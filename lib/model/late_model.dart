class LateModel {
  int hour;
  int lateIn;
  int lateBreak;
  int overtime;

  LateModel({
    required this.hour,
    required this.lateIn,
    required this.lateBreak,
    required this.overtime,
  });
}

class LateMinutesModel {
  int lateInMinutes;
  int lateBreakMinutes;
  int overtimeSeconds;

  LateMinutesModel({
    required this.lateInMinutes,
    required this.lateBreakMinutes,
    required this.overtimeSeconds,
  });
}
