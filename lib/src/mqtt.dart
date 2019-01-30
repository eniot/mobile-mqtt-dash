import 'package:eniot_dash/src/server.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';

typedef FindIOCallback = void Function(List<String>, dynamic, Mqtt);
typedef IOListenSubscribe = void Function(String);
typedef MqttErrorCallback = void Function(String, Mqtt);

class Mqtt {
  MqttClient client;
  bool connected() =>
      client.connectionStatus.state == MqttConnectionState.connected;
  bool connecting() =>
      client.connectionStatus.state == MqttConnectionState.connecting;
  final FindIOCallback onFindIO;

  final customSubscriptions = Map<String, List<IOListenSubscribe>>();
  final ServerInfo info;
  final MqttErrorCallback onError;

  Mqtt(this.info, {this.onError, this.onFindIO}) {
    this.client = MqttClient.withPort(
        info.server, info.clientId, info.port ?? Constants.defaultMqttPort);
    client.onDisconnected = () {
      client.connect(info.username, info.password);
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
    };
  }

  Future<bool> connect() async {
    try {
      return await client.connect(info.username, info.password).then((status) {
        return connected();
      });
    } catch (e) {
      if (onError != null) onError(e.toString(), this);
      return false;
    }
  }

  Future<bool> verifyConnection() async => connected() || await connect();

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

  void subscribe(String inTopic, IOListenSubscribe func) {
    if (!customSubscriptions.containsKey(inTopic)) {
      client.subscribe(inTopic, MqttQos.atLeastOnce);
      customSubscriptions[inTopic] = List();
    }
    if (!customSubscriptions[inTopic].contains(func)) {
      customSubscriptions[inTopic].add(func);
    }
  }

  void publish(String topic, String payload) async {
    if (await verifyConnection()) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload);
    }
  }

  void findIO() => publish("cmd/*/io", "get");
  void disconnect() {
    if (client != null && connected()) client.disconnect();
  }
}
