import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/department_model.dart';
import '../model/user_model.dart';
import '../services/http_service.dart';

class HomeData with ChangeNotifier {
  var _historyList = <HistoryModel>[];
  List<HistoryModel> get historyList => _historyList;

  var _uiList = <HistoryModel>[];
  List<HistoryModel> get uiList => _uiList;

  final _departmentList = <DepartmentModel>[];
  List<DepartmentModel> get departmentList => _departmentList;

  DateTime selectedFrom = DateTime.now();
  DateTime selectedTo = DateTime.now();

  final _isLogging = ValueNotifier(false);
  ValueNotifier<bool> get isLogging => _isLogging;

  final _is24HourFormat = ValueNotifier(false);
  ValueNotifier<bool> get is24HourFormat => _is24HourFormat;

  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final _dateFormatFileExcel = DateFormat().add_yMMMMd();

  String dateFormat12or24(DateTime dateTime) {
    if (_is24HourFormat.value) {
      return DateFormat('HH:mm:ss').format(dateTime);
    } else {
      return DateFormat('hh:mm:ss aa').format(dateTime);
    }
  }

  void changeTimeFormat(bool state) {
    _is24HourFormat.value = state;
    debugPrint(_is24HourFormat.value.toString());
  }

  void changeLoadingState(bool state) {
    _isLogging.value = state;
  }

  void exportExcel() async {
    try {
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
        ..value = 'Time In'
        ..cellStyle = cellStyle;

      var column6 = sheetObject.cell(CellIndex.indexByString('F1'));
      column6
        ..value = 'Date Out'
        ..cellStyle = cellStyle;

      var column7 = sheetObject.cell(CellIndex.indexByString('G1'));
      column7
        ..value = 'Time Out'
        ..cellStyle = cellStyle;

      var column8 = sheetObject.cell(CellIndex.indexByString('H1'));
      column8
        ..value = 'Duration(Hours)'
        ..cellStyle = cellStyle;

      var column9 = sheetObject.cell(CellIndex.indexByString('I1'));
      column9
        ..value = 'Undertime'
        ..cellStyle = cellStyle;

      var column10 = sheetObject.cell(CellIndex.indexByString('J1'));
      column10
        ..value = 'Tardy'
        ..cellStyle = cellStyle;

      var column11 = sheetObject.cell(CellIndex.indexByString('K1'));
      column11
        ..value = 'Overtime'
        ..cellStyle = cellStyle;

      sheetObject.setColWidth(2, 25);

      // sort list alphabetically and by date, very important
      _historyList.sort((a, b) {
        return ('${a.lastName.toLowerCase()} ${a.firstName.toLowerCase()} ${a.middleName.toLowerCase()}  ${a.date.toString()}')
            .compareTo(
                '${b.lastName.toLowerCase()} ${b.firstName.toLowerCase()} ${b.middleName.toLowerCase()}  ${b.date.toString()}');
      });

      var rowCountUser = 0;
      final dateFormatInOut = DateFormat('yyyy-MM-dd');

      for (int i = 0; i < _historyList.length; i++) {
        rowCountUser = rowCountUser + 1;
        var dateOut = '';
        var duration = 0;
        var timeLogs = <Log>[];

        if (i > 0) {
          //reset user logs count and add space
          if (nameIndex(i) != nameIndex(i - 1)) {
            rowCountUser = 1;
            List<dynamic> emptyRow = [
              '',
              '',
              '',
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

        // if logs is only 1 and is out remove
        if (_historyList[i].logs.length == 1 &&
            _historyList[i].logs.first.logType == 'OUT') {
          _historyList.removeAt(i);
        }

        timeLogs.add(_historyList[i].logs.first);

        if (_historyList[i].logs.last.logType == 'IN') {
          // if last log is in, then date out is tommorrow
          if (i + 1 < _historyList.length) {
            debugPrint(nameIndex(i));
            if (nameIndex(i) == nameIndex(i + 1)) {
              dateOut = dateFormatInOut.format(_historyList[i + 1].date);
              duration = calcDurationInOutOtherDay(
                  _historyList[i].logs, _historyList[i + 1].logs);
              // move first log other day to yesterday if out
              debugPrint(_historyList[i + 1].logs.first.timeStamp.toString());
              timeLogs.add(_historyList[i + 1].logs[0]);
              // if next log is out and is solo, remove
              if (_historyList[i + 1].logs.length > 1) {
                _historyList[i + 1].logs.removeAt(0);
              }
            } else {
              if (_historyList[i + 1].logs.first.logType == 'OUT') {
                historyList[i + 1].logs.removeAt(0);
              }
            }
          }
          // if last log is in and last index, do in out same day, otherwise dont calc duration
          else {
            dateOut = dateFormatInOut.format(_historyList[i].date);
            debugPrint(nameIndex(i));
            duration = calcDurationInOutSameDay(_historyList[i].logs);
            timeLogs.add(_historyList[i].logs.last);
          }
        }
        // if date is out, then date in and out same
        else {
          dateOut = dateFormatInOut.format(_historyList[i].date);
          debugPrint(nameIndex(i));
          duration = calcDurationInOutSameDay(_historyList[i].logs);
          timeLogs.add(_historyList[i].logs.last);
        }

        var timeIn = dateFormat12or24(timeLogs.first.timeStamp);
        var timeOut = dateFormat12or24(timeLogs.last.timeStamp);
        if (timeLogs.length == 1) timeOut = '';

        List<dynamic> dataList = [
          rowCountUser,
          _historyList[i].employeeId,
          '${_historyList[i].lastName} ${_historyList[i].firstName}, ${_historyList[i].middleName}',
          dateFormatInOut.format(_historyList[i].date),
          timeIn,
          dateOut,
          timeOut,
          duration,
        ];
        sheetObject.appendRow(dataList);
      }

      excel.save(
          fileName:
              'DTR ${_dateFormatFileExcel.format(selectedFrom)} - ${_dateFormatFileExcel.format(selectedTo)}.xlsx');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String nameIndex(int index) {
    final name =
        "${_historyList[index].firstName} ${historyList[index].middleName} ${_historyList[index].lastName}";
    return name;
  }

  // calculate duration in hours if log out is other day
  int calcDurationInOutOtherDay(List<Log> logs1, List<Log> logs2) {
    debugPrint('logs1 ${logs1.length} logs1 ${logs2.length}');
    var seconds = 0;
    try {
      if (logs1.last.logType == 'IN') {
        if (logs2.first.logType == 'IN') {
          for (int j = 0; j < logs2.length; j++) {
            if (logs2[j].logType == 'OUT') {
              seconds = seconds +
                  logs2[j].timeStamp.difference(logs1.last.timeStamp).inSeconds;
              debugPrint(
                  'other day 1st ${logs2[j].timeStamp.difference(logs1.last.timeStamp).inSeconds}');
              break;
            }
          }
        } else {
          seconds = seconds +
              logs2.first.timeStamp.difference(logs1.last.timeStamp).inSeconds;
          debugPrint(
              'other day 2nd ${logs2.first.timeStamp.difference(logs1.last.timeStamp).inHours}');
        }
      }
      for (int i = 0; i < logs1.length; i++) {
        if (i + 1 < logs1.length) {
          if (logs1[i].logType == 'IN' && logs1[i + 1].logType == 'OUT') {
            seconds = seconds +
                logs1[i + 1].timeStamp.difference(logs1[i].timeStamp).inSeconds;
            debugPrint(
                'other day loop ${logs1[i + 1].timeStamp.difference(logs1[i].timeStamp).inHours}');
          }
        }
      }
    } catch (e) {
      debugPrint('other error $e');
    }
    debugPrint('seconds $seconds');
    var hours = Duration(seconds: seconds).inHours;
    debugPrint('hours $hours');
    return hours;
  }

  // calculate duration in hours if in and out same day
  int calcDurationInOutSameDay(List<Log> logs) {
    var seconds = 0;
    try {
      for (int i = 0; i < logs.length; i++) {
        if (i + 1 < logs.length) {
          if (logs[i].logType == 'IN' && logs[i + 1].logType == 'OUT') {
            seconds = seconds +
                logs[i + 1].timeStamp.difference(logs[i].timeStamp).inSeconds;
            debugPrint(
                'same day ${logs[i + 1].timeStamp.difference(logs[i].timeStamp).inHours}');
          }
        }
      }
    } catch (e) {
      debugPrint('same day error $e');
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

  Future<void> getRecords({
    required String employeeId,
    required DepartmentModel department,
  }) async {
    var newselectedFrom = selectedFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = selectedTo.copyWith(hour: 23, minute: 59, second: 59);
    try {
      var result = await HttpService.getRecords(
        employeeId: employeeId,
        dateFrom: _dateFormat.format(newselectedFrom),
        dateTo: _dateFormat.format(newselectedTo),
        department: department,
      );
      setData(result);
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> getRecordsAll({required DepartmentModel department}) async {
    var newselectedFrom = selectedFrom.copyWith(hour: 0, minute: 0, second: 0);
    var newselectedTo = selectedTo.copyWith(hour: 23, minute: 59, second: 59);

    try {
      debugPrint(newselectedFrom.toString());
      debugPrint(newselectedTo.toString());
      var result = await HttpService.getRecordsAll(
        dateFrom: _dateFormat.format(newselectedFrom),
        dateTo: _dateFormat.format(newselectedTo),
        department: department,
      );
      setData(result);
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> getDepartment() async {
    try {
      final result = await HttpService.getDepartment();
      _departmentList.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }
}
