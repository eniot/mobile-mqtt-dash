import 'package:eniot_dash/src/io.dart';
import 'package:flutter/material.dart';

class IOCard extends StatefulWidget {
  final IO io;

  const IOCard({Key key, this.io}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new _IOCardState(io);
}

class _IOCardState extends State<IOCard> {
  final IO io;
  bool _working = false;
  _IOCardState(this.io) {
    io.onExternalChange = (IO currIO) {
      setState(() {
        _working = false;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_working) {
      return Card(
        child: Center(
          child: Text("Woring..."),
        ),
      );
    }
    return Card(
      child: Center(
        child: SwitchListTile(
          title: Text(io.device),
          subtitle: Text(io.io),
          value: io.isOn(),
          onChanged: (bool switchValue) {
            setState(() {
              io.setOnOff(switchValue);
              _working = true;
            });
          },
        ),
      ),
    );
  }
}
