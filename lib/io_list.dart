import 'package:eniot_dash/io_card.dart';
import 'package:eniot_dash/src/io.dart';
import 'package:eniot_dash/src/mqtt.dart';
import 'package:eniot_dash/src/server.dart';
import 'package:flutter/material.dart';

class IOList extends StatefulWidget {
  final IOListState state;
  IOList({Key key, this.state}) : super(key: key);
  @override
  State<StatefulWidget> createState() => state;
}

class IOListState extends State<IOList> {
  final data = Map<String, IO>();
  final ServerInfo serverInfo;
  Mqtt mqtt;
  String error;

  void updateServerInfo(ServerInfo info) async {
    if (mqtt != null) mqtt.disconnect();
    mqtt = new Mqtt(serverInfo, onError: (msg, _) {
      setState(() {
        error = msg;
      });
    }, onFindIO: (topicParts, ioJson, _mqtt) {
      IO io = IO(_mqtt,
          device: topicParts[1],
          io: ioJson["io"],
          mode: ioJson["mode"],
          value: ioJson["val"] ?? IO.LOW);
      add(io);
    });
    await mqtt.verifyConnection().then((_) {
      setState(() {});
    });
  }

  IOListState(this.serverInfo) {
    updateServerInfo(this.serverInfo);
  }

  void add(IO io) {
    setState(() {
      final key = _key(io.device, io.io);
      data[key] = io;
    });
  }

  void remove(String device, String io) {
    setState(() {
      final key = _key(device, io);
      if (!data.containsKey(key)) return;
      data.remove(key);
    });
  }

  String _key(String device, String io) => device + "_" + io;

  List<IOCard> _widgets() =>
      data.values.map((io) => new IOCard(io: io)).toList();

  @override
  Widget build(BuildContext context) {
    if (mqtt.connected()) {
      return new RefreshIndicator(
        child: OrientationBuilder(builder: (context, orientation) {
          return GridView.count(
            crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
            childAspectRatio: orientation == Orientation.portrait ? 2 : 2.5,
            children: _widgets(),
          );
        }),
        onRefresh: () async {
          data.clear();
          mqtt.findIO();
          return Future.delayed(Duration(seconds: 1), () {});
        },
      );
    } else if (mqtt.connecting()) {
      return new Center(child: Text("Connecting..."));
    } else {
      return new Center(child: Text(error ?? "Not connected..."));
    }
  }
}
