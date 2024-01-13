import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/department_model.dart';
import '../model/history_model.dart';
import '../services/http_service.dart';

class HistoryProvider with ChangeNotifier {
  var _historyList = <HistoryModel>[];
  List<HistoryModel> get historyList => _historyList;

  var _uiList = <HistoryModel>[];
  List<HistoryModel> get uiList => _uiList;

  final _isLoading = ValueNotifier(false);
  ValueNotifier<bool> get isLoading => _isLoading;

  DateTime selectedFrom = DateTime.now();
  DateTime selectedTo = DateTime.now();
  final _dateFormat1 = DateFormat('yyyy-MM-dd HH:mm');
  final _is24HourFormat = ValueNotifier(false);
  ValueNotifier<bool> get is24HourFormat => _is24HourFormat;

  void changeLoadingState(bool state) {
    _isLoading.value = state;
  }

  bool isSoloUser() {
    if (_uiList.isEmpty) {
      return false;
    }
    HistoryModel firstIndexUser = _uiList.first;
    for (HistoryModel data in _uiList) {
      if (firstIndexUser.employeeId != data.employeeId) {
        return false;
      }
    }
    return true;
  }

  // get initial data for history and put 30 it ui
  void setData(List<HistoryModel> data) {
    _historyList = data;
    if (_historyList.length > 30) {
      _uiList = _historyList.getRange(0, 30).toList();
    } else {
      _uiList = _historyList;
    }
    notifyListeners();
  }

  void loadMore() {
    if (_historyList.length - _uiList.length < 30) {
      _uiList.addAll(
          _historyList.getRange(_uiList.length, _historyList.length).toList());
    } else {
      _uiList.addAll(
          _historyList.getRange(_uiList.length, _uiList.length + 30).toList());
    }
    notifyListeners();
  }

  Future<void> getRecords({
    required String employeeId,
    required DepartmentModel department,
  }) async {
    var newselectedFrom = selectedFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = selectedTo.copyWith(hour: 23, minute: 59, second: 59);
    try {
      var result = await HttpService.getRecords(
        employeeId: employeeId,
        dateFrom: _dateFormat1.format(newselectedFrom),
        dateTo: _dateFormat1.format(newselectedTo),
        department: department,
      );
      setData(result);
    } catch (e) {
      debugPrint('$e getRecords');
    }
  }

  Future<void> getRecordsAll({required DepartmentModel department}) async {
    var newselectedFrom = selectedFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = selectedTo.copyWith(hour: 23, minute: 59, second: 59);

    try {
      var result = await HttpService.getRecordsAll(
        dateFrom: _dateFormat1.format(newselectedFrom),
        dateTo: _dateFormat1.format(newselectedTo),
        department: department,
      );
      setData(result);
    } catch (e) {
      debugPrint('$e getRecordsAll');
    }
  }
}
