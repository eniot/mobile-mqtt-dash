import 'package:eniot_dash/src/server.dart';
import 'package:flutter/material.dart';

class ServerForm extends StatefulWidget {
  final ServerInfo info;

  const ServerForm({Key key, this.info}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      _ServerFormState(info ?? new ServerInfo());
}

class _ServerFormState extends State {
  final ServerInfo info;
  final _formKey = GlobalKey<FormState>();
  _ServerFormState(this.info);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: Builder(
          builder: (scontext) => AppBar(
                title: Text("MQTT Server"),
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      _save(scontext);
                    },
                  ),
                ],
              ),
        ),
      ),
      body: Builder(
        builder: (scontext) => SingleChildScrollView(
              child: _form(scontext),
            ),
      ),
    );
  }

  _save(BuildContext context) {
    if (!_formKey.currentState.validate()) return;
    final snackBar = SnackBar(content: Text('Trying to connect...'));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Widget _form(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _formFields(context)),
      ),
    );
  }

  List<Widget> _formFields(BuildContext context) {
    return [
      TextFormField(
        decoration:
            InputDecoration(labelText: "Server", hintText: "mqtt.local"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a server address';
          }
        },
      ),
      TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: "Port", hintText: "1883"),
        validator: (value) {
          if (value.isNotEmpty && int.tryParse(value) != null) {
            return 'Please enter a port number';
          }
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Username"),
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Password"),
      ),
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              _save(context);
            },
            child: Text('Save'),
          ),
        ),
      ),
    ];
  }
}
