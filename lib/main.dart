import 'package:eniot_dash/io_list.dart';
import 'package:eniot_dash/server_list.dart';
import 'package:eniot_dash/src/server.dart';
import 'package:eniot_dash/src/mqtt.dart';
import 'package:flutter/material.dart';

final title = "eniot dashboard";
void main() => runApp(new MaterialApp(home: MainApp(), title: title));
ServerInfo currServerInfo;

class MainApp extends StatefulWidget {
  @override
  MainAppState createState() => new MainAppState();
}

class MainAppState extends State<MainApp> {
  Mqtt mqtt;
  ServerList _serverList;

  MainAppState() {
    _serverList = new ServerList(
      servers: new Servers(
          onChange: (name, currInfo) {
            setState(() {
              currServerInfo = currInfo;
              mqtt = new Mqtt(currServerInfo);
            });
          },
          onEmpty: () {
            _newServerForm();
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.cloud_queue),
            onPressed: () {
              _serversModalBottomSheet(context);
            },
          ),
        ],
      ),
      body: mqtt == null? new Text("Loading..."): new IOList(mqtt: mqtt),
    );
  }

  void _serversModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(child: _serverList);
        });
  }

  void _newServerForm(){
    //TODO
  }
}
