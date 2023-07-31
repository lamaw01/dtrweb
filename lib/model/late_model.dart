class LateModel {
  int hour;
  int lateIn;
  int lateBreak;

  LateModel({
    required this.hour,
    required this.lateIn,
    required this.lateBreak,
  });
}

class LateMinutesModel {
  int lateInMinutes;
  int lateBreakMinutes;

  LateMinutesModel({
    required this.lateInMinutes,
    required this.lateBreakMinutes,
  });
}
