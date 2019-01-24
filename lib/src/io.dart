import 'package:eniot_dash/src/mqtt.dart';

typedef IOChangeCallback = void Function(IO io);

class IO {
  static const int HIGH = 1;
  static const int LOW = 0;
  static const String READ_WRITE = "rw";
  static const String READ_ONLY = "ro";

  IOChangeCallback onExternalChange;
  IOChangeCallback onInternalChange;

  String device;
  String io;
  String inTopic;
  String outTopic;
  String mode;
  int _value;

  final Mqtt mqtt;

  IO(this.mqtt,
      {String device,
      String io,
      int value,
      String inTopic,
      String outTopic,
      String mode}) {
    this.device = device;
    this.io = io;
    this.mode = mode;
    this.inTopic = inTopic ?? "res/" + device + "/io/" + io;
    this.outTopic = outTopic ?? "cmd/" + device + "/io/" + io;
    setExternalVal(value);

    mqtt.subscribe(this.inTopic, (String payload) {
      var val = int.tryParse(payload);
      if (val == null) return;
      setExternalVal(val);
    });
  }
  void setExternalVal(int val) {
    _value = val;
    if (onExternalChange != null) onExternalChange(this);
  }

  bool isOn() => _value == HIGH;
  void setOnOff(bool val) => val ? setValue(HIGH) : setValue(LOW);
  void setValue(int val) {
    _value = val;
    mqtt.publish(outTopic, "set:" + _value.toString());
  }

  Map<String, dynamic> toJson() => {
        'io': io,
        'val': _value,
        'mode': mode,
        'device': device,
        'in_topic': inTopic,
        'out_topic': outTopic
      };
}
