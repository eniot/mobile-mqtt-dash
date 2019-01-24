import 'package:eniot_dash/io_list.dart';
import 'package:eniot_dash/src/server.dart';
import 'package:eniot_dash/src/mqtt.dart';
import 'package:flutter/material.dart';

void main() => runApp(MainApp());
Servers servers = new Servers();

class MainApp extends StatefulWidget {
  MainApp() {
    () async {
      servers.add(
          "default",
          new ServerInfo(
              clientId: "test-app",
              server: "m15.cloudmqtt.com",
              port: 11942,
              username: "avpibbsx",
              password: "W5JpLz3234kz"));
    }();
  }

  @override
  MainAppState createState() => new MainAppState();
}

class MainAppState extends State<MainApp> {
  final mqtt = new Mqtt(servers.fetch("default"));
  final title = "eniot dashboard";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: new IOList(mqtt: mqtt),
      ),
    );
  }
}
