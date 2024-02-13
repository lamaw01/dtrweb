// To parse this JSON data, do
//
//     final settingsModel = settingsModelFromJson(jsonString);

import 'dart:convert';

SettingsModel settingsModelFromJson(String str) =>
    SettingsModel.fromJson(json.decode(str));

String settingsModelToJson(SettingsModel data) => json.encode(data.toJson());

class SettingsModel {
  int lateThreshold;

  SettingsModel({
    required this.lateThreshold,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        lateThreshold: json["late_threshold"],
      );

  Map<String, dynamic> toJson() => {
        "late_threshold": lateThreshold,
      };
}
