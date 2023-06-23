import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/user_model.dart';
import '../services/http_service.dart';

class HomeData with ChangeNotifier {
  var _historyList = <HistoryModel>[];
  List<HistoryModel> get historyList => _historyList;

  var _uiList = <HistoryModel>[];
  List<HistoryModel> get uiList => _uiList;

  DateTime selectedFrom = DateTime.now();
  DateTime selectedTo = DateTime.now();

  final _isLogging = ValueNotifier(false);
  ValueNotifier<bool> get isLogging => _isLogging;

  final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  void changeLoadingState(bool state) {
    _isLogging.value = state;
  }

  void exportExcel({String? employeeId}) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    var cellStyle = CellStyle(
      backgroundColorHex: '#dddddd',
      fontFamily: getFontFamily(FontFamily.Arial),
      horizontalAlign: HorizontalAlign.Center,
    );

    var column1 = sheetObject.cell(CellIndex.indexByString('A1'));
    column1
      ..value = 'Employee ID'
      ..cellStyle = cellStyle;

    var column2 = sheetObject.cell(CellIndex.indexByString('B1'));
    column2
      ..value = 'Name'
      ..cellStyle = cellStyle;

    var column3 = sheetObject.cell(CellIndex.indexByString('C1'));
    column3
      ..value = 'Log'
      ..cellStyle = cellStyle;

    var column4 = sheetObject.cell(CellIndex.indexByString('D1'));
    column4
      ..value = 'Date Time'
      ..cellStyle = cellStyle;

    for (int i = 0; i < _historyList.length; i++) {
      for (int j = 0; j < _historyList[i].logs.length; j++) {
        List<String> dataList = [
          _historyList[i].employeeId,
          _historyList[i].name,
          _historyList[i].logs[j].logType,
          dateFormat.format(_historyList[i].logs[j].timeStamp)
        ];
        sheetObject.appendRow(dataList);
      }
    }
    excel.save(
        fileName: 'DTR ${DateFormat().add_yMMMMd().format(selectedTo)}.xlsx');
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
    debugPrint(_historyList
        .getRange(_uiList.length, _historyList.length)
        .length
        .toString());
  }

  Future<void> getRecords({required String employeeId}) async {
    var newselectedFrom = selectedFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = selectedTo.copyWith(hour: 23, minute: 59, second: 59);
    try {
      var result = await HttpService.getRecords(
        employeeId: employeeId,
        dateFrom: dateFormat.format(newselectedFrom),
        dateTo: dateFormat.format(newselectedTo),
      );
      setData(result);
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> getRecordsAll() async {
    var newselectedFrom = selectedFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = selectedTo.copyWith(hour: 23, minute: 59, second: 59);

    try {
      debugPrint(newselectedFrom.toString());
      debugPrint(newselectedTo.toString());
      var result = await HttpService.getRecordsAll(
        dateFrom: dateFormat.format(newselectedFrom),
        dateTo: dateFormat.format(newselectedTo),
      );
      setData(result);
    } catch (e) {
      debugPrint('$e');
    }
  }
}
