import 'package:eniot_dash/io_list.dart';
import 'package:eniot_dash/server_form.dart';
import 'package:eniot_dash/server_list.dart';
import 'package:eniot_dash/src/server.dart';
import 'package:flutter/material.dart';

final title = "eniot dashboard";
void main() => runApp(new MaterialApp(home: MainApp(), title: title));

class MainApp extends StatefulWidget {
  @override
  MainAppState createState() => new MainAppState();
}

class MainAppState extends State<MainApp> {
  Servers _servers;
  ServerList _serverList;
  IOListState _ioListState;
  String _serverName;

  MainAppState() {
    _servers = new Servers(
      onChange: (name, currInfo) {
        setState(() {
          if (_ioListState == null)
            _ioListState = new IOListState(currInfo);
          else
            _ioListState.updateServerInfo(currInfo);
          _serverName = name;
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
        title: Text(_serverName ?? title),
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
      body: _ioListState == null
          ? new Text("Loading...")
          : new IOList(state: _ioListState),
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
