import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Environment {
  static const development = 'development';
  static const staging = 'staging';
  static const production = 'production';
  static const test = 'test';
}

class KeyConstants {}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class DateTimeFormat {
  static DateFormat get dayString => DateFormat.EEEE();
  static DateFormat get monthAbbrWithDate => DateFormat.MMMMd();
  static DateFormat get hourMinutes => DateFormat.Hm();
}

enum MessageType {
  info,
  warning,
  success,
  danger,
}
