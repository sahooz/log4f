class Log {
  final DateTime time;
  final String level;
  final String tag;
  final String msg;
  final String trace;

  Log(this.time, this.level, this.tag, this.msg, this.trace);

  String get displayTime => "${time.hour}:${time.minute}:${time.second}:${time.millisecond}";

  bool levelHigherThan(String level) {
    return _map[level.toLowerCase()]?.contains(this.level.toLowerCase()) ?? false;
  }

  static Map<String, List<String>>_map = {
    'v': ['v', 'd', 'i', 'w', 'e', 'wtf'],
    'd': ['d', 'i', 'w', 'e', 'wtf'],
    'i': ['i', 'w', 'e', 'wtf'],
    'w': ['w', 'e', 'wtf'],
    'e': ['e', 'wtf'],
    'wtf': ['wtf'],
  };
}