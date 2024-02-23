import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charset/charset.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show AnchorElement;

import '../model/department_model.dart';
import '../model/history_model.dart';
import '../model/log_model.dart';
import '../services/http_service.dart';
import '../view/home_view.dart';
import 'binary.dart';

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
    if (is24HourFormat.value) {
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
    const String filename = 'WIND1252.exf';

    _historyList.sort((a, b) {
      var valueA = '${a.employeeId} ${a.date}';
      var valueB = '${b.employeeId} ${b.date}';
      return valueA.compareTo(valueB);
    });

    // int counter = 0;

    for (int i = 0; i < _historyList.length; i++) {
      for (int j = 0; j < _historyList[i].logs.length; j++) {
        // counter++;
        data = data +
            _historyList[i].employeeId +
            logValue(_historyList[i].logs[j], _historyList[i].logs, j,
                    _historyList[i].currentSchedId)
                .toString() +
            _dateExf.format(_historyList[i].logs[j].timeStamp) +
            space;
        // int modulo = counter % 6;
        // int value = logValue(_historyList[i].logs[j]);
        // log('counter $counter modulo $modulo value $value');
        // if (modulo == 0) {
        //   data = data + newLine;
        // }
      }
    }

    final String decodedGarbleStart = decode(
        '$etx $can $stx $ff $poste $etx $nul2 $nul2 $c $nul2 $quote $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $nul2 $emp_no $nul2 $bibIC $stx $can $nul2 $nul2 $dle $nul2 $soh $nul2 $soh $nul2 $dc4 $moba $exclamation $em $y $soh $nul2 $io $nul2 $no $nul2 $bibIC $stx $can $nul2 $nul2 $soh $nul2 $soh $nul2 $soh $nul2 $dc4 $moba $exclamation $em $y $soh $nul2 $ddate $nul2 $nul2 $bibID $stx $can $nul2 $nul2 $bs $nul2 $soh $nul2 $soh $nul2 $dc4 $moba $exclamation $em $y $soh $nul2 $ttime $nul2 $nul2 $bibIC $stx $can $nul2 $nul2 $bs $nul2 $soh $nul2 $soh $nul2 $dc4 $moba $exclamation $em $y $soh $nul2');

    final String decodedGarbleNew = decode(
        '$nul2 $space1 $space1 $space1 $space1 $space1 $space1 $space1 $space1 $space1 $space1 $space1 $space1');

    final String decodedGarbleEnd = decode(sub);

    AnchorElement()
      ..href =
          '${Uri.dataFromString('$decodedGarbleStart$newLine$decodedGarbleNew${data.trim()}$decodedGarbleEnd', mimeType: 'text/plain', encoding: windows1252)}'
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

  //CURRENT LOLOY = 1434
  //CORRECT LOLOY = 1234
  //CURRENT KEVIN 3212
  //CORRECT KEVIN 3412
  //1 = MORNING IN
  //2 = MORNING OUT
  //3 = AFTERNOON IN
  //4 = AFTERNOON OUT
  int logValue(Log logval, List<Log> logs, int index, String schedId) {
    final String schedFirstChar = schedId.substring(0, 1);
    switch (logval.timeStamp.hour) {
      case 0:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 1:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 2:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 3:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 4:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 5:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 6:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 7:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 8:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 9:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 10:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
      case 11:
        if (index == 0 && logs.length >= 3 && schedFirstChar == 'E') {
          return 4;
        }
        return logval.logType == 'IN' ? 1 : 2;
/////////////////////////////////////////////////////
      case 12:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 13:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 14:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 15:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 16:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 17:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 18:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 19:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 20:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 21:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 22:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      case 23:
        if (index == 1 && logs.length >= 4) {
          return 2;
        }
        return logval.logType == 'IN' ? 3 : 4;
      default:
        return 1;
    }
  }

  // void testTime() {
  //   String date1 = '2024-01-02 00:01:01';
  //   final parsedDate1 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date1);

  //   String date2 = '2024-01-02 23:00:01';
  //   final parsedDate2 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date2);

  //   String date3 = '2024-01-02 01:01:01';
  //   final parsedDate3 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date3);

  //   String date4 = '2024-01-02 12:01:01';
  //   final parsedDate4 = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date4);
  //   log('1 $parsedDate1 2 $parsedDate2 3 $parsedDate3 4 $parsedDate4');

  //   log('1 ${parsedDate1.hour} 2 ${parsedDate2.hour} 3 ${parsedDate3.hour} 4 ${parsedDate4.hour}');
  // }
}
