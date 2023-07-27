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
  String firstName;
  String lastName;
  String middleName;
  DateTime date;
  List<Log> logs;
  String schedCode;
  String schedIn;
  String breakStart;
  String breakEnd;
  String schedOut;

  HistoryModel({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.date,
    required this.logs,
    required this.schedCode,
    required this.schedIn,
    required this.breakStart,
    required this.breakEnd,
    required this.schedOut,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        employeeId: json["employee_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        middleName: json["middle_name"],
        date: DateTime.parse(json["date"]),
        logs: List<Log>.from(json["logs"].map((x) => Log.fromJson(x))),
        schedCode: json["sched_code"].toString(),
        schedIn: json["sched_in"].toString(),
        breakStart: json["break_start"].toString(),
        breakEnd: json["break_end"].toString(),
        schedOut: json["sched_out"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "employee_id": employeeId,
        "first_name": firstName,
        "last_name": lastName,
        "middle_name": middleName,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "logs": List<dynamic>.from(logs.map((x) => x.toJson())),
        "sched_code": schedCode,
        "sched_in": schedIn,
        "break_start": breakStart,
        "break_end": breakEnd,
        "sched_out": schedOut,
      };
}

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
