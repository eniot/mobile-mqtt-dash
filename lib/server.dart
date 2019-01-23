import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// MQTT Server configuration
class ServerInfo {
  String clientId;
  String server;
  int port;
  String username;
  String password;

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
  final SharedPreferences prefs;

  Servers(this.prefs);

  factory Servers.fromJson(SharedPreferences prefs, Map<String, dynamic> json) {
    Servers instances = Servers(prefs);
    json.forEach((name, server) {
      instances.add(name, ServerInfo.fromJson(server));
    });
    return instances;
  }

  Map<String, dynamic> toJson() => servers;  

  void add(String name, ServerInfo server) => servers[name] = server;
  ServerInfo fetch(String name) => servers[name];
  void delete(String name) => servers.remove(name);
  void save() => prefs.setString(prefKey, jsonEncode(servers));
}
