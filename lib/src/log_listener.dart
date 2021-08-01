import 'package:log4f/src/log.dart';

abstract class LogListener {
  void onLog(Log log);
}