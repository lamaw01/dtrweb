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
  List<String> array;
  List<Log> logs;

  HistoryModel({
    required this.employeeId,
    required this.name,
    required this.date,
    required this.array,
    required this.logs,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        employeeId: json["employee_id"],
        name: json["name"],
        array: [],
        date: DateTime.parse(json["date"]),
        logs: List<Log>.from(json["logs"].map((x) => Log.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "employee_id": employeeId,
        "name": name,
        "array": array,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "logs": List<dynamic>.from(logs.map((x) => x.toJson())),
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
