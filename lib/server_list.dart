import 'package:eniot_dash/src/server.dart';
import 'package:flutter/material.dart';

typedef ServerListAddCallback = void Function();

class ServerList extends StatefulWidget {
  final Servers servers;
  final ServerListAddCallback onAdd;

  const ServerList({Key key, this.servers, this.onAdd}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ServerListState(servers, onAdd);
}

class _ServerListState extends State<ServerList> {
  final Servers servers;
  final ServerListAddCallback onAdd;

  _ServerListState(this.servers, this.onAdd);
  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = servers.servers
        .map((name, info) {
          var icon = servers.selected == name
              ? new Icon(Icons.cloud_done, color: Colors.blue)
              : new Icon(Icons.cloud);
          return MapEntry(
            name,
            new ListTile(
              leading: icon,
              title: new Text(name),
              subtitle: new Text(info.server),
              onTap: () {
                setState(() {
                  servers.select(name);
                });
                Navigator.of(context).pop();
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (alertContext) => AlertDialog(
                        title: new Text("Removing " + name),
                        content: new Text("Are you sure?"),
                        actions: <Widget>[
                          new FlatButton(
                            textColor: Colors.grey,
                            child: new Text("Yes"),
                            onPressed: () {
                              Navigator.of(alertContext).pop();
                              setState(() {
                                servers.delete(name);
                                servers.save();
                              });
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
              },
            ),
          );
        })
        .values
        .toList();

    widgets.add(new ListTile(
      title: Text("add MQTT server"),
      leading: Icon(Icons.add_to_queue),
      onTap: () {
        Navigator.of(context).pop();
        onAdd();
      },
    ));

    return new Wrap(
      children: widgets,
    );
  }
}
