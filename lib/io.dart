import 'package:eniot_dash/mqtt.dart';

typedef IOChangeCallback = void Function(IO io);

class IO {
  static final high = 1;
  static final low = 0;
  static final modeReadWrite = "rw";
  static final modeReadOnly = "ro";

  IOChangeCallback onChange;

  String device;
  String io;
  String inTopic;
  String outTopic;
  String mode;
  int value;

  bool isOn() => value == high;
  bool isOff() => value == low;
  bool edible() => mode == modeReadWrite;
  bool readOnly() => mode == modeReadOnly;
  void toggle() => isOn() ? turnOff() : turnOn();
  void turnOff() => value = low;
  void turnOn() => value = high;

  IO.fromJson(Map<String, dynamic> json)
      : device = json["device"],
        io = json["io"],
        mode = json["mode"],
        inTopic = json["in_topic"],
        outTopic = json["out_topic"],
        value = json["val"];

  Map<String, dynamic> toJson() => {
    'io': io, 
    'val': value,
    'mode': mode,
    'device': device,
    'in_topic': inTopic,
    'out_topic': outTopic
  };
}

typedef IOAddedCallback = void Function(IO io);

class IOs {
  final data = Map<String, IO>();
  final Mqtt mqtt;

  IOAddedCallback onIOAdded;

  IOs(this.mqtt)
  {
    mqtt.onFindIO = (IO io) {
      add(io);
    };
  }

  void add(IO io) {
    if(data.containsKey(io.io)) 
      return;

    data[io.io] = io;
    mqtt.subscribe(io.inTopic, (int value) {      
      io.value = value;
      if (io.onChange == null){
        io.onChange(io);
      }
    });

    if (onIOAdded != null) 
      onIOAdded(io);
  }
  
  void remove(String io) => data.remove(io);
}