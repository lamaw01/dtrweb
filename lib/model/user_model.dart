// To parse this JSON data, do
//
//     final historyModel = historyModelFromJson(jsonString);

import 'dart:convert';

List<HistoryModel> historyModelFromJson(String str) => List<HistoryModel>.from(
    json.decode(str).map((x) => HistoryModel.fromJson(x)));

String historyModelToJson(List<HistoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HistoryModel {
  String employeeId;
  String name;
  DateTime date;
  List<ImageId> image;
  List<Log> logs;

  HistoryModel({
    required this.employeeId,
    required this.name,
    required this.date,
    required this.image,
    required this.logs,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        employeeId: json["employee_id"],
        name: json["name"],
        date: DateTime.parse(json["date"]),
        image:
            List<ImageId>.from(json["image"].map((x) => ImageId.fromJson(x))),
        logs: List<Log>.from(json["logs"].map((x) => Log.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "employee_id": employeeId,
        "name": name,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "image": List<dynamic>.from(image.map((x) => x.toJson())),
        "logs": List<dynamic>.from(logs.map((x) => x.toJson())),
      };
}

class ImageId {
  String id;
  DateTime selfieTimestamp;

  ImageId({
    required this.id,
    required this.selfieTimestamp,
  });

  factory ImageId.fromJson(Map<String, dynamic> json) => ImageId(
        id: json["id"],
        selfieTimestamp: DateTime.parse(json["selfie_timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "selfie_timestamp": selfieTimestamp.toIso8601String(),
      };
}

class Log {
  DateTime timeStamp;
  String logType;

  Log({
    required this.timeStamp,
    required this.logType,
  });

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        timeStamp: DateTime.parse(json["time_stamp"]),
        logType: json["log_type"],
      );

  Map<String, dynamic> toJson() => {
        "time_stamp": timeStamp.toIso8601String(),
        "log_type": logType,
      };
}
