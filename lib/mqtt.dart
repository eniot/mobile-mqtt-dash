import 'package:eniot_dash/io.dart';
import 'package:eniot_dash/server.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';

typedef FindIOCallback = void Function(IO io);
typedef IOListenSubscribe = void Function(int value);

class Mqtt {
  MqttClient client;
  bool connected;
  FindIOCallback onFindIO;
  final customSubscriptions = Map<String, List<IOListenSubscribe>>();

  Mqtt(ServerInfo info) {
    this.client = MqttClient.withPort(info.server, info.clientId, info.port);
    client.onDisconnected = () {
      connected = false;
      client.connect(info.username, info.password);
    };
    client.onConnected = () {
      connected = true;
    };
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
  }

  void _handleMessage(String topic, String payload) {
    final topicParts = topic.split("/");
    if(onFindIO != null && topicParts.length == 3 && topicParts[0] == 'res' && topicParts[2] == "io") 
    {
      Iterable ioPayloads = jsonDecode(payload);
      ioPayloads.forEach((ioJson) {
        final io = IO.fromJson(ioJson);
        io.device = topicParts[1];
        io.inTopic = "res/" + io.device + "/" + io.io;
        return onFindIO(io);
      });
    }
    if(customSubscriptions.containsKey(topic)) {
      customSubscriptions[topic].forEach((fn) {
        var val = int.tryParse(payload);
        if(val != null) 
          fn(val);
      });
    }
  }

  bool findIOs() {
    if (!connected) return false;
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString('get');
    client.publishMessage('cmd/*/io', MqttQos.atLeastOnce, builder.payload);
    return true;
  }

  void subscribe(String inTopic, IOListenSubscribe func) {
    if(!customSubscriptions.containsKey(inTopic)) {
      client.subscribe(inTopic, MqttQos.atLeastOnce);
      customSubscriptions[inTopic] = List();
    }
    if(!customSubscriptions[inTopic].contains(func)){
      customSubscriptions[inTopic].add(func);
    }
  }
}
