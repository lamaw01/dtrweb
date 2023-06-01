import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/user_model.dart';

class HttpService {
  static const String _serverUrl = 'http://uc-1.dnsalias.net:55083/dtrwebapi';

  static Future<List<HistoryModel>> getRecords({
    required String employeeId,
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
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    debugPrint('getRecords ${response.body}');
    return historyModelFromJson(response.body);
  }
}
