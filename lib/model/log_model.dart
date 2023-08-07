class Log {
  DateTime timeStamp;
  String logType;
  String id;
  String isSelfie;

  Log({
    required this.timeStamp,
    required this.logType,
    required this.id,
    required this.isSelfie,
  });

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        timeStamp: DateTime.parse(json["time_stamp"]),
        logType: json["log_type"].toString(),
        id: json["id"].toString(),
        isSelfie: json["is_selfie"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "time_stamp": timeStamp.toIso8601String(),
        "log_type": logType,
        "id": id,
        "is_selfie": isSelfie,
      };
}
