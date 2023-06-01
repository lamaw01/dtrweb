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
    try {
      final result = await HttpService.getRecords(
        employeeId: employeeId,
        dateFrom: DateFormat('yyyy-MM-dd').format(selectedFrom),
        dateTo: DateFormat('yyyy-MM-dd').format(selectedTo),
      );
      _historyList = result;
    } catch (e) {
      debugPrint('$e');
    } finally {
      _rowCount = await HttpService.getRecordsCount(
        employeeId: employeeId,
        dateFrom: DateFormat('yyyy-MM-dd').format(selectedFrom),
        dateTo: DateFormat('yyyy-MM-dd').format(selectedTo),
      );
      notifyListeners();
    }
  }

  Future<void> loadMoreRecords({
    required String employeeId,
    required DateTime dateFrom,
    required String dateTo,
  }) async {
    try {
      final result = await HttpService.getRecords(
        employeeId: employeeId,
        dateFrom: DateFormat('yyyy-MM-dd').format(dateFrom),
        dateTo: DateFormat('yyyy-MM-dd').format(selectedTo),
      );
      _historyList.addAll(result.skip(1));
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }

  // Future<void> getRecordsCount({
  //   required String employeeId,
  //   required DateTime dateFrom,
  //   required String dateTo,
  // }) async {
  //   try {
  //     await HttpService.getRecords(
  //       employeeId: employeeId,
  //       dateFrom: DateFormat('yyyy-MM-dd').format(selectedFrom),
  //       dateTo: DateFormat('yyyy-MM-dd').format(selectedTo),
  //     );
  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint('$e');
  //   }
  // }
}
