import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// MQTT Server configuration
class ServerInfo {
  String clientId;
  String server;
  int port;
  String username;
  String password;

  ServerInfo(
      {String clientId,
      String server,
      int port,
      String username,
      String password}) {
    this.clientId = clientId;
    this.server = server;
    this.port = port;
    this.username = username;
    this.password = password;
  }

  ServerInfo.fromJson(Map<String, dynamic> json)
      : server = json["server"],
        clientId = json["client_id"],
        port = json["port"],
        username = json["username"],
        password = json["password"];

  Map<String, dynamic> toJson() => {
        'server': server,
        'port': port,
        'username': username,
        'password': password,
        'client_id': clientId
      };
}

typedef ServersEmptyCallback = void Function();
typedef ServersChangeCallback = void Function(String, ServerInfo);

// MQTT Server configuration set
class Servers {
  final prefKey = "mqtt_servers";
  final servers = new Map<String, ServerInfo>();
  String selected;
  final ServersEmptyCallback onEmpty;
  final ServersChangeCallback onChange;

  SharedPreferences prefs;
  Servers({this.onEmpty, this.onChange}) {
    () async {
      prefs = await SharedPreferences.getInstance();
      if (prefs == null) return onEmpty();
      final scontent = prefs.getString(prefKey);
      if (scontent == null) return onEmpty();
      final Map json = jsonDecode(scontent);
      loadFromJson(json);
    }();
  }

  void loadFromJson(Map<String, dynamic> json) {
    json.forEach((name, server) {
      add(name, ServerInfo.fromJson(server));
    });
    if (servers.isEmpty) onEmpty();
    else select(servers.keys.first);    
  }

  Map<String, dynamic> toJson() => servers;

  void add(String name, ServerInfo server) => servers[name] = server;
  ServerInfo fetch(String name) =>
      servers.containsKey(name) ? servers[name] : null;
  void delete(String name) { 
    servers.remove(name);
    if(servers.isEmpty) onEmpty();
  }
  void save() => prefs.setString(prefKey, jsonEncode(servers));

  void select(String name) {
    var info = fetch(name);
    if (info != null) {
      try {
        if (onChange != null) onChange(name, info);
        selected = name;
      } catch (_) {}
    }
  }
}
