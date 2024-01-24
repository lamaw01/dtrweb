class Log {
  DateTime timeStamp;
  String logType;
  String id;
  String imagePath;
  String isSelfie;
  String latlng;

  Log({
    required this.timeStamp,
    required this.logType,
    required this.id,
    this.imagePath = '',
    required this.isSelfie,
    required this.latlng,
  });

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        timeStamp: DateTime.parse(json["time_stamp"]),
        logType: json["log_type"].toString(),
        id: json["id"].toString(),
        imagePath: json["image_path"].toString(),
        isSelfie: json["is_selfie"].toString(),
        latlng: json["latlng"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "time_stamp": timeStamp.toIso8601String(),
        "log_type": logType,
        "id": id,
        "image_path": imagePath,
        "is_selfie": isSelfie,
        "latlng": latlng,
      };
}

class TimeLog {
  String isSelfie;
  String timestamp;
  String id;

  TimeLog({
    this.isSelfie = '0',
    this.timestamp = '',
    this.id = '',
  });
}
