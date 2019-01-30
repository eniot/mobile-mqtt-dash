import 'package:eniot_dash/src/server.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:random_string/random_string.dart' as random;

typedef ServerFormSubmitCallback = void Function(String, ServerInfo);

class ServerForm extends StatefulWidget {
  final ServerInfo info;
  final ServerFormSubmitCallback onSubmit;
  final bool popable;

  const ServerForm(this.onSubmit, {Key key, this.info, this.popable = true})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      _ServerFormState(info ?? new ServerInfo(), onSubmit, popable);
}

class _ServerFormState extends State {
  final ServerInfo info;
  final ServerFormSubmitCallback onSubmit;
  final bool popable;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serverController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  _ServerFormState(this.info, this.onSubmit, this.popable);

  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          child: Builder(
            builder: (preferredSizeContext) => AppBar(
                  title: Text("MQTT Server"),
                  automaticallyImplyLeading: popable,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () {
                        _save(preferredSizeContext);
                      },
                    ),
                  ],
                ),
          ),
        ),
        body: Builder(
          builder: (scaffoldContext) => SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              labelText: "Connection Name",
                              hintText: "Home MQTT"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a connection name';
                            }
                          },
                        ),
                        TextFormField(
                          controller: _serverController,
                          decoration: InputDecoration(
                              labelText: "Server", hintText: "mqtt.local"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a server address';
                            }
                          },
                        ),
                        TextFormField(
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: "Port", hintText: "1883"),
                          validator: (value) {
                            if (value.isNotEmpty &&
                                int.tryParse(value) == null) {
                              return 'Please enter a port number';
                            }
                          },
                        ),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(labelText: "Username"),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: "Password"),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: FlatButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              onPressed: () {
                                _save(scaffoldContext);
                              },
                              child: Text('Save'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
      onWillPop: () {
        return new Future(() => popable);
      },
    );
  }

  _save(BuildContext childContext) async {
    if (!_formKey.currentState.validate()) return;

    final sInfo = new ServerInfo();
    sInfo.clientId = random.randomAlphaNumeric(10);
    sInfo.server = _serverController.text;
    sInfo.port =
        int.tryParse(_portController.text) ?? Constants.defaultMqttPort;
    sInfo.username = _usernameController.text;
    sInfo.password = _passwordController.text;

    final snackBar = SnackBar(content: Text('Trying to connect...'));
    Scaffold.of(childContext).showSnackBar(snackBar);
    final mqtt = MqttClient.withPort(
        sInfo.server.trim(), sInfo.clientId.trim(), sInfo.port);
    try {
      await mqtt.connect(sInfo.username.trim(), sInfo.password.trim());
      mqtt.disconnect();
      Scaffold.of(childContext).hideCurrentSnackBar();
      _submit(childContext, sInfo);
    } on Exception catch (_) {
      Scaffold.of(childContext).hideCurrentSnackBar();
      mqtt.disconnect();
      showDialog(
        context: childContext,
        builder: (alertContext) => AlertDialog(
              title: new Text("MQTT Connection Failed"),
              content: new Text("Do you want to save the configuration?"),
              actions: <Widget>[
                new FlatButton(
                  textColor: Colors.grey,
                  child: new Text("Yes"),
                  onPressed: () {
                    Navigator.of(alertContext).pop();
                    _submit(childContext, sInfo);
                  },
                ),
                new FlatButton(
                  child: new Text("No"),
                  onPressed: () {
                    Navigator.of(alertContext).pop();
                  },
                ),
              ],
            ),
      );
    }
  }

  void _submit(BuildContext childContext, ServerInfo sInfo) {
    if (onSubmit != null) onSubmit(_nameController.text.trim(), sInfo);
    Navigator.of(context).pop();
  }
}
