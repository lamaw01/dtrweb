class ExcelModel {
  int rowCount;
  String employeeId;
  String name;
  String timeIn1;
  String timeOut1;
  String timeIn2;
  String timeOut2;
  int duration;
  int lateIn;
  int lateBreak;

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
  });
}
