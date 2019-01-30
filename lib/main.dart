import 'package:eniot_dash/io_list.dart';
import 'package:eniot_dash/server_form.dart';
import 'package:eniot_dash/server_list.dart';
import 'package:eniot_dash/src/server.dart';
import 'package:eniot_dash/src/mqtt.dart';
import 'package:flutter/material.dart';

final title = "eniot dashboard";
void main() => runApp(new MaterialApp(home: MainApp(), title: title));

class MainApp extends StatefulWidget {
  @override
  MainAppState createState() => new MainAppState();
}

class MainAppState extends State<MainApp> {
  Mqtt mqtt;
  Servers _servers;
  ServerList _serverList;

  MainAppState() {
    _servers = new Servers(
      onChange: (name, currInfo) {
        setState(() {
          if (mqtt != null) mqtt.disconnect();
          mqtt = new Mqtt(currInfo);
          mqtt.findIO();
        });
      },
      onEmpty: () => _newServerForm(false),
    );
    _serverList = new ServerList(
      servers: _servers,
      onAdd: () => _newServerForm(true),
    );
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

  void _newServerForm(bool popable) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServerForm(
              (name, sInfo) {
                _servers.add(name, sInfo);
                _servers.select(name);
                _servers.save();
              },
              popable: popable,
            ),
      ),
    );
  }
}
