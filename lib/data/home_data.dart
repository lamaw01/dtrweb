import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../services/http_service.dart';

class HomeData with ChangeNotifier {
  var _historyList = <HistoryModel>[];
  List<HistoryModel> get historyList => _historyList;

  // insert device log to database
  Future<void> getRecords({required String employeeId}) async {
    try {
      final result = await HttpService.getRecords(employeeId: employeeId);
      _historyList = result;

      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }
}
