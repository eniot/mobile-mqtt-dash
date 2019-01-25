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
    return Card(
      child: Center(
        child: ListTile(
          title: Text(io.device),
          subtitle: Text(io.io),
          trailing: _trailView(),
        ),
      ),
    );
  }

  Widget _trailView() => (io.readOnly()
      ? _valueView()
      : _working ? _workingView() : _swicthView());

  Widget _workingView() => const Padding(
        padding: EdgeInsets.all(10.0),
        child: CircularProgressIndicator(),
      );

  Widget _valueView() => io.isOn()
      ? Icon(Icons.blur_circular, color: Colors.blue, size: 30)
      : Icon(Icons.blur_circular, size: 30);

  Widget _swicthView() {
    return Switch(
      value: io.isOn(),
      onChanged: (val) {
        setState(() {
          _working = true;
          io.setOnOff(val);
        });
      },
    );
  }
}
