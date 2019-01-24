import 'package:eniot_dash/io.dart';
import 'package:eniot_dash/mqtt.dart';

typedef IOListChangeCallback = void Function();

class IOList {
  final data = Map<String, IO>();
  final Mqtt mqtt;

  IOListChangeCallback onChange;

  IOList(this.mqtt) {
    mqtt.onFindIO = (IO io) {
      add(io);
    };
  }

  void add(IO io) {
    if (data.containsKey(io.io)) return;
    data[io.io] = io;
    if (onChange != null) onChange();
  }

  void remove(String io) {
    if (!data.containsKey(io)) return;
    data.remove(io);
    if (onChange != null) onChange();
  }

  List<IOCard> widgets() =>
      data.values.map((io) => new IOCard(io: io)).toList();
}
