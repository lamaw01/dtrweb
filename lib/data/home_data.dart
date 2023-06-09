import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../model/user_model.dart';
import '../services/http_service.dart';

class HomeData with ChangeNotifier {
  var _historyList = <HistoryModel>[];
  List<HistoryModel> get historyList => _historyList;
  DateTime selectedFrom = DateTime.now();
  DateTime selectedTo = DateTime.now();
  var _rowCount = 0;
  int get rowCount => _rowCount;
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  void exportExcel() {
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
      ..value = 'Date Time'
      ..cellStyle = cellStyle;

    for (int i = 0; i < _historyList.length; i++) {
      for (int j = 0; j < _historyList[i].logs.length; j++) {
        // kRow++;
        List<String> dataList = [
          historyList[i].employeeId,
          _historyList[i].name,
          dateFormat.format(_historyList[i].logs[j].timeStamp)
        ];
        sheetObject.appendRow(dataList);
      }
    }
    excel.save(
        fileName: 'DTR ${DateFormat().add_yMMMMd().format(selectedTo)}.xlsx');
  }

  int getLowestId(List<Log> logs) {
    var listOfId = <int>[];
    for (var log in logs) {
      listOfId.add(log.id);
    }
    debugPrint(listOfId.reduce(min).toString());
    return listOfId.reduce(min);
  }

  Future<void> getRecords({
    required String employeeId,
  }) async {
    var newselectedFrom = selectedFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = selectedTo.copyWith(hour: 23, minute: 59, second: 59);
    try {
      final result = await HttpService.getRecords(
        employeeId: employeeId,
        dateFrom: dateFormat.format(newselectedFrom),
        dateTo: dateFormat.format(newselectedTo),
      );

      _historyList = result;
    } catch (e) {
      debugPrint('$e');
    } finally {
      _rowCount = await HttpService.getRecordsCount(
        employeeId: employeeId,
        dateFrom: dateFormat.format(newselectedFrom),
        dateTo: dateFormat.format(newselectedTo),
      );
      notifyListeners();
    }
  }

  Future<void> loadMore({
    required String employeeId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    var newselectedFrom = dateFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = dateTo
        .copyWith(hour: 23, minute: 59, second: 59)
        .subtract(const Duration(days: 1));
    try {
      final result = await HttpService.loadMore(
        employeeId: employeeId,
        dateFrom: dateFormat.format(newselectedFrom),
        dateTo: dateFormat.format(newselectedTo),
      );
      _historyList.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> getRecordsAll() async {
    var newselectedFrom = selectedFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = selectedTo.copyWith(hour: 23, minute: 59, second: 59);
    try {
      final result = await HttpService.getRecordsAll(
        dateFrom: dateFormat.format(newselectedFrom),
        dateTo: dateFormat.format(newselectedTo),
      );

      _historyList = result;
    } catch (e) {
      debugPrint('$e');
    } finally {
      _rowCount = await HttpService.getRecordsCountAll(
        dateFrom: dateFormat.format(newselectedFrom),
        dateTo: dateFormat.format(newselectedTo),
      );
      notifyListeners();
    }
  }

  Future<void> loadMoreAll({
    required int id,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    var newselectedFrom = dateFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = dateTo.copyWith(hour: 23, minute: 59, second: 59);
    try {
      final result = await HttpService.loadMoreAll(
        id: id.toString(),
        dateFrom: dateFormat.format(newselectedFrom),
        dateTo: dateFormat.format(newselectedTo),
      );
      _historyList.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }
}
