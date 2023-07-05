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

  void exportExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    var cellStyle = CellStyle(
      backgroundColorHex: '#dddddd',
      fontFamily: getFontFamily(FontFamily.Arial),
      horizontalAlign: HorizontalAlign.Center,
    );

    var column1 = sheetObject.cell(CellIndex.indexByString('A1'));
    column1
      ..value = ''
      ..cellStyle = cellStyle;

    var column2 = sheetObject.cell(CellIndex.indexByString('B1'));
    column2
      ..value = 'Emp ID'
      ..cellStyle = cellStyle;

    var column3 = sheetObject.cell(CellIndex.indexByString('C1'));
    column3
      ..value = 'Name'
      ..cellStyle = cellStyle;

    var column4 = sheetObject.cell(CellIndex.indexByString('D1'));
    column4
      ..value = 'Date In'
      ..cellStyle = cellStyle;

    var column5 = sheetObject.cell(CellIndex.indexByString('E1'));
    column5
      ..value = 'Date Out'
      ..cellStyle = cellStyle;

    var column6 = sheetObject.cell(CellIndex.indexByString('F1'));
    column6
      ..value = 'Time Logs'
      ..cellStyle = cellStyle;

    var column7 = sheetObject.cell(CellIndex.indexByString('G1'));
    column7
      ..value = 'Duration(Hours)'
      ..cellStyle = cellStyle;

    var column8 = sheetObject.cell(CellIndex.indexByString('H1'));
    column8
      ..value = 'Undertime'
      ..cellStyle = cellStyle;

    var column9 = sheetObject.cell(CellIndex.indexByString('I1'));
    column9
      ..value = 'Tardy'
      ..cellStyle = cellStyle;

    var column10 = sheetObject.cell(CellIndex.indexByString('J1'));
    column10
      ..value = 'Overtime'
      ..cellStyle = cellStyle;

    sheetObject.setColWidth(5, 100);

    _historyList.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    var rowCountUser = 0;
    final dateFormatExcel = DateFormat('hh:mm:ss aa');
    final dateFormatInOut = DateFormat('yyyy-MM-dd');

    for (int i = 0; i < _historyList.length; i++) {
      rowCountUser = rowCountUser + 1;
      var dateOut = '';
      var duration = 0;
      if (i > 0) {
        if (_historyList[i].name != _historyList[i - 1].name) {
          rowCountUser = 1;
          List<dynamic> emptyRow = [
            '',
            '',
            '',
            '',
            '',
            '',
            '',
          ];
          sheetObject.appendRow(emptyRow);
        }
      }

      if (_historyList[i].logs.last.logType == 'IN') {
        // if last log is in, then date out is tommorrow
        debugPrint('$i ${_historyList.length - 1}');
        if (i < _historyList.length - 1 &&
            _historyList[i].name == _historyList[i + 1].name) {
          dateOut = dateFormatInOut.format(_historyList[i + 1].date);
          debugPrint(_historyList[i].name);
          duration = calcDurationInOutOtherDay(
              _historyList[i].logs, _historyList[i + 1].logs);
        }
      }
      // if last log is in and last user log, empty date out
      else if (_historyList[i].logs.last.logType == 'IN' &&
          _historyList[i].name != _historyList[i + 1].name) {
        dateOut = '';
        debugPrint(_historyList[i].name);
        duration = calcDurationInOutSameDay(_historyList[i].logs);
      }
      // if date is out, then date in and out same
      else {
        dateOut = dateFormatInOut.format(_historyList[i].date);
        debugPrint(_historyList[i].name);
        duration = calcDurationInOutSameDay(_historyList[i].logs);
      }

      var logsString = '';
      for (var log in _historyList[i].logs) {
        logsString =
            '$logsString - ${log.logType} ${dateFormatExcel.format(log.timeStamp)}';
      }

      List<dynamic> dataList = [
        rowCountUser,
        _historyList[i].employeeId,
        _historyList[i].name,
        dateFormatInOut.format(_historyList[i].date),
        dateOut,
        logsString.substring(2),
        duration,
      ];
      sheetObject.appendRow(dataList);
    }

    excel.save(
        fileName: 'DTR ${DateFormat().add_yMMMMd().format(selectedTo)}.xlsx');
  }

  int calcDurationInOutOtherDay(List<Log> logs1, List<Log> logs2) {
    debugPrint('logs1 ${logs1.length} logs1 ${logs2.length}');
    var seconds = 0;
    try {
      if (logs1.last.logType == 'IN') {
        seconds = seconds +
            logs2.first.timeStamp.difference(logs1.last.timeStamp).inSeconds;
        debugPrint(
            'calcDurationInOutOtherDay if ${logs2.first.timeStamp.difference(logs1.last.timeStamp).inHours}');
      }

      for (int i = 0; i < logs1.length; i++) {
        if (logs1[i].logType == 'IN' && logs1[i + 1].logType == 'OUT') {
          seconds = seconds +
              logs1[i + 1].timeStamp.difference(logs1[i].timeStamp).inSeconds;
          debugPrint(
              'calcDurationInOutOtherDay loop ${logs1[i + 1].timeStamp.difference(logs1[i].timeStamp).inHours}');
        }
      }
    } catch (e) {
      debugPrint('calcDurationInOutOtherDay $e');
    }

    debugPrint('seconds $seconds');
    var hours = Duration(seconds: seconds).inHours;
    debugPrint('hours $hours');
    return hours;
  }

  int calcDurationInOutSameDay(List<Log> logs) {
    var seconds = 0;
    try {
      for (int i = 0; i < logs.length; i++) {
        if (logs[i].logType == 'IN' && logs[i + 1].logType == 'OUT') {
          seconds = seconds +
              logs[i + 1].timeStamp.difference(logs[i].timeStamp).inSeconds;
          debugPrint(
              'calcDurationInOutSameDay ${logs[i + 1].timeStamp.difference(logs[i].timeStamp).inHours}');
        }
      }
    } catch (e) {
      debugPrint('calcDurationInOutSameDay $e');
    }

    debugPrint('seconds $seconds');
    var hours = Duration(seconds: seconds).inHours;
    debugPrint('hours $hours');
    return hours;
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
