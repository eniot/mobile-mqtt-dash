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

  _IOCardState(this.io) {
    io.onExternalChange = (IO currIO) {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: SwitchListTile(
          title: Text(io.io),
          subtitle: Text(io.device),
          value: io.isOn(),
          onChanged: (bool switchValue) {
            setState(() {
              io.setOnOff(switchValue);
            });
          },
        ),
      ),
    );
  }
}
