import 'log_model.dart';
import 'schedule_model.dart';

class CleanExcelDataModel {
  String employeeId;
  String name;
  DateTime date;
  List<Log> logs;
  ScheduleModel currentSched;
  String duration;
  String lateIn;
  String lateBreak;
  String overtime;
  String rowCount;

  CleanExcelDataModel({
    required this.employeeId,
    required this.name,
    required this.date,
    required this.logs,
    required this.currentSched,
    required this.duration,
    required this.lateIn,
    required this.lateBreak,
    required this.overtime,
    required this.rowCount,
  });
}
