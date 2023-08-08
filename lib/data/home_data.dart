// import 'dart:developer';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/department_model.dart';
import '../model/excel_model.dart';
import '../model/late_model.dart';
import '../model/log_model.dart';
import '../model/schedule_model.dart';
import '../model/history_model.dart';
import '../services/http_service.dart';

class HomeData with ChangeNotifier {
  var _historyList = <HistoryModel>[];
  List<HistoryModel> get historyList => _historyList;

  var _excelList = <ExcelModel>[];
  List<ExcelModel> get excelList => _excelList;

  var _uiList = <HistoryModel>[];
  List<HistoryModel> get uiList => _uiList;

  final _departmentList = <DepartmentModel>[];
  List<DepartmentModel> get departmentList => _departmentList;

  final _scheduleList = <ScheduleModel>[];
  List<ScheduleModel> get scheduleList => _scheduleList;

  DateTime selectedFrom = DateTime.now();
  DateTime selectedTo = DateTime.now();

  final _isLogging = ValueNotifier(false);
  ValueNotifier<bool> get isLogging => _isLogging;

  final _is24HourFormat = ValueNotifier(false);
  ValueNotifier<bool> get is24HourFormat => _is24HourFormat;

  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final _dateFormatFileExcel = DateFormat().add_yMMMMd();

  String dateFormat12or24Excel(DateTime dateTime) {
    if (_is24HourFormat.value) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd hh:mm:ss aa').format(dateTime);
    }
  }

  String dateFormat12or24Web(DateTime dateTime) {
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

  void exportExcel(bool isExcel) {
    final historyListExcel = <HistoryModel>[..._historyList];

    // sort list alphabetically and by date, very important
    historyListExcel.sort((a, b) {
      return '${a.lastName.toLowerCase()} ${a.firstName.toLowerCase()} ${a.middleName.toLowerCase()}  ${a.date.toString()}'
          .compareTo(
              '${b.lastName.toLowerCase()} ${b.firstName.toLowerCase()} ${b.middleName.toLowerCase()}  ${b.date.toString()}');
    });

    final result = <ExcelModel>[
      ExcelModel(
        rowCount: '',
        employeeId: 'Emp ID',
        name: 'Name',
        timeIn1: 'In',
        timeOut1: 'Out',
        timeIn2: 'In',
        timeOut2: 'Out',
        duration: 'Duration(Hours)',
        lateIn: 'Late Break(Minutes)',
        lateBreak: 'Late In(Minutes)',
      )
    ];

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
        ..value = 'In'
        ..cellStyle = cellStyle;

      var column5 = sheetObject.cell(CellIndex.indexByString('E1'));
      column5
        ..value = 'Out'
        ..cellStyle = cellStyle;

      var column6 = sheetObject.cell(CellIndex.indexByString('F1'));
      column6
        ..value = 'In'
        ..cellStyle = cellStyle;

      var column7 = sheetObject.cell(CellIndex.indexByString('G1'));
      column7
        ..value = 'Out'
        ..cellStyle = cellStyle;

      var column8 = sheetObject.cell(CellIndex.indexByString('H1'));
      column8
        ..value = 'Duration(Hours)'
        ..cellStyle = cellStyle;

      var column10 = sheetObject.cell(CellIndex.indexByString('I1'));
      column10
        ..value = 'Late In(Minutes)'
        ..cellStyle = cellStyle;

      var column11 = sheetObject.cell(CellIndex.indexByString('J1'));
      column11
        ..value = 'Late Break(Minutes)'
        ..cellStyle = cellStyle;

      var column12 = sheetObject.cell(CellIndex.indexByString('K1'));
      column12
        ..value = 'Undertime'
        ..cellStyle = cellStyle;

      var column13 = sheetObject.cell(CellIndex.indexByString('L1'));
      column13
        ..value = 'Tardy'
        ..cellStyle = cellStyle;

      var column14 = sheetObject.cell(CellIndex.indexByString('M1'));
      column14
        ..value = 'Overtime'
        ..cellStyle = cellStyle;

      var rowCountUser = 0;

      try {
        for (int k = 0; k < historyListExcel.length; k++) {
          if (k == 0 &&
              historyListExcel[k].logs.length == 1 &&
              historyListExcel[k].logs.first.logType == 'OUT') {
            historyListExcel.removeAt(k);
          } else if (k > 0) {
            //remove solo out and move to yesterday
            if (historyListExcel[k].logs.length == 1 &&
                historyListExcel[k].logs.first.logType == 'OUT' &&
                historyListExcel[k - 1].logs.last.logType == 'IN') {
              if (nameIndex(historyListExcel[k]) ==
                  nameIndex(historyListExcel[k - 1])) {
                historyListExcel[k - 1]
                    .logs
                    .add(historyListExcel[k].logs.first);
              }
              if (k - 1 == 0) {
                historyListExcel[k - 1].logs.removeAt(0);
                // log('remove solo 0');
              }
              historyListExcel.removeAt(k);
              // log('remove solo 1');
            }
          } else if (k > 0 && k < 3) {
            if (nameIndex(historyListExcel[k]) !=
                    nameIndex(historyListExcel[k - 1]) &&
                nameIndex(historyListExcel[k]) !=
                    nameIndex(historyListExcel[k + 1])) {
              // log('remove solo 2');
              historyListExcel.removeAt(k);
            }
          }
          if (k + 1 < historyListExcel.length &&
              nameIndex(historyListExcel[k]) ==
                  nameIndex(historyListExcel[k + 1]) &&
              historyListExcel[k].logs.first.logType == 'OUT' &&
              historyListExcel[k].logs.length == 1) {
            // log('remove solo 3');
            historyListExcel.removeAt(k);
          }
        }
      } catch (e) {
        debugPrint('$e remove solo out and move to yesterday');
      }

      for (int i = 0; i < historyListExcel.length; i++) {
        try {
          //remove first out if logs more than 2
          if (historyListExcel[i].logs.isNotEmpty) {
            if (historyListExcel[i].logs.first.logType == 'OUT' &&
                historyListExcel[i].logs.length > 2 &&
                rowCountUser == 1) {
              if (historyListExcel[i].logs.isNotEmpty) {
                historyListExcel[i].logs.removeAt(0);
              }
            }
          }
        } catch (e) {
          debugPrint('$e remove first out if logs more than 2');
        }

        rowCountUser = rowCountUser + 1;

        late LateModel duration;
        var timeLogs = <Log>[];

        if (i > 0) {
          //reset user logs count and add space
          if (nameIndex(historyListExcel[i - 1]) !=
              nameIndex(historyListExcel[i])) {
            List<dynamic> emptyRow = [
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
            result.add(ExcelModel(
              rowCount: '',
              employeeId: '',
              name: '',
              timeIn1: '',
              timeOut1: '',
              timeIn2: '',
              timeOut2: '',
              duration: '',
              lateIn: '',
              lateBreak: '',
            ));
            rowCountUser = 1;
          }
        }
        var dayOfWeek = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
        var todaySched = scheduleList.singleWhere(
          (element) =>
              element.schedId ==
              selectDay(day: dayOfWeek, model: historyListExcel[i]),
        );

        // if last log is in, then date out is tommorrow
        if (historyListExcel[i].logs.isNotEmpty) {
          if (historyListExcel[i].logs.last.logType == 'IN') {
            try {
              if (i + 1 < historyListExcel.length) {
                if (nameIndex(historyListExcel[i]) ==
                    nameIndex(historyListExcel[i + 1])) {
                  // log('dire 0');

                  duration = calcDurationInOutOtherDay(
                    logs1: historyListExcel[i].logs,
                    logs2: historyListExcel[i + 1].logs,
                    name: historyListExcel[i].firstName,
                    sched: todaySched,
                  );
                  timeLogs.add(historyListExcel[i].logs.last);
                  // move first log other day to yesterday if out
                  timeLogs.add(historyListExcel[i + 1].logs[0]);
                  // if next log is out and is solo, remove
                  if (historyListExcel[i + 1].logs.isNotEmpty) {
                    historyListExcel[i + 1].logs.removeAt(0);
                  }
                } else {
                  //remove first log of n+1 index if out, because already move to i
                  if (historyListExcel[i + 1].logs.isNotEmpty) {
                    if (historyListExcel[i + 1].logs[0].logType == 'OUT' &&
                        nameIndex(historyListExcel[i]) ==
                            nameIndex(historyListExcel[i + 1])) {
                      historyListExcel[i + 1].logs.removeAt(0);
                    }
                  }
                  // log('dire 1');
                  duration = calcDurationInOutSameDay(
                    logs: historyListExcel[i].logs,
                    name: historyListExcel[i].firstName,
                    sched: todaySched,
                  );
                  // timeLogs.add(historyListExcel[i].logs.last);
                  if (historyListExcel[i].logs.isNotEmpty) {
                    timeLogs.addAll(historyListExcel[i].logs);
                  }
                }
              } else {
                // log('dire 2');
                // if last log is in and last index, do in out same day, otherwise dont calc duration
                if (historyListExcel[i].logs.isNotEmpty) {
                  duration = calcDurationInOutSameDay(
                    logs: historyListExcel[i].logs,
                    name: historyListExcel[i].firstName,
                    sched: todaySched,
                  );
                  timeLogs.addAll(historyListExcel[i].logs);
                }
              }
            } catch (e) {
              debugPrint('$e if in');
            }
          } else {
            try {
              if (historyListExcel[i].logs.isNotEmpty) {
                // log('dire 3');
                // if date is out, then date in and out same
                duration = calcDurationInOutSameDay(
                  logs: historyListExcel[i].logs,
                  name: historyListExcel[i].firstName,
                  sched: todaySched,
                );
                timeLogs.addAll(historyListExcel[i].logs);
              }
            } catch (e) {
              debugPrint('$e else out');
            }
          }
        }

        var timeIn1 = '';
        var timeOut1 = '';
        var timeIn2 = '';
        var timeOut2 = '';

        try {
          if (timeLogs.length > 1 &&
              (timeLogs[0].logType == 'OUT' && timeLogs[1].logType == 'IN')) {
            var tempList = <Log>[];
            tempList.add(timeLogs[1]);
            tempList.add(timeLogs[0]);
            timeLogs[0] = tempList[0];
            timeLogs[1] = tempList[1];
          }

          timeIn1 = dateFormat12or24Excel(timeLogs[0].timeStamp);

          if (timeLogs.length >= 2) {
            timeOut1 = dateFormat12or24Excel(timeLogs[1].timeStamp);
          }
          if (timeLogs.length >= 3) {
            timeIn2 = dateFormat12or24Excel(timeLogs[2].timeStamp);
          }
          if (timeLogs.length >= 4) {
            timeOut2 = dateFormat12or24Excel(timeLogs[3].timeStamp);
          }
          if (timeLogs.length == 1) timeOut1 = '';
        } catch (e) {
          debugPrint('$e time slot');
        }

        var employeeId = int.tryParse(historyListExcel[i].employeeId);

        List<dynamic> dataList = [
          rowCountUser,
          employeeId,
          nameIndex(historyListExcel[i]),
          timeIn1,
          timeOut1,
          timeIn2,
          timeOut2,
          duration.hour,
          duration.lateIn,
          duration.lateBreak,
        ];
        result.add(ExcelModel(
          rowCount: rowCountUser.toString(),
          employeeId: historyListExcel[i].employeeId,
          name: nameIndex(historyListExcel[i]),
          timeIn1: timeIn1,
          timeOut1: timeOut1,
          timeIn2: timeIn2,
          timeOut2: timeOut2,
          duration: duration.hour.toString(),
          lateIn: duration.lateIn.toString(),
          lateBreak: duration.lateBreak.toString(),
          scheduleModel: todaySched,
          logs: timeLogs,
        ));
        sheetObject.appendRow(dataList);
      }

      sheetObject.setColWidth(2, 25);

      if (isExcel) {
        excel.save(
            fileName:
                'DTR ${_dateFormatFileExcel.format(selectedFrom)} - ${_dateFormatFileExcel.format(selectedTo)}.xlsx');
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      _excelList = result;
    }
  }

  void reCalcLate({
    required ExcelModel model,
    required ScheduleModel newSchedule,
  }) {
    late LateModel duration;
    try {
      duration = calcDurationInOutSameDay(
        logs: model.logs!,
        name: model.name,
        sched: newSchedule,
      );
      model.duration = duration.hour.toString();
      model.lateIn = duration.lateIn.toString();
      model.lateBreak = duration.lateBreak.toString();
      model.scheduleModel = newSchedule;
    } catch (e) {
      debugPrint('$e');
    }
  }

  void remakeExcel() {
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
        ..value = 'In'
        ..cellStyle = cellStyle;

      var column5 = sheetObject.cell(CellIndex.indexByString('E1'));
      column5
        ..value = 'Out'
        ..cellStyle = cellStyle;

      var column6 = sheetObject.cell(CellIndex.indexByString('F1'));
      column6
        ..value = 'In'
        ..cellStyle = cellStyle;

      var column7 = sheetObject.cell(CellIndex.indexByString('G1'));
      column7
        ..value = 'Out'
        ..cellStyle = cellStyle;

      var column8 = sheetObject.cell(CellIndex.indexByString('H1'));
      column8
        ..value = 'Duration(Hours)'
        ..cellStyle = cellStyle;

      var column10 = sheetObject.cell(CellIndex.indexByString('I1'));
      column10
        ..value = 'Late In(Minutes)'
        ..cellStyle = cellStyle;

      var column11 = sheetObject.cell(CellIndex.indexByString('J1'));
      column11
        ..value = 'Late Break(Minutes)'
        ..cellStyle = cellStyle;

      var column12 = sheetObject.cell(CellIndex.indexByString('K1'));
      column12
        ..value = 'Undertime'
        ..cellStyle = cellStyle;

      var column13 = sheetObject.cell(CellIndex.indexByString('L1'));
      column13
        ..value = 'Tardy'
        ..cellStyle = cellStyle;

      var column14 = sheetObject.cell(CellIndex.indexByString('M1'));
      column14
        ..value = 'Overtime'
        ..cellStyle = cellStyle;

      for (int i = 0; i < _excelList.length; i++) {
        var rowCount = int.tryParse(_excelList[i].rowCount);
        var employeeId = int.tryParse(_excelList[i].employeeId);
        var duration = int.tryParse(_excelList[i].duration);
        var lateIn = int.tryParse(_excelList[i].lateIn);
        var lateBreak = int.tryParse(_excelList[i].lateBreak);

        if (i != 0) {
          List<dynamic> dataList = [
            rowCount,
            employeeId,
            _excelList[i].name,
            _excelList[i].timeIn1,
            _excelList[i].timeOut1,
            _excelList[i].timeIn2,
            _excelList[i].timeOut2,
            duration,
            lateIn,
            lateBreak,
          ];
          sheetObject.appendRow(dataList);
        }
      }

      sheetObject.setColWidth(2, 25);

      excel.save(
          fileName:
              'DTR ${_dateFormatFileExcel.format(selectedFrom)} - ${_dateFormatFileExcel.format(selectedTo)}.xlsx');
    } catch (e) {
      debugPrint('$e remakeExcel');
    }
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
    // debugPrint('calcDurationInOutOtherDay');
    seconds = seconds + 300;
    var hours = Duration(seconds: seconds).inHours;
    var lateIn = Duration(seconds: latePenalty.lateInMinutes).inMinutes;
    var lateBreak = Duration(seconds: latePenalty.lateBreakMinutes).inMinutes;
    return LateModel(
      hour: hours,
      lateIn: lateIn,
      lateBreak: lateBreak,
    );
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
    // debugPrint('calcDurationInOutSameDay');
    seconds = seconds + 300;
    var hours = Duration(seconds: seconds).inHours;
    var lateIn = Duration(seconds: latePenalty.lateInMinutes).inMinutes;
    var lateBreak = Duration(seconds: latePenalty.lateBreakMinutes).inMinutes;
    return LateModel(
      hour: hours,
      lateIn: lateIn,
      lateBreak: lateBreak,
    );
  }

  LateMinutesModel calcLate({
    required List<Log> logs,
    required String name,
    required ScheduleModel sched,
  }) {
    var sIn = sched.schedIn;
    var bEnd = sched.breakEnd;
    var schedIn = '';
    var breakIn = '';
    var latePenaltyIn = 0;
    var latePenaltyBreak = 0;
    try {
      // log('lateIn $name schedType ${sched.schedType} schedIn ${sched.schedIn} breakEnd ${sched.breakEnd}');
      if (sched.schedType.toLowerCase() != 'c') {
        if (logs.length >= 2) {
          if (logs[0].logType == 'IN' && logs[1].logType == 'OUT') {
            // log('${_dateFormat.format(logs[0].timeStamp)} $schedIn');
            schedIn = '${logs[0].timeStamp.toString().substring(0, 10)} $sIn';

            var inDifference = logs[0]
                .timeStamp
                .difference(_dateFormat
                    .parse(schedIn)
                    .add(const Duration(seconds: 300)))
                .inSeconds;
            // var differenceSec = Duration(seconds: inDifference).inSeconds;

            // late
            if (inDifference > 0) {
              latePenaltyIn = latePenaltyIn + inDifference + 300;
            }
            // var lateIn = Duration(seconds: latePenaltyIn).inMinutes;
            // log('lateIn $name $differenceSec seconds $lateIn minutes');
          }
          if (logs.length >= 4 && sched.schedType.toLowerCase() == 'b') {
            if (logs[2].logType == 'IN' && logs[3].logType == 'OUT') {
              // log('${_dateFormat.format(logs[2].timeStamp)} $breakIn');
              breakIn =
                  '${logs[2].timeStamp.toString().substring(0, 10)} $bEnd';

              var inDifference = logs[2]
                  .timeStamp
                  .difference(_dateFormat
                      .parse(breakIn)
                      .add(const Duration(seconds: 300)))
                  .inSeconds;
              // var differenceSec = Duration(seconds: inDifference).inSeconds;

              // late
              if (inDifference > 0) {
                latePenaltyBreak = latePenaltyBreak + inDifference + 300;
              }
              // var lateBreak = Duration(seconds: latePenaltyBreak).inMinutes;
              // log('lateBreak $name $differenceSec seconds $lateBreak minutes');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('$e calcLate');
    }
    return LateMinutesModel(
      lateInMinutes: latePenaltyIn,
      lateBreakMinutes: latePenaltyBreak,
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

  Future<void> getSchedule() async {
    try {
      final result = await HttpService.geSchedule();
      _scheduleList.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }
}
