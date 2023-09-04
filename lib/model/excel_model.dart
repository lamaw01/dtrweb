import 'package:dtrweb/model/log_model.dart';
import 'package:dtrweb/model/schedule_model.dart';

class ExcelModel {
  String rowCount;
  String employeeId;
  String name;
  String duration;
  String lateIn;
  String lateBreak;
  String overtime;
  ScheduleModel scheduleModel;
  List<Log> logs;
  Log? log1;
  Log? log2;
  Log? log3;
  Log? log4;

  ExcelModel({
    required this.rowCount,
    required this.employeeId,
    required this.name,
    required this.duration,
    required this.lateIn,
    required this.lateBreak,
    required this.overtime,
    required this.scheduleModel,
    required this.logs,
    this.log1,
    this.log2,
    this.log3,
    this.log4,
  });
}
