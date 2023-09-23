class LateModel {
  int hour;
  int lateIn;
  int lateBreak;
  int overtime;
  // int undertimeIn;
  // int undertimelateBreak;
  LateModel({
    required this.hour,
    required this.lateIn,
    required this.lateBreak,
    required this.overtime,
    // required this.undertimeIn,
    // required this.undertimelateBreak,
  });
}

class LateMinutesModel {
  int lateInMinutes;
  int lateBreakMinutes;
  int overtimeSeconds;
  // int undertimeInMinutes;
  // int undertimeBreakMinutes;

  LateMinutesModel({
    required this.lateInMinutes,
    required this.lateBreakMinutes,
    required this.overtimeSeconds,
    // required this.undertimeInMinutes,
    // required this.undertimeBreakMinutes,
  });
}
