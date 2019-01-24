import 'package:eniot_dash/io_card.dart';
import 'package:eniot_dash/src/io.dart';
import 'package:eniot_dash/src/mqtt.dart';
import 'package:flutter/material.dart';

class IOList extends StatefulWidget {
  final Mqtt mqtt;

  const IOList({Key key, this.mqtt}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new _IOListState(mqtt);
}

class _IOListState extends State<IOList> {
  final data = Map<String, IO>();
  final Mqtt mqtt;

  _IOListState(this.mqtt) {
    mqtt.onFindIO = (topicParts, ioJson) {
      IO io = IO(mqtt,
          device: topicParts[1],
          io: ioJson["io"],
          mode: ioJson["mode"],
          value: ioJson["val"] ?? IO.LOW);
      add(io);
    };
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
    return new RefreshIndicator(
      child: OrientationBuilder(builder: (context, orientation) {
        return GridView.count(
          crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
          childAspectRatio: orientation == Orientation.portrait ? 2 : 2.5,
          children: _widgets(),
        );
      }),
      onRefresh: () async {
        mqtt.findIO();
        return Future.delayed(Duration(seconds: 1), () {});
      },
    );
  }
}
