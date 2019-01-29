import 'package:eniot_dash/io_list.dart';
import 'package:eniot_dash/server_form.dart';
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
  Servers _servers;

  MainAppState() {
    _servers = new Servers(onChange: (name, currInfo) {
      setState(() {        
        currServerInfo = currInfo;
        if(mqtt != null) mqtt.disconnect();
        mqtt = new Mqtt(currServerInfo);
      });
    }, onEmpty: () {
      _newServerForm();
    });
    _serverList = new ServerList(servers: _servers);
  }

  @override
  void initState() {
    super.initState();
    if(mqtt != null) mqtt.connect();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
      body: mqtt == null ? new Text("Loading...") : new IOList(mqtt: mqtt),
    );
  }

  void _serversModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(child: _serverList);
        });
  }

  void _newServerForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServerForm((name, sInfo) {
              _servers.add(name, sInfo);
              _servers.select(name);
              _servers.save();
            }),
      ),
    );
  }
}
