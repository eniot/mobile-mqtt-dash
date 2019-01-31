import 'package:eniot_dash/dialogs.dart';
import 'package:eniot_dash/io_card.dart';
import 'package:eniot_dash/server_form.dart';
import 'package:eniot_dash/server_list.dart';
import 'package:eniot_dash/src/io.dart';
import 'package:eniot_dash/src/mqtt.dart';
import 'package:eniot_dash/src/server.dart';
import 'package:flutter/material.dart';

final title = "eniot dashboard";
void main() => runApp(new MaterialApp(home: MainApp(), title: title));

class MainApp extends StatefulWidget {
  @override
  MainAppState createState() => new MainAppState();
}

class MainAppState extends State<MainApp> {
  final _ioMap = Map<String, IO>();
  Mqtt _mqtt;
  Servers _servers;

  @override
  void initState() {
    super.initState();
    _servers = new Servers(
      onChange: (name, currInfo) {
        setState(() {
          _ioMap.clear();
        });
        // Update MQTT connection
        if (_mqtt != null) _mqtt.disconnect();
        _mqtt = new Mqtt(currInfo, onFindIO: (topicParts, json, mqtt) {
          setState(() {
            final io = IO.fromMqttResponse(mqtt, topicParts, json);
            _ioMap[io.key()] = io;
          });
        }, onError: (msg, _) {
          setState(() {});
        });
        _mqtt.verifyConnection();
      },
      onEmpty: () => _newServerForm(false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text(_servers.selected ?? title),
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
        body: _ioList(context));
  }

  void _serversModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new ServerList(
            _servers.servers,
            _servers.selected,
            onAdd: () {
              _newServerForm(true);
            },
            onRemove: _servers.remove,
            onSelect: (name) {
              _servers.select(name);
              Navigator.of(bc).pop();
            },
          ),
        );
      },
    );
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

  Widget _ioList(BuildContext context) {
    if (_mqtt == null) {
      return new Center(child: Text("Please select a connection"));
    }
    if (_mqtt.connected()) {
      return new RefreshIndicator(
        child: OrientationBuilder(builder: (context, orientation) {
          return GridView.count(
            crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
            childAspectRatio: orientation == Orientation.portrait ? 2 : 2.5,
            children: _ioMap.values.map((io) => new IOCard(io: io)).toList(),
          );
        }),
        onRefresh: () async {
          _ioMap.clear();
          _mqtt.findIO();
          return Future.delayed(Duration(seconds: 1), () {});
        },
      );
    } else {
      return new Center(child: Text(_mqtt.statusMessage()));
    }
  }
}
