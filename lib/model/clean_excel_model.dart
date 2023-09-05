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
  TimeLog in1;
  TimeLog out1;
  TimeLog in2;
  TimeLog out2;

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
    required this.in1,
    required this.out1,
    required this.in2,
    required this.out2,
  });
}
