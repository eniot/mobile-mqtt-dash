import 'package:eniot_dash/dialogs.dart';
import 'package:eniot_dash/src/server.dart';
import 'package:flutter/material.dart';

typedef ServerListRemoveCallback = void Function(String);
typedef ServerListAddCallback = void Function();
typedef ServerListSelectCallback = void Function(String);

class ServerList extends StatefulWidget {
  final Map<String, ServerInfo> servers;
  final String selected;
  final ServerListRemoveCallback onRemove;
  final ServerListAddCallback onAdd;
  final ServerListSelectCallback onSelect;

  const ServerList(this.servers, this.selected,
      {Key key, this.onRemove, this.onAdd, this.onSelect})
      : super(key: key);

  @override
  _ServerListState createState() => new _ServerListState(servers, selected, onRemove, onAdd, onSelect);
}

class _ServerListState extends State<ServerList> {
  final Map<String, ServerInfo> servers;
  String selected;
  final ServerListRemoveCallback onRemove;
  final ServerListAddCallback onAdd;
  final ServerListSelectCallback onSelect;

  _ServerListState(
      this.servers, this.selected, this.onRemove, this.onAdd, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = servers
        .map((name, info) {
          var icon = selected == name
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
                  selected = name;
                });
                onSelect(name);
              },
              onLongPress: () {
                if (name == selected) return;
                confirmDialog(context, "Removing " + name, onConfirm: () {
                  setState(() {
                    servers.remove(name);
                  });
                  onRemove(name);
                });
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
        onAdd();
      },
    ));
    return new Wrap(children: widgets);
  }
}
