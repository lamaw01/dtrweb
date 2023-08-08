import 'package:dtrweb/model/log_model.dart';
import 'package:dtrweb/model/schedule_model.dart';

class ExcelModel {
  String rowCount;
  String employeeId;
  String name;
  String timeIn1;
  String timeOut1;
  String timeIn2;
  String timeOut2;
  String duration;
  String lateIn;
  String lateBreak;
  ScheduleModel? scheduleModel;
  List<Log>? logs;

  ExcelModel({
    required this.rowCount,
    required this.employeeId,
    required this.name,
    required this.timeIn1,
    required this.timeOut1,
    required this.timeIn2,
    required this.timeOut2,
    required this.duration,
    required this.lateIn,
    required this.lateBreak,
    this.scheduleModel,
    this.logs,
  });
}
