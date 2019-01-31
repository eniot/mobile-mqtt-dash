import 'package:eniot_dash/src/server.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';

typedef FindIOCallback = void Function(List<String>, dynamic, Mqtt);
typedef IOListenSubscribe = void Function(String);
typedef MqttStateChangeCallback = void Function();

class Mqtt {
  MqttClient client;

  bool connected() =>
      client.connectionStatus.state == MqttConnectionState.connected;
  bool connecting() =>
      client.connectionStatus.state == MqttConnectionState.connecting;

  final customSubscriptions = Map<String, List<IOListenSubscribe>>();
  final ServerInfo info;

  // Events
  final MqttStateChangeCallback onStateChange;
  final FindIOCallback onFindIO;
  String error;

  Mqtt(this.info, {this.onStateChange, this.onFindIO}) {
    this.client = MqttClient.withPort(
        info.server, info.clientId, info.port ?? Constants.defaultMqttPort);
    client.onDisconnected = () {
      if (onStateChange != null) onStateChange();
      //client.connect(info.username, info.password);
    };
    client.onConnected = () {
      client.subscribe('res/#', MqttQos.atLeastOnce);
      client.subscribe('err/#', MqttQos.atLeastOnce);
      client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        for (var i = 0; i < c.length; i++) {
          final MqttPublishMessage recMess = c[i].payload;
          final String payload =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          _handleMessage(c[i].topic, payload);
        }
      });
      findIO();
    };
  }

  void _handleMessage(String topic, String payload) {
    final topicParts = topic.split("/");
    if (onFindIO != null &&
        topicParts.length == 3 &&
        topicParts[0] == 'res' &&
        topicParts[2] == "io") {
      Iterable ioPayloads = jsonDecode(payload);
      ioPayloads.forEach((ioJson) {
        return onFindIO(topicParts, ioJson, this);
      });
    }
    if (customSubscriptions.containsKey(topic)) {
      customSubscriptions[topic].forEach((fn) {
        fn(payload);
      });
    }
  }

  // Verify Connection
  Future<bool> verifyConnection() async => connected() || await connect();

  // connect
  Future<bool> connect() async {
    try {
      return await client.connect(info.username, info.password).then((status) {
        if (onStateChange != null) onStateChange();
        return connected();
      });
    } catch (_) {
      if (onStateChange != null) onStateChange();
      return false;
    }
  }

  // Subscribe to topic
  void subscribe(String inTopic, IOListenSubscribe func) {
    if (!customSubscriptions.containsKey(inTopic)) {
      client.subscribe(inTopic, MqttQos.atLeastOnce);
      customSubscriptions[inTopic] = List();
    }
    if (!customSubscriptions[inTopic].contains(func)) {
      customSubscriptions[inTopic].add(func);
    }
  }

  // Publish message
  void publish(String topic, String payload) async {
    if (await verifyConnection()) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload);
    }
  }

  // Find IOs
  void findIO() {
    if (onStateChange != null) onStateChange();
    publish("cmd/*/io", "get");
  }

  // Disconnect client
  void disconnect() {
    if (client != null && connected()) client.disconnect();
    if (onStateChange != null) onStateChange();
  }

  // Get Status message
  String statusMessage() {
    switch (client.connectionStatus.state) {
      case MqttConnectionState.connected:
        return "Connected";
      case MqttConnectionState.connecting:
        return "Trying to connect...";
      case MqttConnectionState.disconnecting:
        return "Disconnecting...";
      case MqttConnectionState.faulted:
        return "Connection failed.\n\nCheck your server configuration, and make sure you are connected to the network.";
      default:
        return "Not connected.";
    }
  }
}
