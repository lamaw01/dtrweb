import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/user_model.dart';

class HttpService {
  static const String serverUrl = 'http://103.62.153.74:53000/dtr_history_api';

  static Future<List<HistoryModel>> getRecords({
    required String employeeId,
    required String dateFrom,
    required String dateTo,
  }) async {
    var response = await http
        .post(
          Uri.parse('$serverUrl/get_history.php'),
          headers: <String, String>{
            'Accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(
            <String, dynamic>{
              'employee_id': employeeId,
              'date_from': dateFrom,
              'date_to': dateTo,
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    debugPrint('getRecords ${response.body}');
    return historyModelFromJson(response.body);
  }

  static Future<List<HistoryModel>> getRecordsAll(
      {required String dateFrom, required String dateTo}) async {
    var response = await http
        .post(
          Uri.parse('$serverUrl/get_history_all.php'),
          headers: <String, String>{
            'Accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(
            <String, dynamic>{
              'date_from': dateFrom,
              'date_to': dateTo,
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    debugPrint('getRecordsAll ${response.body}');
    return historyModelFromJson(response.body);
  }
}
