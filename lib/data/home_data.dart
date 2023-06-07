import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/user_model.dart';
import '../services/http_service.dart';

class HomeData with ChangeNotifier {
  var _historyList = <HistoryModel>[];
  List<HistoryModel> get historyList => _historyList;
  DateTime selectedFrom = DateTime.now();
  DateTime selectedTo = DateTime.now();
  var _rowCount = 0;
  int get rowCount => _rowCount;

  Future<void> getRecords({
    required String employeeId,
  }) async {
    var newselectedFrom = selectedFrom.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    var newselectedTo = selectedTo.copyWith(
        hour: 23, minute: 59, second: 59, millisecond: 0, microsecond: 0);
    debugPrint(DateFormat('yyyy-MM-dd hh:mm:ss').format(newselectedFrom));
    debugPrint(DateFormat('yyyy-MM-dd hh:mm:ss').format(newselectedTo));
    try {
      final result = await HttpService.getRecords(
        employeeId: employeeId,
        dateFrom: DateFormat('yyyy-MM-dd hh:mm:ss').format(newselectedFrom),
        dateTo: DateFormat('yyyy-MM-dd hh:mm:ss').format(newselectedTo),
      );

      _historyList = result;
    } catch (e) {
      debugPrint('$e');
    } finally {
      _rowCount = await HttpService.getRecordsCount(
        employeeId: employeeId,
        dateFrom: DateFormat('yyyy-MM-dd hh:mm:ss').format(newselectedFrom),
        dateTo: DateFormat('yyyy-MM-dd hh:mm:ss').format(newselectedTo),
      );
      notifyListeners();
    }
  }

  Future<void> loadMoreRecords({
    required String employeeId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    var newselectedFrom = selectedFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = selectedTo.copyWith(hour: 23, minute: 59, second: 59);
    try {
      final result = await HttpService.getRecords(
        employeeId: employeeId,
        dateFrom: DateFormat('yyyy-MM-dd hh:mm:ss').format(newselectedFrom),
        dateTo: DateFormat('yyyy-MM-dd hh:mm:ss').format(newselectedTo),
      );
      _historyList.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }
}
