import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:log4f/src/log.dart';
import 'package:log4f/src/log_listener.dart';
import 'package:stack_trace/stack_trace.dart';

class Log4f {
  
  static String _tag = 'Log4f';
  static final LogContainer logContainer = LogContainer(1024);
  static List<LogListener> _listeners = [];

  static Map<String, Color> colorMap = {
    'v' : Colors.grey,
    'd' : Colors.lightBlue,
    'i' : Colors.lightGreen,
    'w' : Colors.yellow,
    'e' : Colors.redAccent,
    'wtf' : Colors.red,
  };

  static void addLogListener(LogListener listener) {
    _listeners.add(listener);
  }

  static void removeLogListener(LogListener listener) {
    _listeners.remove(listener);
  }
  
  static void setDefaultTag(String tag) {
    _tag = tag;
  }
  
  static const MethodChannel _channel = const MethodChannel('log4f');

  static Future<void> v({String? tag, required String msg, int stackDepth = 0, int logType = 2, bool writeFile = false}) async {
    await log('v', tag, msg, stackDepth, logType, writeFile);
  }

  static Future<void> d({String? tag, required String msg, int stackDepth = 0, int logType = 2, bool writeFile = false}) async {
    await log('d', tag, msg, stackDepth, logType, writeFile);
  }

  static Future<void> i({String? tag, required String msg, int stackDepth = 0, int logType = 2, bool writeFile = false}) async {
    await log('i', tag, msg, stackDepth, logType, writeFile);
  }

  static Future<void> w({String? tag, required String msg, int stackDepth = 10, int logType = 2, bool writeFile = false}) async {
    await log('w', tag, msg, stackDepth, logType, writeFile);
  }

  static Future<void> e({String? tag, required String msg, int stackDepth = 50, int logType = 2, bool writeFile = false}) async {
    await log('e', tag, msg, stackDepth, logType, writeFile);
  }

  static Future<void> wtf({String? tag, required String msg, int stackDepth = 1000, int logType = 2, bool writeFile = false}) async {
    await log('wtf', tag, msg, stackDepth, logType, writeFile);
  }
  
  static Future<void> log(String level, String? tag, String msg, int stackDepth, int logType, bool writeFile) async {
    var args = { 'level': level, 'tag': tag ?? _tag, 'msg': msg, 'write': writeFile, 'logType': logType };
    var stackTrace = '';
    if(stackDepth > 0) { // stackDepth > 0 means we want to print the stack trace
      final chain = Chain.forTrace(StackTrace.current);
      final frames = chain.toTrace().frames;
      if(frames.isNotEmpty) {
        StringBuffer sb = StringBuffer('stack trace:\n');
        int realDepth = min(stackDepth, frames.length);
        int counter = 0;
        for(var i = 0; i < frames.length; i++) {
          var frame = frames[i];
          // Ignore Log4f frames
          if(frame.uri.toString() == 'package:log4f/src/log4f.dart') {
            continue;
          }

          // add prefix
          if(++counter < realDepth) {
            sb.write('|- ');
          } else {
            sb.write('|_ ');
          }
          // add the frame
          sb.write('${frame.member} at: (${frame.uri}:${frame.line}:${frame.column})');
          sb.write('\n');
          if(counter >= realDepth ) {
            break;
          }
        }
        stackTrace = sb.toString();
      }
    }

    if(stackTrace.isNotEmpty) {
      args['trace'] = stackTrace;
    }
    var log = Log(DateTime.now(), level, tag ?? _tag, msg, stackTrace);
    logContainer._addLog(log);
    // notify listeners
    _listeners.forEach((listener) { listener.onLog(log); });
    await _channel.invokeMethod('doLog', args);
  }
}

class LogContainer {
  int capacity;
  List<Log> _logs = [];

  LogContainer(this.capacity);

  int get logSize => _logs.length;

  void _addLog(Log log) {
    _logs.add(log);
    while(_logs.length > capacity) {
      _logs.removeAt(0);
    }
  }

  Log getLogAt(int index) => _logs[index];

  List<Log> get logs => List.from(_logs);

  void clear() {
    _logs.clear();
  }
}
