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

// MQTT Server configuration set
class Servers {
  final prefKey = "mqtt_servers";
  final servers = new Map<String, ServerInfo>();
  SharedPreferences prefs;
  Servers() {
    () async {
      prefs = await SharedPreferences.getInstance();
    }();
  }

  factory Servers.fromJson(Map<String, dynamic> json) {
    Servers instances = new Servers();
    json.forEach((name, server) {
      instances.add(name, ServerInfo.fromJson(server));
    });
    return instances;
  }

  Map<String, dynamic> toJson() => servers;

  void add(String name, ServerInfo server) => servers[name] = server;
  ServerInfo fetch(String name) =>
      servers.containsKey(name) ? servers[name] : null;
  void delete(String name) => servers.remove(name);
  void save() => prefs.setString(prefKey, jsonEncode(servers));
}
