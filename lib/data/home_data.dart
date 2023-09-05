import 'dart:developer';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../model/clean_data_model.dart';
import '../model/clean_excel_model.dart';
import '../model/department_model.dart';
import '../model/late_model.dart';
import '../model/log_model.dart';
import '../model/schedule_model.dart';
import '../model/history_model.dart';
import '../services/http_service.dart';

class HomeData with ChangeNotifier {
  var _historyList = <HistoryModel>[];
  List<HistoryModel> get historyList => _historyList;

  var _uiList = <HistoryModel>[];
  List<HistoryModel> get uiList => _uiList;

  final _departmentList = <DepartmentModel>[];
  List<DepartmentModel> get departmentList => _departmentList;

  final _scheduleList = <ScheduleModel>[];
  List<ScheduleModel> get scheduleList => _scheduleList;

  var _cleanData = <CleanDataModel>[];
  List<CleanDataModel> get cleanData => _cleanData;

  final _cleanExcelData = <CleanExcelDataModel>[];
  List<CleanExcelDataModel> get cleanExcelData => _cleanExcelData;

  var _appVersion = "";
  String get appVersion => _appVersion;

  DateTime selectedFrom = DateTime.now();
  DateTime selectedTo = DateTime.now();

  final _isLogging = ValueNotifier(false);
  ValueNotifier<bool> get isLogging => _isLogging;

  final _is24HourFormat = ValueNotifier(false);
  ValueNotifier<bool> get is24HourFormat => _is24HourFormat;

  final _dateFormat1 = DateFormat('yyyy-MM-dd HH:mm');
  final _dateFormat2 = DateFormat('yyyy-MM-dd hh:mm aa');
  DateFormat get dateFormat2 => _dateFormat2;
  final _dateFormatFileExcel = DateFormat().add_yMMMMd();

  void changeLoadingState(bool state) {
    _isLogging.value = state;
  }

  DateFormat dateFormat12or24() {
    if (_is24HourFormat.value) {
      return _dateFormat1;
    } else {
      return _dateFormat2;
    }
  }

  String formatPrettyDate(DateTime? d) {
    if (d == null) {
      return '';
    }
    return dateFormat12or24Excel(d);
  }

  String dateFormat12or24Web(DateTime dateTime) {
    if (_is24HourFormat.value) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('hh:mm aa').format(dateTime);
    }
  }

  String dateFormat12or24Excel(DateTime dateTime) {
    if (_is24HourFormat.value) {
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd hh:mm aa').format(dateTime);
    }
  }

  // String dateFormat12or24Time() {
  //   if (_is24HourFormat.value) {
  //     return 'HH:mm';
  //   } else {
  //     return 'hh:mm aa';
  //   }
  // }

  // String friendlyDateFormat(String date) {
  //   var friendlyDate = '';
  //   if (date == '' || date == 'In' || date == 'Out') {
  //     return date;
  //   }
  //   try {
  //     friendlyDate = DateFormat.yMEd()
  //         .addPattern(dateFormat12or24Time())
  //         .format(dateFormat12or24().parse(date));
  //   } catch (e) {
  //     debugPrint('friendlyDateFormat $e');
  //     log(date);
  //   }
  //   return friendlyDate;
  // }

  void reCalcLate({
    required CleanExcelDataModel model,
    required ScheduleModel newSchedule,
  }) {
    var duration = LateModel(hour: 0, lateIn: 0, lateBreak: 0, overtime: 0);
    try {
      duration = calcDurationInOutSameDay(
        logs: model.logs,
        name: model.name,
        sched: newSchedule,
      );
      var finalOtString = calcOvertimeHour(duration.overtime);
      model.duration = duration.hour.toString();
      model.lateIn = duration.lateIn.toString();
      model.lateBreak = duration.lateBreak.toString();
      model.overtime = finalOtString;
      model.currentSched = newSchedule;
    } catch (e) {
      debugPrint('$e reCalcLate');
    }
  }

  void exportExcel() {
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
        ..value = 'ID / Name'
        ..cellStyle = cellStyle;

      var column2 = sheetObject.cell(CellIndex.indexByString('B1'));
      column2
        ..value = 'In'
        ..cellStyle = cellStyle;

      var column3 = sheetObject.cell(CellIndex.indexByString('C1'));
      column3
        ..value = 'Out'
        ..cellStyle = cellStyle;

      var column4 = sheetObject.cell(CellIndex.indexByString('D1'));
      column4
        ..value = 'In'
        ..cellStyle = cellStyle;

      var column5 = sheetObject.cell(CellIndex.indexByString('E1'));
      column5
        ..value = 'Out'
        ..cellStyle = cellStyle;

      var column6 = sheetObject.cell(CellIndex.indexByString('F1'));
      column6
        ..value = 'D(h)'
        ..cellStyle = cellStyle;

      var column7 = sheetObject.cell(CellIndex.indexByString('G1'));
      column7
        ..value = 'T(m)'
        ..cellStyle = cellStyle;

      var column8 = sheetObject.cell(CellIndex.indexByString('H1'));
      column8
        ..value = 'BT(m)'
        ..cellStyle = cellStyle;

      var column9 = sheetObject.cell(CellIndex.indexByString('I1'));
      column9
        ..value = 'OT'
        ..cellStyle = cellStyle;

      var column10 = sheetObject.cell(CellIndex.indexByString('J1'));
      column10
        ..value = 'UD'
        ..cellStyle = cellStyle;

      var cellStyleData = CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 9,
      );

      for (int i = 1; i < _cleanExcelData.length; i++) {
        var idName = '';
        if (_cleanExcelData[i].name != '') {
          idName =
              '${_cleanExcelData[i].employeeId} / ${_cleanExcelData[i].name}';
        }

        var duration = int.tryParse(_cleanExcelData[i].duration);
        var lateIn = int.tryParse(_cleanExcelData[i].lateIn);
        var lateBreak = int.tryParse(_cleanExcelData[i].lateBreak);
        var overtime = _cleanExcelData[i].overtime;

        log('kani ${_cleanExcelData[i].overtime} $overtime');

        List<dynamic> dataList = [
          idName,
          _cleanExcelData[i].in1.timestamp,
          _cleanExcelData[i].out1.timestamp,
          _cleanExcelData[i].in2.timestamp,
          _cleanExcelData[i].out2.timestamp,
          duration,
          lateIn,
          lateBreak,
          overtime,
        ];
        sheetObject.appendRow(dataList);
        sheetObject.setColWidth(0, 25.70);
        sheetObject.setColWidth(1, 15.70);
        sheetObject.setColWidth(2, 15.71);
        sheetObject.setColWidth(3, 15.72);
        sheetObject.setColWidth(4, 15.73);
        sheetObject.setColWidth(5, 3.50);
        sheetObject.setColWidth(6, 3.90);
        sheetObject.setColWidth(7, 4.70);
        sheetObject.setColWidth(8, 2.90);
        sheetObject.setColWidth(9, 2.91);

        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: i,
          ),
          idName,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: i,
          ),
          _cleanExcelData[i].in1.timestamp,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 2,
            rowIndex: i,
          ),
          _cleanExcelData[i].out1.timestamp,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 3,
            rowIndex: i,
          ),
          _cleanExcelData[i].in2.timestamp,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 4,
            rowIndex: i,
          ),
          _cleanExcelData[i].out2.timestamp,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 5,
            rowIndex: i,
          ),
          duration,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 6,
            rowIndex: i,
          ),
          lateIn,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 7,
            rowIndex: i,
          ),
          lateBreak,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 8,
            rowIndex: i,
          ),
          overtime,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 9,
            rowIndex: i,
          ),
          '',
          cellStyle: cellStyleData,
        );
      }
      excel.save(
          fileName:
              'DTR ${_dateFormatFileExcel.format(selectedFrom)} - ${_dateFormatFileExcel.format(selectedTo)}.xlsx');
    } catch (e) {
      debugPrint('exportExcel $e');
    }
  }

  void sortData() {
    final cd = <CleanDataModel>[];
    var dayOfWeek = DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    for (int i = 0; i < _historyList.length; i++) {
      var todaySched = scheduleList.singleWhere(
        (element) =>
            element.schedId ==
            selectDay(day: dayOfWeek, model: _historyList[i]),
      );
      cd.add(
        CleanDataModel(
          employeeId: _historyList[i].employeeId,
          firstName: _historyList[i].firstName,
          lastName: _historyList[i].lastName,
          middleName: _historyList[i].middleName,
          currentSched: todaySched,
          date: _historyList[i].date,
          logs: _historyList[i].logs,
        ),
      );
    }

    cd.sort((a, b) {
      var valueA = '${a.lastName.toLowerCase()} ${a.date}';
      var valueB = '${b.lastName.toLowerCase()} ${b.date}';
      return valueA.compareTo(valueB);
    });

    cleanseData(cd);
  }

  List<CleanDataModel> dayCleanData({
    required int i,
    required List<CleanDataModel> c,
  }) {
    final dayCleanData = <CleanDataModel>[];
    if (i == 0) {
      try {
        var logs = <Log>[];
        bool isSoloOut = false;
        if (c[i].logs.first.logType == 'OUT' && c[i].logs.length > 1) {
          for (int k = 1; k < c[i].logs.length; k++) {
            logs.add(c[i].logs[k]);
          }
        } else if (c[i].logs.length == 1 && c[i].logs.first.logType == 'IN') {
          logs.add(c[i].logs.first);
        } else if (c[i].logs.first.logType == 'OUT' && c[i].logs.length == 1) {
          isSoloOut = true;
        } else {
          logs.addAll(c[i].logs);
        }

        if (!isSoloOut) {
          dayCleanData.add(
            CleanDataModel(
              employeeId: c[i].employeeId,
              firstName: c[i].firstName,
              lastName: c[i].lastName,
              middleName: c[i].middleName,
              date: c[i].date,
              logs: logs,
              currentSched: c[i].currentSched,
            ),
          );
        }
      } catch (e) {
        debugPrint('if $e');
      }
    } else if (i == c.length - 1) {
      try {
        var logs = <Log>[];

        if (c[i].logs.first.logType == 'OUT') {
          for (int k = 1; k < c[i].logs.length; k++) {
            logs.add(c[i].logs[k]);
          }
        } else {
          logs.addAll(c[i].logs);
        }

        dayCleanData.add(
          CleanDataModel(
            employeeId: c[i].employeeId,
            firstName: c[i].firstName,
            lastName: c[i].lastName,
            middleName: c[i].middleName,
            date: c[i].date,
            logs: logs,
            currentSched: c[i].currentSched,
          ),
        );
      } catch (e) {
        debugPrint('else $e');
      }
    } else {
      try {
        if (c[i].logs.last.logType == 'IN') {
          var logs = <Log>[];

          logs.add(c[i].logs.last);

          if (fullName(c[i]) == fullName(c[i + 1])) {
            if (isForgotOut(c[i + 1])) {
            } else {
              logs.add(c[i + 1].logs.first);
            }
          }

          dayCleanData.add(
            CleanDataModel(
              employeeId: c[i].employeeId,
              firstName: c[i].firstName,
              lastName: c[i].lastName,
              middleName: c[i].middleName,
              date: c[i].date,
              logs: logs,
              currentSched: c[i].currentSched,
            ),
          );
        } else {
          var logs = <Log>[];
          bool isSoloOut = false;
          if (c[i].logs.first.logType == 'OUT' && c[i].logs.length > 2) {
            for (int k = 1; k < c[i].logs.length; k++) {
              logs.add(c[i].logs[k]);
            }
          } else if (c[i].logs.length == 1 &&
              c[i].logs.first.logType == 'OUT') {
            isSoloOut = true;
          } else {
            logs.addAll(c[i].logs);
          }

          if (!isSoloOut) {
            dayCleanData.add(
              CleanDataModel(
                employeeId: c[i].employeeId,
                firstName: c[i].firstName,
                lastName: c[i].lastName,
                middleName: c[i].middleName,
                date: c[i].date,
                logs: logs,
                currentSched: c[i].currentSched,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('else $e ${c[i].date} ${c[i].firstName}');
      }
    }
    return dayCleanData;
  }

  List<CleanDataModel> eveningCleanData({
    required int i,
    required List<CleanDataModel> c,
  }) {
    final dayCleanData = <CleanDataModel>[];
    if (i == 0) {
      try {
        var logs = <Log>[];
        if (c[i].logs.first.logType == 'OUT' && c[i].logs.length > 1) {
          for (int k = 0; k < c[i].logs.length; k++) {
            logs.add(c[i].logs[k]);
          }
        } else if (c[i].logs.first.logType == 'IN' && c[i].logs.length == 1) {
          logs.add(c[i].logs.first);
          logs.add(c[i + 1].logs.first);
          if (isInCloseEvening(c[i + 1])) {
            logs.add(c[i + 1].logs[1]);
            logs.add(c[i + 1].logs[2]);
          }
        } else if (c[i].logs.length > 3 && c[i].logs.first.logType == 'OUT') {
          logs.addAll(c[i].logs.sublist(1, 4));
        } else {
          logs.addAll(c[i].logs);
        }
        dayCleanData.add(
          CleanDataModel(
            employeeId: c[i].employeeId,
            firstName: c[i].firstName,
            lastName: c[i].lastName,
            middleName: c[i].middleName,
            date: c[i].date,
            logs: logs,
            currentSched: c[i].currentSched,
          ),
        );
      } catch (e) {
        debugPrint('if $e');
      }
    } else if (i == c.length - 1) {
      try {
        var logs = <Log>[];
        bool isSoloOut = false;
        if (c[i].logs.length == 1 && c[i].logs.first.logType == 'OUT') {
          logs.add(c[i].logs.first);
          isSoloOut = true;
        } else if (c[i].logs.length > 3 && c[i].logs.first.logType == 'OUT') {
          logs.addAll(c[i].logs.sublist(1));
        } else {
          logs.addAll(c[i].logs);
        }
        if (!isSoloOut) {
          dayCleanData.add(
            CleanDataModel(
              employeeId: c[i].employeeId,
              firstName: c[i].firstName,
              lastName: c[i].lastName,
              middleName: c[i].middleName,
              date: c[i].date,
              logs: logs,
              currentSched: c[i].currentSched,
            ),
          );
        }
      } catch (e) {
        debugPrint('else $e');
      }
    } else {
      try {
        var logs = <Log>[];
        bool isSoloOut = false;
        if (c[i].logs.first.logType == 'OUT' &&
            c[i].logs.last.logType == 'IN' &&
            c[i].logs.length > 3) {
          logs.add(c[i].logs.last);
          if (c[i + 1].logs.length > 3 &&
              c[i + 1].logs.first.logType == 'OUT' &&
              c[i + 1].logs.last.logType == 'IN') {
            logs.addAll(c[i + 1].logs.sublist(0, 3));
          } else if (c[i + 1].logs.length == 1 &&
              c[i + 1].logs.first.logType == 'OUT') {
            logs.add(c[i + 1].logs.first);
          } else {
            logs.add(c[i + 1].logs.first);
          }
        } else if (c[i].logs.length == 1 && c[i].logs.last.logType == 'IN') {
          logs.add(c[i].logs.last);
          if (c[i + 1].logs.length > 3 &&
              c[i + 1].logs.first.logType == 'OUT' &&
              c[i + 1].logs.last.logType == 'IN') {
            logs.addAll(c[i + 1].logs.sublist(0, 3));
          } else if (c[i + 1].logs.length < 4 &&
              c[i + 1].logs.first.logType == 'OUT') {
            logs.add(c[i + 1].logs.first);
          }
        } else if (c[i].logs.length == 1 && c[i].logs.first.logType == 'OUT') {
          isSoloOut = true;
        } else if (c[i].logs.length < 4 &&
            c[i].logs.first.logType == 'OUT' &&
            c[i + 1].logs.first.logType == 'OUT') {
          logs.addAll(c[i].logs.sublist(1));
          logs.add(c[i + 1].logs.first);
        } else {
          logs.addAll(c[i].logs);
        }

        if (!isSoloOut) {
          dayCleanData.add(
            CleanDataModel(
              employeeId: c[i].employeeId,
              firstName: c[i].firstName,
              lastName: c[i].lastName,
              middleName: c[i].middleName,
              date: c[i].date,
              logs: logs,
              currentSched: c[i].currentSched,
            ),
          );
        }
      } catch (e) {
        debugPrint('else $e ${c[i].date} ${c[i].firstName}');
      }
    }
    return dayCleanData;
  }

  void cleanseData(List<CleanDataModel> c) {
    _cleanData.clear();
    for (int i = 0; i < c.length; i++) {
      if (isEvening(c[i])) {
        var resultdayClean = eveningCleanData(i: i, c: c);
        _cleanData.addAll(resultdayClean);
      } else {
        var resultdayClean = dayCleanData(i: i, c: c);
        _cleanData.addAll(resultdayClean);
      }
    }
    calcLogs(_cleanData);
    finalizeData(_cleanData);
  }

  void calcLogs(List<CleanDataModel> c) {
    for (int i = 0; i < c.length; i++) {
      var duration = calcDurationInOutSameDay(
        logs: c[i].logs,
        name: c[i].firstName,
        sched: c[i].currentSched,
      );
      var finalOtString = calcOvertimeHour(duration.overtime);

      c[i].duration = duration.hour.toString();
      c[i].lateIn = duration.lateIn.toString();
      c[i].lateBreak = duration.lateBreak.toString();
      c[i].overtime = finalOtString;
    }

    _cleanData = c;
  }

  void finalizeData(List<CleanDataModel> c) {
    _cleanExcelData.clear();
    var count = 0;
    _cleanExcelData.add(
      CleanExcelDataModel(
        employeeId: 'Emp ID',
        name: 'Name',
        currentSched: ScheduleModel(
          schedId: 'Sched ID',
          schedType: '',
          schedIn: '',
          breakStart: '',
          breakEnd: '',
          schedOut: '',
          description: '',
        ),
        date: DateTime.now(),
        logs: <Log>[],
        duration: 'Duration(Hrs)',
        lateIn: 'Tardy(Mns)',
        lateBreak: 'Late Break(Mns)',
        overtime: 'Overtime',
        rowCount: '',
        in1: TimeLog(timestamp: 'In'),
        out1: TimeLog(timestamp: 'Out'),
        in2: TimeLog(timestamp: 'In'),
        out2: TimeLog(timestamp: 'Out'),
      ),
    );
    for (int i = 0; i < c.length; i++) {
      count = count + 1;

      if (i > 0 && c[i].employeeId != c[i - 1].employeeId) {
        _cleanExcelData.add(
          CleanExcelDataModel(
            employeeId: '',
            name: '',
            currentSched: ScheduleModel(
              schedId: '',
              schedType: '',
              schedIn: '',
              breakStart: '',
              breakEnd: '',
              schedOut: '',
              description: '',
            ),
            date: DateTime.now(),
            logs: <Log>[],
            duration: '',
            lateIn: '',
            lateBreak: '',
            overtime: '',
            rowCount: '',
            in1: TimeLog(),
            out1: TimeLog(),
            in2: TimeLog(),
            out2: TimeLog(),
          ),
        );
        count = 1;
      }

      _cleanExcelData.add(
        CleanExcelDataModel(
          employeeId: c[i].employeeId,
          name: fullName(c[i]),
          currentSched: c[i].currentSched,
          date: c[i].date,
          logs: c[i].logs,
          duration: c[i].duration!,
          lateIn: c[i].lateIn!,
          lateBreak: c[i].lateBreak!,
          overtime: c[i].overtime!,
          rowCount: '$count',
          in1: TimeLog(),
          out1: TimeLog(),
          in2: TimeLog(),
          out2: TimeLog(),
        ),
      );
    }
    for (var cxd in _cleanExcelData) {
      if (cxd.logs.isNotEmpty) {
        cxd.in1.timestamp = formatPrettyDate(cxd.logs[0].timeStamp);
        cxd.in1.isSelfie = cxd.logs[0].isSelfie;
        cxd.in1.isSelfie = cxd.logs[0].id;
      }
      if (cxd.logs.length >= 2) {
        cxd.out1.timestamp = formatPrettyDate(cxd.logs[1].timeStamp);
        cxd.out1.isSelfie = cxd.logs[1].isSelfie;
        cxd.out1.id = cxd.logs[1].id;
      }
      if (cxd.logs.length >= 3) {
        cxd.in2.timestamp = formatPrettyDate(cxd.logs[2].timeStamp);
        cxd.in2.isSelfie = cxd.logs[2].isSelfie;
        cxd.in2.id = cxd.logs[2].id;
      }
      if (cxd.logs.length >= 4) {
        cxd.out2.timestamp = formatPrettyDate(cxd.logs[3].timeStamp);
        cxd.out2.isSelfie = cxd.logs[3].isSelfie;
        cxd.out2.id = cxd.logs[3].id;
      }
    }
  }

  void checkData() {
    for (int i = 0; i < _cleanData.length; i++) {
      log('${_cleanData[i].date}');
      for (int k = 0; k < _cleanData[i].logs.length; k++) {
        log('${_cleanData[i].logs[k].logType} ${_cleanData[i].logs[k].timeStamp}');
      }
    }
  }

  bool isEvening(CleanDataModel c) {
    if (c.currentSched.schedId.substring(0, 1).toUpperCase() == 'E') {
      return true;
    }
    return false;
  }

  bool isForgotOut(CleanDataModel c) {
    var differenceForgotOut = 0;
    try {
      if (c.logs[0].logType == 'OUT' && c.logs[1].logType == 'IN') {
        differenceForgotOut =
            c.logs[1].timeStamp.difference(c.logs[0].timeStamp).inMinutes;
        // dont calc if out and in if less than 30 minutes gap
        // means user forgot to out
        if (differenceForgotOut < 30) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('$e isForgotOut');
    }
    return false;
  }

  bool isInCloseEvening(CleanDataModel c) {
    var differenceForgotOut = 0;
    try {
      if (c.logs[1].logType == 'IN' && c.logs[2].logType == 'OUT') {
        differenceForgotOut =
            c.logs[2].timeStamp.difference(c.logs[1].timeStamp).inMinutes;
        // dont calc if out and in if less than 30 minutes gap
        // means user forgot to out
        if (differenceForgotOut < 30) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('$e isInCloseEvening');
    }
    return false;
  }

  String fullName(CleanDataModel cleanDataModel) {
    return '${cleanDataModel.lastName}, ${cleanDataModel.firstName} ${cleanDataModel.middleName}';
  }

  String selectDay({required String day, required HistoryModel model}) {
    switch (day) {
      case 'monday':
        return model.monday;
      case 'tuesday':
        return model.tuesday;
      case 'wednesday':
        return model.wednesday;
      case 'thursday':
        return model.thursday;
      case 'friday':
        return model.friday;
      case 'saturday':
        return model.saturday;
      default:
        return model.sunday;
    }
  }

  String nameIndex(HistoryModel model) {
    final name = "${model.lastName}, ${model.firstName} ${model.middleName}";
    return name;
  }

  String calcOvertimeHour(int overtime) {
    var finalOtString = '';
    try {
      var overtimeDouble = overtime / 60;
      var overtimeDoubleString = overtimeDouble.toStringAsFixed(1);
      var rounderDigit = overtimeDouble.toStringAsFixed(1).substring(2, 3);
      if (int.parse(rounderDigit) >= 5) {
        finalOtString = overtimeDoubleString.replaceRange(2, 3, '5');
      } else {
        finalOtString = overtimeDoubleString.replaceRange(2, 3, '0');
      }
      if (overtimeDouble < 0.5) {
        finalOtString = '0';
      }
      log('last $finalOtString');
    } catch (e) {
      debugPrint('$e calcOvertimeHour');
    }
    return finalOtString;
  }

  // calculate duration in hours if log out is other day
  LateModel calcDurationInOutOtherDay({
    required List<Log> logs1,
    required List<Log> logs2,
    required String name,
    required ScheduleModel sched,
  }) {
    var seconds = 0;
    var logs = <Log>[];

    try {
      if (logs1.last.logType == 'IN') {
        logs.add(logs1.last);
        if (logs2.first.logType == 'IN') {
          for (int j = 0; j < logs2.length; j++) {
            if (logs2[j].logType == 'OUT') {
              logs.add(logs2[j]);
              break;
            }
          }
        } else {
          logs.add(logs2.first);
        }
      }

      for (int i = 0; i < logs.length; i++) {
        if (i + 1 < logs.length) {
          if (logs[i].logType == 'IN' && logs[i + 1].logType == 'OUT') {
            seconds = seconds +
                logs[i + 1].timeStamp.difference(logs[i].timeStamp).inSeconds;
          }
        }
      }
    } catch (e) {
      debugPrint('other error $e');
    }
    var latePenalty = calcLate(
      logs: logs,
      name: name,
      sched: sched,
    );
    seconds = seconds + 300;
    var hours = Duration(seconds: seconds).inHours;
    var lateIn = Duration(seconds: latePenalty.lateInMinutes).inMinutes;
    var lateBreak = Duration(seconds: latePenalty.lateBreakMinutes).inMinutes;
    var overtime = Duration(seconds: latePenalty.overtimeSeconds).inMinutes;
    var model = LateModel(
      hour: hours,
      lateIn: lateIn,
      lateBreak: lateBreak,
      overtime: overtime,
    );
    var differenceForgotOut = 0;
    if (logs2[0].logType == 'OUT' && logs2[1].logType == 'IN') {
      differenceForgotOut =
          logs2[1].timeStamp.difference(logs2[0].timeStamp).inMinutes;
      // dont calc if out and in if less than 30 minutes gap
      // means user forgot to out
      if (differenceForgotOut < 30) {
        model = LateModel(hour: 0, lateIn: 0, lateBreak: 0, overtime: 0);
      }
    }
    return model;
  }

  // calculate duration in hours if in and out same day
  LateModel calcDurationInOutSameDay({
    required List<Log> logs,
    required String name,
    required ScheduleModel sched,
  }) {
    var seconds = 0;
    try {
      for (int i = 0; i < logs.length; i++) {
        if (i + 1 < logs.length) {
          if (logs[i].logType == 'IN' && logs[i + 1].logType == 'OUT') {
            seconds = seconds +
                logs[i + 1].timeStamp.difference(logs[i].timeStamp).inSeconds;
          }
        }
      }
    } catch (e) {
      debugPrint('same day error $e');
    }
    var latePenalty = calcLate(
      logs: logs,
      name: name,
      sched: sched,
    );
    seconds = seconds + 300;
    var hours = Duration(seconds: seconds).inHours;
    var lateIn = Duration(seconds: latePenalty.lateInMinutes).inMinutes;
    var lateBreak = Duration(seconds: latePenalty.lateBreakMinutes).inMinutes;
    var overtime = Duration(seconds: latePenalty.overtimeSeconds).inMinutes;
    return LateModel(
      hour: hours,
      lateIn: lateIn,
      lateBreak: lateBreak,
      overtime: overtime,
    );
  }

  LateMinutesModel calcLate({
    required List<Log> logs,
    required String name,
    required ScheduleModel sched,
  }) {
    var sIn = sched.schedIn;
    var bEnd = sched.breakEnd;
    var sOut = sched.schedOut;
    var schedIn = '';
    var breakIn = '';
    var schedOut = '';
    var latePenaltyIn = 0;
    var latePenaltyBreak = 0;
    var overtime = 0;
    var calcOvertimebreak = true;
    try {
      if (sched.schedType.toLowerCase() != 'c') {
        if (logs.length >= 2) {
          if (logs[0].logType == 'IN' && logs[1].logType == 'OUT') {
            schedIn = '${logs[0].timeStamp.toString().substring(0, 10)} $sIn';
            var inDifference = logs[0]
                .timeStamp
                .difference(_dateFormat1
                    .parse(schedIn)
                    .add(const Duration(seconds: 300)))
                .inSeconds;

            // late
            if (inDifference > 0) {
              latePenaltyIn = latePenaltyIn + inDifference + 300;
            }
          }
          if (logs.length >= 4 && sched.schedType.toLowerCase() == 'b') {
            calcOvertimebreak = false;
            if (logs[2].logType == 'IN' && logs[3].logType == 'OUT') {
              breakIn =
                  '${logs[2].timeStamp.toString().substring(0, 10)} $bEnd';
              var inDifference = logs[2]
                  .timeStamp
                  .difference(_dateFormat1
                      .parse(breakIn)
                      .add(const Duration(seconds: 300)))
                  .inSeconds;
              // late
              if (inDifference > 0) {
                latePenaltyBreak = latePenaltyBreak + inDifference + 300;
              }
            }
          }
          if (calcOvertimebreak) {
            schedOut = '${logs[1].timeStamp.toString().substring(0, 10)} $sOut';
            overtime = logs[1]
                .timeStamp
                .difference(_dateFormat1.parse(schedOut))
                .inSeconds;
          } else {
            schedOut = '${logs[3].timeStamp.toString().substring(0, 10)} $sOut';
            overtime = logs[3]
                .timeStamp
                .difference(_dateFormat1.parse(schedOut))
                .inSeconds;
          }
          if (overtime < 0) overtime = 0;
        }
      }
    } catch (e) {
      debugPrint('$e calcLate');
    }
    return LateMinutesModel(
      lateInMinutes: latePenaltyIn,
      lateBreakMinutes: latePenaltyBreak,
      overtimeSeconds: overtime,
    );
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

  // get device version
  Future<void> getPackageInfo() async {
    try {
      await PackageInfo.fromPlatform().then((result) {
        _appVersion = result.version;
        debugPrint('_appVersion $_appVersion');
      });
    } catch (e) {
      debugPrint('getPackageInfo $e');
      notifyListeners();
    }
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

  Future<void> getDepartment() async {
    try {
      final result = await HttpService.getDepartment();
      _departmentList.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e getDepartment');
    }
  }

  Future<void> getSchedule() async {
    try {
      final result = await HttpService.geSchedule();
      _scheduleList.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e getSchedule');
    }
  }
}
