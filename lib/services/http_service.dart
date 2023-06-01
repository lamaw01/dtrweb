import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/user_model.dart';

class HttpService {
  static const String _serverUrl = 'http://uc-1.dnsalias.net:55083/dtrwebapi';

  static Future<List<HistoryModel>> getRecords({
    required String employeeId,
    required String dateFrom,
    required String dateTo,
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
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    debugPrint('getRecords ${response.body}');
    return historyModelFromJson(response.body);
  }

  static Future<int> getRecordsCount({
    required String employeeId,
    required String dateFrom,
    required String dateTo,
  }) async {
    var response = await http
        .post(
          Uri.parse('$_serverUrl/get_history_count.php'),
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
    debugPrint('getRecordsCount ${response.body}');
    return json.decode(response.body)['count'];
  }
}
