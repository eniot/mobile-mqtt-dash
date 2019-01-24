import 'package:eniot_dash/io_list.dart';
import 'package:eniot_dash/mqtt.dart';
import 'package:eniot_dash/server.dart';
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
  IOList ioList = IOList(new Mqtt(servers.fetch("default")));

  final title = "eniot dashboard";

  MainAppState() {
    ioList.onChange = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          return GridView.count(
            crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
            childAspectRatio: orientation == Orientation.portrait ? 2 : 2.5,
            children: ioList.widgets(),
          );
        }),
      ),
    );
  }
}
