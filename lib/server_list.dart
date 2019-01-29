import 'package:eniot_dash/src/server.dart';
import 'package:flutter/material.dart';

class ServerList extends StatefulWidget {
  final Servers servers;

  const ServerList({Key key, this.servers}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ServerListState(servers);
}

class _ServerListState extends State<ServerList> {
  final Servers servers;

  _ServerListState(this.servers);
  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = servers.servers
        .map((name, info) {
          return MapEntry(
              name,
              new ListTile(
                leading: new Icon(Icons.cloud),
                title: new Text(name),
                subtitle: new Text(info.server),
                onTap: () {
                  servers.select(name);
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
              ));
        })
        .values
        .toList();
    return new Wrap(
      children: widgets,
    );
  }
}
