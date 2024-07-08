// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/department_model.dart';
import '../model/schedule_model.dart';
import '../model/history_model.dart';
import '../model/settings_model.dart';

class HttpService {
  static String currentUri = Uri.base.toString();
  static String isSecured = currentUri.substring(4, 5);

  static const String _serverUrlHttp = 'http://103.62.153.74:53000/';
  String get serverUrlHttp => _serverUrlHttp;

  static const String _serverUrlHttps = 'https://konek.parasat.tv:50443/dtr/';
  String get serverUrlHttps => _serverUrlHttps;

  static final String _url =
      isSecured == 's' ? _serverUrlHttps : _serverUrlHttp;

  static final String _serverUrl = '${_url}dtr_history_api';
  static String get serverUrl => _serverUrl;

  //http://103.62.153.74:53000/field_api/images/02222/20240116091536.jpg

  static Future<List<HistoryModel>> getRecords({
    required String employeeId,
    required String dateFrom,
    required String dateTo,
    required DepartmentModel department,
  }) async {
    var response = await http
        .post(
          Uri.parse('$_serverUrl/get_history.php'),
          headers: <String, String>{
            'Accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(
            <String, dynamic>{
              'employee_id': employeeId,
              'date_from': dateFrom,
              'date_to': dateTo,
              'department': department.departmentId,
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    // debugPrint('getRecords ${response.body}');
    return historyModelFromJson(response.body);
  }

  static Future<List<HistoryModel>> getRecordsAll({
    required String dateFrom,
    required String dateTo,
    required DepartmentModel department,
  }) async {
    var response = await http
        .post(
          Uri.parse('$_serverUrl/get_history_all.php'),
          headers: <String, String>{
            'Accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(
            <String, dynamic>{
              'date_from': dateFrom,
              'date_to': dateTo,
              'department': department.departmentId,
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    // debugPrint('getRecordsAll ${response.body}');
    return historyModelFromJson(response.body);
  }

  static Future<List<DepartmentModel>> getDepartment() async {
    var response = await http.get(
      Uri.parse('$_serverUrl/get_department.php'),
      headers: <String, String>{
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).timeout(const Duration(seconds: 10));
    // debugPrint('getDepartment ${response.body}');
    return departmentModelFromJson(response.body);
  }

  static Future<List<ScheduleModel>> geSchedule() async {
    var response = await http.get(
      Uri.parse('$_serverUrl/get_schedule.php'),
      headers: <String, String>{
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).timeout(const Duration(seconds: 10));
    // debugPrint('geSchedule ${response.body}');
    return scheduleModelFromJson(response.body);
  }

  static Future<SettingsModel> getSettings() async {
    var response = await http.get(
      Uri.parse('$_serverUrl/get_settings.php'),
      headers: <String, String>{
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).timeout(const Duration(seconds: 10));
    // debugPrint('getSettings ${response.body}');
    return settingsModelFromJson(response.body);
  }
}
