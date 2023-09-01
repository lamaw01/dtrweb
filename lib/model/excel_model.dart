import 'package:dtrweb/model/log_model.dart';
import 'package:dtrweb/model/schedule_model.dart';

class ExcelModel {
  String rowCount;
  String employeeId;
  String name;
  // String timeIn1;
  // String timeOut1;
  // String timeIn2;
  // String timeOut2;
  String duration;
  String lateIn;
  String lateBreak;
  String overtime;
  ScheduleModel? scheduleModel;
  List<Log>? logs;
  TimeLog timeLogIn1;
  TimeLog timeLogOut1;
  TimeLog? timeLogIn2;
  TimeLog? timeLogOut2;

  ExcelModel({
    required this.rowCount,
    required this.employeeId,
    required this.name,
    // required this.timeIn1,
    // required this.timeOut1,
    // required this.timeIn2,
    // required this.timeOut2,
    required this.duration,
    required this.lateIn,
    required this.lateBreak,
    required this.overtime,
    this.scheduleModel,
    this.logs,
    required this.timeLogIn1,
    required this.timeLogOut1,
    this.timeLogIn2,
    this.timeLogOut2,
  });
}

class TimeLog {
  String timeLog;
  String isSelfie;

  TimeLog({
    required this.timeLog,
    required this.isSelfie,
  });
}
