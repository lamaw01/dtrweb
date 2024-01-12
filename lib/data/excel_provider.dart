// ignore_for_file: unused_import

import 'dart:developer';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/clean_data_model.dart';
import '../model/clean_excel_model.dart';
import '../model/history_model.dart';
import '../model/late_model.dart';
import '../model/log_model.dart';
import '../model/schedule_model.dart';

class ExcelProvider with ChangeNotifier {
  var _cleanData = <CleanDataModel>[];
  List<CleanDataModel> get cleanData => _cleanData;

  final _cleanExcelData = <CleanExcelDataModel>[];
  List<CleanExcelDataModel> get cleanExcelData => _cleanExcelData;

  final _is24HourFormat = ValueNotifier(false);
  final _dateFormat1 = DateFormat('yyyy-MM-dd HH:mm');
  DateFormat get dateFormat1 => _dateFormat1;

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

  bool isEvening(CleanDataModel c) {
    if (c.currentSched.schedId.substring(0, 1).toUpperCase() == 'E') {
      return true;
    }
    return false;
  }

  String dateFormat12or24Excel(DateTime dateTime) {
    if (_is24HourFormat.value) {
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd hh:mm aa').format(dateTime);
    }
  }

  String formatPrettyDate(DateTime? d) {
    if (d == null) {
      return '';
    }
    return dateFormat12or24Excel(d);
  }

  //assign historylist to cleandata
  void sortData({
    required List<ScheduleModel> scheduleList,
    required List<HistoryModel> historyList,
  }) {
    var dayOfWeek = DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    _cleanData.clear();

    for (int i = 0; i < historyList.length; i++) {
      var todaySched = scheduleList.singleWhere((element) =>
          element.schedId == selectDay(day: dayOfWeek, model: historyList[i]));

      _cleanData.add(
        CleanDataModel(
          employeeId: historyList[i].employeeId,
          firstName: historyList[i].firstName,
          lastName: historyList[i].lastName,
          middleName: historyList[i].middleName,
          currentSched: todaySched,
          date: historyList[i].date,
          logs: historyList[i].logs,
        ),
      );
    }

    cleanseData();
  }

  //clean data
  void cleanseData() {
    try {
      if (isEvening(_cleanData.first)) {
        arrangeDataEvening();
      }
      // for (int i = 0; i < _cleanData.length; i++) {
      //   if (isEvening(_cleanData[i])) {
      //     var resultdayClean = eveningCleanData(i: i, c: _cleanData);
      //     _cleanData.addAll(resultdayClean);
      //   } else {
      //     var resultdayClean = dayCleanData(i: i, c: _cleanData);
      //     _cleanData.addAll(resultdayClean);
      //   }
      // }
      calcLogs(_cleanData);
      finalizeData(_cleanData);
    } catch (e) {
      debugPrint('$e cleanseData1');
    }
  }

  void arrangeDataEvening() {
    if (_cleanData.length == 1) {
      _cleanData.clear();
      return;
    }

    for (int i = 0; i < _cleanData.length; i++) {
      if (i == 0) {
        var logs = <Log>[];
        try {
          if (_cleanData[i].logs.last.logType == 'IN') {
            logs.add(_cleanData[i].logs.last);
            if (_cleanData[i + 1].logs.length >= 4) {
              final removedLastLogIndex =
                  _cleanData[i + 1].logs.reversed.skip(1);
              var logsTemp = <Log>[];
              logsTemp.addAll(removedLastLogIndex);
              logs.addAll(logsTemp.reversed);
            } else {
              logs.addAll(_cleanData[i + 1].logs);
            }
          }
        } catch (e) {
          debugPrint('$e if');
        }
        _cleanData[i].logs = logs;
      } else if (i == _cleanData.length - 1) {
        try {
          _cleanData.removeLast();
        } catch (e) {
          debugPrint('$e else if');
        }
      } else {
        var logs = <Log>[];
        try {
          if (_cleanData[i].logs.last.logType == 'IN') {
            logs.add(_cleanData[i].logs.last);
            if (_cleanData[i + 1].logs.length >= 4) {
              final removedLastLogIndex =
                  _cleanData[i + 1].logs.reversed.skip(1);
              var logsTemp = <Log>[];
              logsTemp.addAll(removedLastLogIndex);
              logs.addAll(logsTemp.reversed);
            } else {
              logs.addAll(_cleanData[i + 1].logs);
            }
          }
        } catch (e) {
          debugPrint('$e else');
        }
        _cleanData[i].logs = logs;
      }
    }

    for (int i = 0; i < _cleanData.length; i++) {
      for (int j = 0; j < _cleanData[i].logs.length; j++) {
        log("${_cleanData[i].logs[j].logType} ${_cleanData[i].logs[j].timeStamp}");
      }
      log('--------');
    }

    _cleanData.removeWhere((e) => e.logs.isEmpty);
  }

  LateMinutesModel calcLate({
    required List<Log> logs,
    required String name,
    required ScheduleModel sched,
  }) {
    var sIn = sched.schedIn;
    // var bS = sched.breakStart;
    var bEnd = sched.breakEnd;
    var sOut = sched.schedOut;
    var schedIn = ''; //0
    // var breakStart = ''; //1
    var breakEnd = ''; //2
    var schedOut = ''; //3
    var latePenaltyIn = 0;
    var latePenaltyBreak = 0;
    var overtime = 0;
    // var undertimeIn = 0;
    // var undertimeBreak = 0;
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
              breakEnd =
                  '${logs[2].timeStamp.toString().substring(0, 10)} $bEnd';
              var inDifference = logs[2]
                  .timeStamp
                  .difference(_dateFormat1
                      .parse(breakEnd)
                      .add(const Duration(seconds: 300)))
                  .inSeconds;
              // late
              if (inDifference > 0) {
                latePenaltyBreak = latePenaltyBreak + inDifference + 300;
              }
            }
          }

          //calc overtime & undertime
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

          // if (logs.length == 2) {
          //   schedOut =
          //       '${logs[1].timeStamp.toString().substring(0, 10)} $sOut'; //1
          //   undertimeBreak = _dateFormat1
          //       .parse(schedOut)
          //       .difference(logs[1].timeStamp)
          //       .inSeconds;
          //   if (undertimeBreak < 0) undertimeBreak = 0;
          // } else if (logs.length == 4) {
          //   breakStart =
          //       '${logs[1].timeStamp.toString().substring(0, 10)} $bS'; //2
          //   undertimeIn = _dateFormat1
          //       .parse(breakStart)
          //       .difference(logs[1].timeStamp)
          //       .inSeconds;

          //   schedOut =
          //       '${logs[3].timeStamp.toString().substring(0, 10)} $sOut'; //3
          //   undertimeBreak = _dateFormat1
          //       .parse(schedOut)
          //       .difference(logs[3].timeStamp)
          //       .inSeconds;
          //   if (undertimeIn < 0) undertimeIn = 0;
          //   if (undertimeBreak < 0) undertimeBreak = 0;
          // }
        }
      }
    } catch (e) {
      debugPrint('$e calcLate');
      // errorString.value = e.toString();
    }
    return LateMinutesModel(
      lateInMinutes: latePenaltyIn,
      lateBreakMinutes: latePenaltyBreak,
      overtimeSeconds: overtime,
      // undertimeInMinutes: undertimeIn,
      // undertimeBreakMinutes: undertimeBreak,
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
      // errorString.value = e.toString();
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
    // var undertimeIn =
    //     Duration(seconds: latePenalty.undertimeInMinutes).inMinutes;
    // var undertimeBreak =
    //     Duration(seconds: latePenalty.undertimeBreakMinutes).inMinutes;

    return LateModel(
      hour: hours,
      lateIn: lateIn,
      lateBreak: lateBreak,
      overtime: overtime,
      // undertimeIn: undertimeIn,
      // undertimelateBreak: undertimeBreak,
    );
  }

  String calcOvertimeHour(int overtime, String name, {DateTime? dt}) {
    var finalOtString = '';
    try {
      var overtimeDouble = overtime / 60;
      var overtimeDoubleString = overtimeDouble.toStringAsFixed(1);
      var rounderDigit = overtimeDouble.toStringAsFixed(1).substring(2, 3);
      var rd = overtimeDouble.toStringAsFixed(1).substring(0, 1);

      if (double.tryParse(rounderDigit) == null) {
        rounderDigit = rd;
        if (double.parse(rounderDigit) >= 5) {
          finalOtString = overtimeDoubleString.replaceRange(3, 4, '5');
        } else {
          finalOtString = overtimeDoubleString.replaceRange(3, 4, '0');
        }
      } else {
        if (double.parse(rounderDigit) >= 5) {
          finalOtString = overtimeDoubleString.replaceRange(2, 3, '5');
        } else {
          finalOtString = overtimeDoubleString.replaceRange(2, 3, '0');
        }
      }

      if (overtimeDouble < 0.5) {
        finalOtString = '0';
      }
    } catch (e) {
      debugPrint('$e calcOvertimeHour $overtime $name $dt');
      // errorString.value = e.toString();
    }
    return finalOtString;
  }

  void calcLogs(List<CleanDataModel> c) {
    try {
      for (int i = 0; i < c.length; i++) {
        var duration = calcDurationInOutSameDay(
          logs: c[i].logs,
          name: c[i].firstName,
          sched: c[i].currentSched,
        );

        var finalOtString =
            calcOvertimeHour(duration.overtime, c[i].firstName, dt: c[i].date);
        c[i].duration = duration.hour.toString();
        c[i].lateIn = duration.lateIn.toString();
        c[i].lateBreak = duration.lateBreak.toString();
        c[i].overtime = finalOtString;
        // c[i].undertimeIn = duration.undertimeIn.toString();
        // c[i].undertimeBreak = duration.undertimelateBreak.toString();
      }
      _cleanData = c;
    } catch (e) {
      debugPrint('$e calcLogs');
      // errorString.value = e.toString();
    }
  }

  void finalizeData(List<CleanDataModel> c) {
    _cleanExcelData.clear();
    var count = 0;
    try {
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
              // undertimeIn: '',
              // undertimeBreak: '',
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
            // undertimeIn: c[i].undertimeIn!,
            // undertimeBreak: c[i].undertimeBreak!,
            rowCount: '$count',
            in1: TimeLog(),
            out1: TimeLog(),
            in2: TimeLog(),
            out2: TimeLog(),
          ),
        );
      }
      for (var cxd in _cleanExcelData) {
        // ignore: prefer_is_empty
        if (cxd.logs.length >= 1) {
          cxd.in1.timestamp = formatPrettyDate(cxd.logs[0].timeStamp);
          cxd.in1.isSelfie = cxd.logs[0].isSelfie;
          cxd.in1.id = cxd.logs[0].id;
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
        if (cxd.duration == '0') cxd.duration = '';
        if (cxd.lateIn == '0') cxd.lateIn = '';
        if (cxd.lateBreak == '0') cxd.lateBreak = '';
        if (cxd.overtime == '0') cxd.overtime = '';
        // if (cxd.undertimeIn == '0') cxd.undertimeIn = '';
        // if (cxd.undertimeBreak == '0') cxd.undertimeBreak = '';
      }
    } catch (e) {
      debugPrint('$e finalizeData');
      // errorString.value = e.toString();
    }
  }

  bool isInCloseEvening(CleanDataModel c) {
    var differenceForgotOut = 0;
    try {
      if (c.logs.length > 2 &&
          c.logs[1].logType == 'IN' &&
          c.logs[2].logType == 'OUT') {
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
      // errorString.value = e.toString();
    }
    return false;
  }

  bool isForgotOut(CleanDataModel c) {
    var differenceForgotOut = 0;
    try {
      if (c.logs.length > 1 &&
          c.logs[0].logType == 'OUT' &&
          c.logs[1].logType == 'IN') {
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
      // errorString.value = e.toString();
    }
    return false;
  }

  String fullName(CleanDataModel c) {
    return '${c.lastName}, ${c.firstName} ${c.middleName}';
  }

  CleanExcelDataModel reCalcLateModel({
    required CleanExcelDataModel model,
    required ScheduleModel newSchedule,
  }) {
    var duration = LateModel(
      hour: 0,
      lateIn: 0,
      lateBreak: 0,
      overtime: 0,
      // undertimeIn: 0,
      // undertimelateBreak: 0
    );
    try {
      duration = calcDurationInOutSameDay(
        logs: model.logs,
        name: model.name,
        sched: newSchedule,
      );
      var finalOtString = calcOvertimeHour(duration.overtime, model.name);
      model.duration = duration.hour.toString();
      model.lateIn = duration.lateIn.toString();
      model.lateBreak = duration.lateBreak.toString();
      model.overtime = finalOtString;
      // model.undertimeIn = duration.undertimeIn.toString();
      // model.undertimeBreak = duration.undertimelateBreak.toString();
      model.currentSched = newSchedule;
      if (model.duration == '0') model.duration = '';
      if (model.lateIn == '0') model.lateIn = '';
      if (model.lateBreak == '0') model.lateBreak = '';
      if (model.overtime == '0') model.overtime = '';
      // if (model.undertimeIn == '0') model.undertimeIn = '';
      // if (model.undertimeBreak == '0') model.undertimeBreak = '';
    } catch (e) {
      debugPrint('$e reCalcLate');
      // errorString.value = e.toString();
    }
    return model;
  }

  CleanExcelDataModel reCalcNewTime({required CleanExcelDataModel model}) {
    try {
      var duration = calcDurationInOutSameDay(
        logs: model.logs,
        name: model.name,
        sched: model.currentSched,
      );
      var finalOtString = calcOvertimeHour(duration.overtime, model.name);
      model.duration = duration.hour.toString();
      model.lateIn = duration.lateIn.toString();
      model.lateBreak = duration.lateBreak.toString();
      model.overtime = finalOtString;
      // model.undertimeIn = duration.undertimeIn.toString();
      // model.undertimeBreak = duration.undertimelateBreak.toString();
      if (model.duration == '0') model.duration = '';
      if (model.lateIn == '0') model.lateIn = '';
      if (model.lateBreak == '0') model.lateBreak = '';
      if (model.overtime == '0') model.overtime = '';
      // if (model.undertimeIn == '0') model.undertimeIn = '';
      // if (model.undertimeBreak == '0') model.undertimeBreak = '';
    } catch (e) {
      debugPrint('$e reCalcLate');
      // errorString.value = e.toString();
    }
    return model;
  }

  List<CleanDataModel> dayCleanData({
    required int i,
    required List<CleanDataModel> c,
  }) {
    final dayCleanData = <CleanDataModel>[];
    bool isSoloOut = false;
    if (i == 0) {
      try {
        var logs = <Log>[];
        if (c[i].logs.first.logType == 'OUT' && c[i].logs.length > 1) {
          for (int k = 1; k < c[i].logs.length; k++) {
            if (c[i].logs[k].logType != c[i].logs[k - 1].logType) {
              logs.add(c[i].logs[k]);
            }
            // logs.add(c[i].logs[k]);
          }
        } else if (c[i].logs.length == 1 && c[i].logs.first.logType == 'IN') {
          logs.add(c[i].logs.first);
        } else if (c[i].logs.length == 1 && c[i].logs.first.logType == 'OUT') {
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
        debugPrint('if m $e');
      }
    } else if (i == c.length - 1) {
      try {
        var logs = <Log>[];

        if (c[i].logs.first.logType == 'OUT' && c[i].logs.length > 3) {
          for (int k = 1; k < c[i].logs.length; k++) {
            if (c[i].logs[k].logType != c[i].logs[k - 1].logType) {
              logs.add(c[i].logs[k]);
            }
          }
        } else if (c[i].logs.length == 1 && c[i].logs.first.logType == 'OUT') {
          isSoloOut = true;
        } else if (c[i].logs.length == 1 && c[i].logs.first.logType == 'IN') {
          logs.add(c[i].logs.first);
        } else if (c[i].logs.length == 2 &&
            c[i].logs.first.logType == 'IN' &&
            c[i].logs.last.logType == 'OUT') {
          logs.addAll(c[i].logs);
        } else if (c[i].logs.length < 4 && c[i].logs.first.logType == 'OUT') {
          logs.addAll(c[i].logs.sublist(1));
        } else if (c[i].logs.length > 3 && c[i].logs.first.logType == 'IN') {
          // logs.addAll(c[i].logs);
          // for (int k = 0; k < c[i].logs.length; k++) {
          //   if (k > 0 && c[i].logs[k].logType != c[i].logs[k - 1].logType) {
          //     logs.add(c[i].logs[k]);
          //   }
          // }
          for (int k = 0; k < c[i].logs.length; k++) {
            if (k > 0 && c[i].logs[k].logType != c[i].logs[k - 1].logType) {
              logs.add(c[i].logs[k]);
            } else if (k == 0) {
              logs.add(c[i].logs[k]);
            }
          }
        } else if (c[i].logs.length == 3 &&
            c[i].logs.first.logType == 'IN' &&
            c[i].logs.last.logType == 'IN') {
          logs.addAll(c[i].logs);
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
        debugPrint('else if m $e');
      }
    } else {
      try {
        if (c[i].logs.last.logType == 'IN') {
          var logs = <Log>[];
          if (fullName(c[i]) == fullName(c[i + 1])) {
            if (isForgotOut(c[i + 1])) {
              logs.add(c[i].logs.last);
            } else if (c[i].logs.length < 4 &&
                c[i].logs.length > 1 &&
                c[i].logs.first.logType == 'IN') {
              // logs.add(c[i].logs[0]);
              logs.add(c[i].logs.last);
              logs.add(c[i].logs[1]);
            } else if (c[i + 1].logs.length == 1 &&
                c[i + 1].logs.first.logType == 'OUT') {
              logs.add(c[i].logs.last);
            } else if (c[i].logs.length == 1 &&
                c[i].logs.first.logType == 'IN' &&
                c[i + 1].logs.first.logType == 'IN') {
              logs.add(c[i].logs.last);
            } else if (c[i].logs.length >= 4 &&
                c[i].logs.first.logType == 'OUT') {
              logs.addAll(c[i].logs.skip(1));
            } else {
              // logs.add(c[i].logs.last);
              logs.add(c[i].logs.last);
              logs.add(c[i + 1].logs.first);
            }
          } else if (c[i].logs.length == 1 &&
              c[i].logs.first.logType == 'IN' &&
              fullName(c[i]) == fullName(c[i - 1])) {
            logs.add(c[i].logs.last);
          } else if (c[i].logs.length == 2 &&
              c[i].logs.first.logType == 'OUT') {
            logs.add(c[i].logs.last);
          } else if (c[i].logs.length == 3 &&
              c[i].logs.first.logType == 'IN' &&
              c[i].logs.last.logType == 'IN') {
            logs.addAll(c[i].logs);
          }

          if (logs.isNotEmpty) {
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
        } else {
          var logs = <Log>[];
          if (c[i].logs.first.logType == 'OUT' && c[i].logs.length > 2) {
            for (int k = 1; k < c[i].logs.length; k++) {
              if (c[i].logs[k].logType != c[i].logs[k - 1].logType) {
                logs.add(c[i].logs[k]);
              }
            }
          } else if (c[i].logs.length == 1 &&
              c[i].logs.first.logType == 'OUT') {
            isSoloOut = true;
          } else if (c[i].logs.length == 2 &&
              c[i].logs.first.logType == 'IN' &&
              c[i].logs.last.logType == 'OUT') {
            logs.addAll(c[i].logs);
          } else if (c[i].logs.length > 3) {
            // logs.addAll(c[i].logs);
            for (int k = 0; k < c[i].logs.length; k++) {
              if (k > 0 && c[i].logs[k].logType != c[i].logs[k - 1].logType) {
                logs.add(c[i].logs[k]);
              } else if (k == 0) {
                logs.add(c[i].logs[k]);
              }
            }
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
        debugPrint('else m $e');
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
        bool isSoloOut = false;
        // if (c[i].logs.first.logType == 'OUT' && c[i].logs.length > 1) {
        //   for (int k = 0; k < c[i].logs.length; k++) {
        //     logs.add(c[i].logs[k]);
        //   }
        // } else

        if (c[i].logs.first.logType == 'IN' && c[i].logs.length == 1) {
          logs.add(c[i].logs.first);
          logs.add(c[i + 1].logs.first);
          if (isInCloseEvening(c[i + 1])) {
            logs.add(c[i + 1].logs[1]);
            logs.add(c[i + 1].logs[2]);
          }
        } else if (c[i].logs.length >= 3 &&
            c[i].logs.first.logType == 'OUT' &&
            c[i].logs.last.logType == 'IN') {
          logs.add(c[i].logs.last);

          if (c[i + 1].logs.length == 1) {
            logs.add(c[i + 1].logs.last);
          } else if (c[i + 1].logs.length > 3 &&
              c[i].logs.last.logType == 'IN') {
            logs.addAll(c[i + 1].logs.sublist(0, 3));
          } else {
            logs.addAll(c[i + 1].logs);
          }
        } else if (c[i].logs.first.logType == 'OUT' && c[i].logs.length == 1) {
          isSoloOut = true;
        } else if (c[i].logs.first.logType == 'OUT' &&
            c[i].logs.last.logType == 'IN' &&
            c[i].logs.length == 2) {
          logs.add(c[i].logs.last);
          if (c[i + 1].logs.length >= 3 &&
              c[i + 1].logs[0].logType == 'OUT' &&
              c[i + 1].logs[2].logType == 'OUT') {
            logs.addAll(
              c[i + 1].logs.getRange(0, 3),
            );
          }
        }
        //  else {
        // logs.addAll(c[i].logs);
        // logs.add(c[i].logs.last);
        // }
        else if (c[i].logs.length == 4) {
          logs.add(c[i].logs.last);
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
        debugPrint('if e $e');
      }
    } else if (i == c.length - 1) {
      try {
        var logs = <Log>[];
        bool isSoloOut = false;

        if (c[i].logs.length == 1 && c[i].logs.first.logType == 'OUT') {
          logs.add(c[i].logs.first);
          isSoloOut = true;
        }
        // else if (c[i].logs.length > 3 && c[i].logs.first.logType == 'OUT') {
        // logs.addAll(c[i].logs.sublist(1));
        // }
        else if (c[i].logs.length < 4 && c[i].logs.last.logType == 'OUT') {
          isSoloOut = true;
        } else if (c[i].logs.length == 3 &&
            c[i].logs.first.logType == 'OUT' &&
            c[i].logs.last.logType == 'OUT') {
          logs.addAll(c[i].logs);
          // isSoloOut = true;
        } else if (c[i].logs.length == 2 && c[i].logs.first.logType == 'OUT') {
          logs.add(c[i].logs.last);
        } else if (c[i].logs.length == 4 &&
            c[i].logs.first.logType == 'OUT' &&
            c[i].logs.last.logType == 'IN') {
          logs.add(c[i].logs.last);
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
        debugPrint('else if e $e');
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
              c[i + 1].logs.last.logType == 'IN' &&
              fullName(c[i]) == fullName(c[i + 1])) {
            logs.addAll(c[i + 1].logs.sublist(0, 3));
          } else if (c[i + 1].logs.length == 1 &&
              c[i + 1].logs.first.logType == 'OUT' &&
              fullName(c[i]) == fullName(c[i + 1])) {
            logs.add(c[i + 1].logs.first);
          } else if (c[i + 1].logs.length == 3 &&
              c[i + 1].logs.first.logType == 'OUT' &&
              c[i + 1].logs.last.logType == 'OUT' &&
              c[i].logs.length == 1 &&
              fullName(c[i]) == fullName(c[i + 1])) {
            logs.add(c[i + 1].logs.first);
          } else if (c[i + 1].logs.length == 3 &&
              c[i + 1].logs.first.logType == 'OUT' &&
              c[i + 1].logs.last.logType == 'OUT' &&
              fullName(c[i]) == fullName(c[i + 1])) {
            logs.addAll(c[i + 1].logs);
          } else {
            if (fullName(c[i]) == fullName(c[i + 1])) {
              logs.add(c[i + 1].logs.first);
            }
          }
        } else if (c[i].logs.length == 1 && c[i].logs.last.logType == 'IN') {
          logs.add(c[i].logs.last);
          if (c[i + 1].logs.length > 3 &&
              c[i + 1].logs.first.logType == 'OUT' &&
              c[i + 1].logs.last.logType == 'IN' &&
              fullName(c[i]) == fullName(c[i + 1])) {
            logs.addAll(c[i + 1].logs.sublist(0, 3));
          } else if (c[i + 1].logs.length == 2 &&
              c[i + 1].logs.first.logType == 'OUT' &&
              c[i + 1].logs.last.logType == 'IN' &&
              fullName(c[i]) == fullName(c[i + 1])) {
            logs.add(c[i + 1].logs.first);
          } else if (c[i + 1].logs.length < 4 &&
              c[i + 1].logs.first.logType == 'OUT' &&
              fullName(c[i]) == fullName(c[i + 1])) {
            // logs.add(c[i + 1].logs.first);
            logs.addAll(c[i + 1].logs);
          }
        } else if (c[i].logs.first.logType == 'OUT' &&
            c[i].logs.last.logType == 'IN' &&
            c[i].logs.length == 2) {
          logs.add(c[i].logs.last);
          if (c[i + 1].logs.length >= 3 &&
              c[i + 1].logs[0].logType == 'OUT' &&
              c[i + 1].logs[2].logType == 'OUT' &&
              fullName(c[i]) == fullName(c[i + 1])) {
            logs.addAll(
              c[i + 1].logs.getRange(0, 3),
            );
          }
        } else if (c[i].logs.length == 1 && c[i].logs.first.logType == 'OUT') {
          isSoloOut = true;
        } else if (c[i].logs.length < 4 && c[i].logs.last.logType == 'OUT') {
          isSoloOut = true;
        } else if (c[i].logs.length < 4 &&
            c[i].logs.first.logType == 'OUT' &&
            c[i + 1].logs.first.logType == 'OUT') {
          logs.addAll(c[i].logs.sublist(1));
          logs.add(c[i + 1].logs.first);
          if (i + 1 == c.length - 1 &&
              c[i + 1].logs.first.logType == 'OUT' &&
              c[i + 1].logs.last.logType == 'OUT' &&
              c[i + 1].logs.length == 3 &&
              fullName(c[i]) == fullName(c[i + 1])) {
            logs.addAll(c[i + 1].logs);
          }
        } else if (c[i].logs.length < 4 &&
            c[i].logs.last.logType == 'OUT' &&
            fullName(c[i]) != fullName(c[i + 1])) {
          isSoloOut = true;
        } else if (c[i].logs.length == 3 &&
            c[i].logs.first.logType == 'OUT' &&
            c[i].logs.last.logType == 'OUT') {
          isSoloOut = true;
        } else if (c[i].logs.length == 3 &&
            c[i].logs.first.logType == 'IN' &&
            c[i].logs.last.logType == 'IN') {
          logs.addAll(c[i].logs);
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
        debugPrint('else e $e');
      }
    }
    return dayCleanData;
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
        ..value = 'd(h)'
        ..cellStyle = cellStyle;

      var column7 = sheetObject.cell(CellIndex.indexByString('G1'));
      column7
        ..value = 't'
        ..cellStyle = cellStyle;

      var column8 = sheetObject.cell(CellIndex.indexByString('H1'));
      column8
        ..value = 'bt'
        ..cellStyle = cellStyle;

      var column9 = sheetObject.cell(CellIndex.indexByString('I1'));
      column9
        ..value = 'ot'
        ..cellStyle = cellStyle;

      var column10 = sheetObject.cell(CellIndex.indexByString('J1'));
      column10
        ..value = 'ut'
        ..cellStyle = cellStyle;

      // var column11 = sheetObject.cell(CellIndex.indexByString('K1'));
      // column11
      //   ..value = 'ut2'
      //   ..cellStyle = cellStyle;

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
        // var undertimeIn = int.tryParse(_cleanExcelData[i].undertimeIn);
        // var undertimeBreak = int.tryParse(_cleanExcelData[i].undertimeBreak);

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
          '',
          // undertimeIn,
          // undertimeBreak,
        ];
        sheetObject.appendRow(dataList);
        sheetObject.setColWidth(0, 25.70);
        sheetObject.setColWidth(1, 15.70);
        sheetObject.setColWidth(2, 15.71);
        sheetObject.setColWidth(3, 15.72);
        sheetObject.setColWidth(4, 15.73);
        sheetObject.setColWidth(5, 3.50);
        sheetObject.setColWidth(6, 3.51);
        sheetObject.setColWidth(7, 4.10);
        sheetObject.setColWidth(8, 3.53);
        sheetObject.setColWidth(9, 3.54);
        // sheetObject.setColWidth(10, 3.55);

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
        // sheetObject.updateCell(
        //   CellIndex.indexByColumnRow(
        //     columnIndex: 10,
        //     rowIndex: i,
        //   ),
        //   undertimeBreak,
        //   cellStyle: cellStyleData,
        // );
      }
      excel.save(fileName: 'DTR-excel.xlsx');
    } catch (e) {
      debugPrint('exportExcel $e');
      // errorString.value = e.toString();
    }
  }
}
