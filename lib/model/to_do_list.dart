import 'package:intl/intl.dart';

final formatter = DateFormat.yMEd();

class ToDoList {
  const ToDoList({
    required this.tid,
    required this.catid,
    // ignore: non_constant_identifier_names
    required this.tododetails,
    required this.date,
    required this.time,
    required this.alarm,
    required this.status,
  });

  final int tid;
  final int catid;
  // ignore: non_constant_identifier_names
  final String tododetails;
  final DateTime? date;
  final DateTime? time;
  final bool alarm;
  final String status;

  String get formateddate {
    return formatter.format(date!);
  }
}
