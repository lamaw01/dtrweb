import 'package:dtrweb/model/schedule_model.dart';

import 'log_model.dart';

class CleanDataModel {
  String employeeId;
  String firstName;
  String lastName;
  String middleName;
  DateTime date;
  List<Log> logs;
  ScheduleModel currentSched;
  String? duration;
  String? lateIn;
  String? lateBreak;
  String? overtime;
  String? undertimeIn;
  String? undertimeBreak;
  int? rowCount;

  CleanDataModel({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.date,
    required this.logs,
    required this.currentSched,
    this.duration,
    this.lateIn,
    this.lateBreak,
    this.overtime,
    this.undertimeIn,
    this.undertimeBreak,
    this.rowCount,
  });
}
