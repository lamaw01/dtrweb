import 'dart:developer';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert' show utf8;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show AnchorElement;

import '../model/department_model.dart';
import '../model/history_model.dart';
import '../model/log_model.dart';
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
  final _dateYmd = DateFormat('yyyy-MM-dd');
  final _dateExf = DateFormat('yyyyMMddHH:mm:ss');
  final _is24HourFormat = ValueNotifier(false);
  ValueNotifier<bool> get is24HourFormat => _is24HourFormat;

  void changeLoadingState(bool state) {
    _isLoading.value = state;
  }

  bool isSoloUser() {
    if (_uiList.isEmpty) {
      return false;
    }
    // HistoryModel firstIndexUser = _uiList.first;
    // for (HistoryModel data in _uiList) {
    //   if (firstIndexUser.employeeId != data.employeeId) {
    //     return false;
    //   }
    // }
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

  String fullNameHistory(HistoryModel h) {
    return '${h.lastName}, ${h.firstName} ${h.middleName}';
  }

  String dateFormat12or24Web(DateTime dateTime) {
    if (_is24HourFormat.value) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('hh:mm aa').format(dateTime);
    }
  }

  void exportRawLogsExcel() {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      var cellStyle = CellStyle(
        backgroundColorHex: '#dddddd',
        fontFamily: getFontFamily(FontFamily.Calibri),
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 9,
      );
      var column1 = sheetObject.cell(CellIndex.indexByString('A1'));
      column1
        ..value = 'Emp ID'
        ..cellStyle = cellStyle;

      var column2 = sheetObject.cell(CellIndex.indexByString('B1'));
      column2
        ..value = 'Name'
        ..cellStyle = cellStyle;

      var column3 = sheetObject.cell(CellIndex.indexByString('C1'));
      column3
        ..value = 'Date'
        ..cellStyle = cellStyle;

      var column4 = sheetObject.cell(CellIndex.indexByString('D1'));
      column4
        ..value = 'Time'
        ..cellStyle = cellStyle;

      var column5 = sheetObject.cell(CellIndex.indexByString('E1'));
      column5
        ..value = 'Log type'
        ..cellStyle = cellStyle;

      var cellStyleData = CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 9,
      );
      var rC = 0;

      var sortedRawHistory = <HistoryModel>[];
      sortedRawHistory.addAll(_historyList);
      sortedRawHistory.sort((a, b) {
        var valueA = '${a.employeeId.toLowerCase()} ${a.date}';
        var valueB = '${b.employeeId.toLowerCase()} ${b.date}';
        return valueA.compareTo(valueB);
      });

      for (int i = 0; i < sortedRawHistory.length; i++) {
        for (int j = 0; j < sortedRawHistory[i].logs.length; j++) {
          rC = rC + 1;
          List<dynamic> dataList = [
            sortedRawHistory[i].employeeId,
            fullNameHistory(sortedRawHistory[i]),
            _dateYmd.format(sortedRawHistory[i].date),
            dateFormat12or24Web(sortedRawHistory[i].logs[j].timeStamp),
            sortedRawHistory[i].logs[j].logType,
          ];
          sheetObject.appendRow(dataList);
          sheetObject.setColWidth(0, 7.0);
          sheetObject.setColWidth(1, 22.0);
          sheetObject.setColWidth(2, 10.0);
          sheetObject.setColWidth(3, 10.1);
          sheetObject.setColWidth(4, 8.1);
          sheetObject.updateCell(
            CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: rC,
            ),
            sortedRawHistory[i].employeeId,
            cellStyle: cellStyleData,
          );
          sheetObject.updateCell(
            CellIndex.indexByColumnRow(
              columnIndex: 1,
              rowIndex: rC,
            ),
            fullNameHistory(sortedRawHistory[i]),
            cellStyle: cellStyleData,
          );
          sheetObject.updateCell(
            CellIndex.indexByColumnRow(
              columnIndex: 2,
              rowIndex: rC,
            ),
            _dateYmd.format(sortedRawHistory[i].date),
            cellStyle: cellStyleData,
          );
          sheetObject.updateCell(
            CellIndex.indexByColumnRow(
              columnIndex: 3,
              rowIndex: rC,
            ),
            dateFormat12or24Web(sortedRawHistory[i].logs[j].timeStamp),
            cellStyle: cellStyleData,
          );
          sheetObject.updateCell(
            CellIndex.indexByColumnRow(
              columnIndex: 4,
              rowIndex: rC,
            ),
            sortedRawHistory[i].logs[j].logType,
            cellStyle: cellStyleData,
          );
        }
      }
      excel.save(fileName: 'DTR-raw.xlsx');
    } catch (e) {
      debugPrint('$e exportRawLogsExcel');
    }
  }

  void saveTextFile() {
    String data = '';
    const String space = '            ';
    String newLine = '\n';
    const String filename = 'TESTEXF.exf';

    _historyList.sort((a, b) {
      var valueA = '${a.employeeId} ${a.date}';
      var valueB = '${b.employeeId} ${b.date}';
      return valueA.compareTo(valueB);
    });

    int counter = 0;

    for (int i = 0; i < _historyList.length; i++) {
      for (int j = 0; j < _historyList[i].logs.length; j++) {
        counter++;
        data = data +
            _historyList[i].employeeId +
            logValue(_historyList[i].logs[j]).toString() +
            _dateExf.format(_historyList[i].logs[j].timeStamp) +
            space;
        int modulo = counter % 6;
        int value = logValue(_historyList[i].logs[j]);
        log('counter $counter modulo $modulo value $value');
        if (modulo == 0) {
          data = data + newLine;
        }
      }
    }

    // const String garbleStart =
    //     '♥↨♂←î☺  ¢ "                     EMP_NO bìbIC♂↑  ► ☺ ☺ ♫möb!"Y☺ IO _NO bìbIC♂↑  ☺ ☺ ☺ ♫möb!"Y☺ DDATE  bìbID♂↑  ◘ ☺ ☺ ♫möb!"Y☺ TTIME  bìbIC♂↑  ◘ ☺ ☺ ♫möb!"Y☺ \n             ';
    // const String garbleEnd = '→';

    final String decodedGarbleStart = decode(
        '00000011 00010111 00001011 00011011 11101111 10111111 10111101 00000001 00000000 00000000 11101111 10111111 10111101 00000000 00100010 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 01000101 01001101 01010000 01011111 01001110 01001111 00000000 01100010 11101111 10111111 10111101 01100010 01001001 01000011 00001011 00011000 00000000 00000000 00010000 00000000 00000001 00000000 00000001 00000000 00001110 01101101 11101111 10111111 10111101 01100010 11101111 10111111 10111101 00100001 00100010 01011001 00000001 00000000 01001001 01001111 00000000 01011111 01001110 01001111 00000000 01100010 11101111 10111111 10111101 01100010 01001001 01000011 00001011 00011000 00000000 00000000 00000001 00000000 00000001 00000000 00000001 00000000 00001110 01101101 11101111 10111111 10111101 01100010 11101111 10111111 10111101 00100001 00100010 01011001 00000001 00000000 01000100 01000100 01000001 01010100 01000101 00000000 00000000 01100010 11101111 10111111 10111101 01100010 01001001 01000100 00001011 00011000 00000000 00000000 00001000 00000000 00000001 00000000 00000001 00000000 00001110 01101101 11101111 10111111 10111101 01100010 11101111 10111111 10111101 00100001 00100010 01011001 00000001 00000000 01010100 01010100 01001001 01001101 01000101 00000000 00000000 01100010 11101111 10111111 10111101 01100010 01001001 01000011 00001011 00011000 00000000 00000000 00001000 00000000 00000001 00000000 00000001 00000000 00001110 01101101 11101111 10111111 10111101 01100010 11101111 10111111 10111101 00100001 00100010 01011001 00000001 00000000 00001010 00000000 00100000 00100000 00100000 00100000 00100000 00100000 00100000 00100000 00100000 00100000 00100000 00100000');

    final String decodedGarbleEnd = decode('00011010');

    AnchorElement()
      ..href =
          '${Uri.dataFromString('$decodedGarbleStart${data.trim()}$decodedGarbleEnd', mimeType: 'text/plain', encoding: utf8)}'
      ..download = filename
      ..style.display = 'none'
      ..click();
  }

  String encode(String value) {
    // Map each code unit from the given value to a base-2 representation of this
    // code unit, adding zeroes to the left until the string has length 8, and join
    // each code unit representation to a single string using spaces
    return value.codeUnits
        .map((v) => v.toRadixString(2).padLeft(8, '0'))
        .join(" ");
  }

  String decode(String value) {
    // Split the given value on spaces, parse each base-2 representation string to
    // an integer and return a new string from the corresponding code units
    return String.fromCharCodes(
        value.split(" ").map((v) => int.parse(v, radix: 2)));
  }

  int logValue(Log logval) {
    // log('hour ${logval.timeStamp.hour} ${logval.timeStamp}');
    switch (logval.timeStamp.hour) {
      case 0:
        return logval.logType == 'IN' ? 1 : 2;
      case 1:
        return logval.logType == 'IN' ? 1 : 2;
      case 2:
        return logval.logType == 'IN' ? 1 : 2;
      case 3:
        return logval.logType == 'IN' ? 1 : 2;
      case 4:
        return logval.logType == 'IN' ? 1 : 2;
      case 5:
        return logval.logType == 'IN' ? 1 : 2;
      case 6:
        return logval.logType == 'IN' ? 1 : 2;
      case 7:
        return logval.logType == 'IN' ? 1 : 2;
      case 8:
        return logval.logType == 'IN' ? 1 : 2;
      case 9:
        return logval.logType == 'IN' ? 1 : 2;
      case 10:
        return logval.logType == 'IN' ? 1 : 2;
      case 11:
        return logval.logType == 'IN' ? 1 : 2;
      case 12:
        return logval.logType == 'IN' ? 3 : 4;
      case 13:
        return logval.logType == 'IN' ? 3 : 4;
      case 14:
        return logval.logType == 'IN' ? 3 : 4;
      case 15:
        return logval.logType == 'IN' ? 3 : 4;
      case 16:
        return logval.logType == 'IN' ? 3 : 4;
      case 17:
        return logval.logType == 'IN' ? 3 : 4;
      case 18:
        return logval.logType == 'IN' ? 3 : 4;
      case 19:
        return logval.logType == 'IN' ? 3 : 4;
      case 20:
        return logval.logType == 'IN' ? 3 : 4;
      case 21:
        return logval.logType == 'IN' ? 3 : 4;
      case 22:
        return logval.logType == 'IN' ? 3 : 4;
      case 23:
        return logval.logType == 'IN' ? 3 : 4;
      default:
        return 1;
    }
  }

  void testTime() {
    String date1 = '2024-01-02 00:01:01';
    final parsedDate1 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date1);

    String date2 = '2024-01-02 23:00:01';
    final parsedDate2 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date2);

    String date3 = '2024-01-02 01:01:01';
    final parsedDate3 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date3);

    String date4 = '2024-01-02 12:01:01';
    final parsedDate4 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date4);
    log('1 $parsedDate1 2 $parsedDate2 3 $parsedDate3 4 $parsedDate4');

    log('1 ${parsedDate1.hour} 2 ${parsedDate2.hour} 3 ${parsedDate3.hour} 4 ${parsedDate4.hour}');
  }
}
