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
import '../services/http_service.dart';
import '../view/home_view.dart';

class ExcelProvider with ChangeNotifier {
  // final _cleanData = <CleanDataModel>[];
  // List<CleanDataModel> get cleanData => _cleanData;

  final _cleanExcelData = <CleanExcelDataModel>[];
  List<CleanExcelDataModel> get cleanExcelData => _cleanExcelData;

  // final _is24HourFormat = ValueNotifier(false);
  final _dateFormat1 = DateFormat('yyyy-MM-dd HH:mm');
  DateFormat get dateFormat1 => _dateFormat1;

  var _lateThreshold = 300;
  int get lateThreshold => _lateThreshold;

  // String selectDay({required String day, required HistoryModel model}) {
  //   switch (day) {
  //     case 'monday':
  //       return model.monday;
  //     case 'tuesday':
  //       return model.tuesday;
  //     case 'wednesday':
  //       return model.wednesday;
  //     case 'thursday':
  //       return model.thursday;
  //     case 'friday':
  //       return model.friday;
  //     case 'saturday':
  //       return model.saturday;
  //     default:
  //       return model.sunday;
  //   }
  // }

  Future<void> getSettings() async {
    try {
      final result = await HttpService.getSettings();
      _lateThreshold = result.lateThreshold;
    } catch (e) {
      debugPrint('$e getSettings');
    }
  }

  bool isMorning(CleanDataModel c) {
    if (c.currentSched.schedId.substring(0, 1).toUpperCase() != 'E') {
      return true;
    }
    return false;
  }

  String dateFormat12or24Excel(DateTime dateTime) {
    if (is24HourFormat.value) {
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

  // String dateFormat12or24Web(DateTime dateTime) {
  //   if (_is24HourFormat.value) {
  //     return DateFormat('HH:mm').format(dateTime);
  //   } else {
  //     return DateFormat('hh:mm aa').format(dateTime);
  //   }
  // }

  List<List<HistoryModel>> disectHistory(List<HistoryModel> historyList) {
    historyList.sort((a, b) {
      var valueA = '${a.employeeId} ${a.date}';
      var valueB = '${b.employeeId} ${b.date}';
      return valueA.compareTo(valueB);
    });

    final List<String> listOfUniqueId = <String>[];

    var listOfListHistory = <List<HistoryModel>>[];

    HistoryModel initialIndex = historyList.first;
    int counterOfUniqueId = 1;
    int indexOfLastCut = 0;

    listOfUniqueId.add(initialIndex.employeeId);

    for (int i = 0; i < historyList.length; i++) {
      if (initialIndex.employeeId != historyList[i].employeeId) {
        counterOfUniqueId++;
        initialIndex = historyList[i];
        listOfUniqueId.add(historyList[i].employeeId);
        // log('sublist length ${historyList.sublist(indexOfLastCut, i).length}');
        listOfListHistory.add(historyList.sublist(indexOfLastCut, i));
        indexOfLastCut = i;
      }
    }

    listOfListHistory
        .add(historyList.sublist(indexOfLastCut, historyList.length));

    log('counterOfUniqueId $counterOfUniqueId listOfListHistory ${listOfListHistory.length}');

    // for (int i = 0; i < listOfListHistory.length; i++) {
    //   for (int j = 0; j < listOfListHistory[i].length; j++) {
    //     log('2d ${listOfListHistory[i][j].employeeId} ${listOfListHistory[i].length}');
    //   }
    // }
    return listOfListHistory;
  }

  //assign historylist to cleandata
  void sortData({
    required List<ScheduleModel> scheduleList,
    required List<HistoryModel> historyList,
  }) {
    // _cleanData.clear();

    final disectedHistory = disectHistory(historyList);

    // for (int i = 0; i < historyList.length; i++) {
    //   late ScheduleModel todaySched;

    //   try {
    //     todaySched = scheduleList.singleWhere(
    //         (element) => element.schedId == historyList[i].currentSchedId);
    //   } catch (e) {
    //     // debugPrint('$e sortData');
    //     todaySched = scheduleList.singleWhere(
    //         (element) => element.schedId == 'M-B-85'); //E-B-96 M-B-85
    //   } finally {
    //     _cleanData.add(
    //       CleanDataModel(
    //         employeeId: historyList[i].employeeId,
    //         firstName: historyList[i].firstName,
    //         lastName: historyList[i].lastName,
    //         middleName: historyList[i].middleName,
    //         currentSched: todaySched,
    //         date: historyList[i].date,
    //         logs: historyList[i].logs,
    //       ),
    //     );
    //   }
    // }

    var listOfListCleanData = <List<CleanDataModel>>[];

    for (int i = 0; i < disectedHistory.length; i++) {
      var listCleanData = <CleanDataModel>[];

      for (int j = 0; j < disectedHistory[i].length; j++) {
        late ScheduleModel todaySched;
        try {
          todaySched = scheduleList.singleWhere((element) =>
              element.schedId == disectedHistory[i][j].currentSchedId);
        } catch (e) {
          // debugPrint('$e sortData');
          todaySched = scheduleList.singleWhere(
              (element) => element.schedId == 'M-B-85'); //E-B-96 M-B-85
        } finally {
          listCleanData.add(CleanDataModel(
            employeeId: disectedHistory[i][j].employeeId,
            firstName: disectedHistory[i][j].firstName,
            lastName: disectedHistory[i][j].lastName,
            middleName: disectedHistory[i][j].middleName,
            currentSched: todaySched,
            date: disectedHistory[i][j].date,
            logs: disectedHistory[i][j].logs,
          ));
          // _cleanData.add(CleanDataModel(
          //   employeeId: disectedHistory[i][j].employeeId,
          //   firstName: disectedHistory[i][j].firstName,
          //   lastName: disectedHistory[i][j].lastName,
          //   middleName: disectedHistory[i][j].middleName,
          //   currentSched: todaySched,
          //   date: disectedHistory[i][j].date,
          //   logs: disectedHistory[i][j].logs,
          // ));
        }
      }
      listOfListCleanData.add(listCleanData);
      log('sortData ${listOfListCleanData[i].length}');
    }

    // cleanseData();
    cleanseData2(listOfListCleanData);
  }

  void cleanseData2(List<List<CleanDataModel>> listOfListCleanData) {
    try {
      int counter = 0;
      for (int i = 0; i < listOfListCleanData.length; i++) {
        for (int j = 0; j < listOfListCleanData[i].length; j++) {
          counter++;
          List<Log> cleanLog = [];
          if (isMorning(listOfListCleanData[i][j])) {
            cleanLog = arrangeDataMorning2(listOfListCleanData[i][j]);
          } else {
            cleanLog = arrangeDataEvening2(listOfListCleanData[i], i);
          }
          listOfListCleanData[i][j].logs = cleanLog;
          listOfListCleanData[i][j] = calcLogs2(listOfListCleanData[i][j]);
        }
        listOfListCleanData[i].removeWhere((e) => e.logs.isEmpty);
      }
      // _cleanData.removeWhere((e) => e.logs.isEmpty);
      // calcLogs();
      // finalizeData();
      log('cleanseData2 $counter');
      finalizeData2(listOfListCleanData);
    } catch (e) {
      debugPrint('$e cleanseData2');
    }
  }

  // //clean data
  // void cleanseData() {
  //   try {
  //     for (int i = 0; i < _cleanData.length; i++) {
  //       if (isMorning(_cleanData[i])) {
  //         arrangeDataMorning(i);
  //       } else {
  //         arrangeDataEvening(i);
  //       }
  //     }
  //     _cleanData.removeWhere((e) => e.logs.isEmpty);
  //     calcLogs();
  //     finalizeData();
  //   } catch (e) {
  //     debugPrint('$e cleanseData');
  //   }
  // }

  List<Log> arrangeDataEvening2(List<CleanDataModel> model, i) {
    if (i == 0) {
      var logs = <Log>[];
      try {
        if (model[i].logs.last.logType == 'IN') {
          logs.add(model[i].logs.last);
          if (model[i + 1].logs.length >= 4) {
            final removedLastLogIndex = model[i + 1].logs.reversed.skip(1);
            var logsTemp = <Log>[];
            logsTemp.addAll(removedLastLogIndex);
            logs.addAll(logsTemp.reversed);
          } else {
            logs.addAll(model[i + 1].logs);
          }
        }
      } catch (e) {
        debugPrint('$e if');
      }
      // model[i].logs = logs;
      return logs;
    } else if (i == model.length - 1) {
      try {
        // model.removeLast();
      } catch (e) {
        debugPrint('$e else if');
      }
      return model[i].logs;
    } else {
      var logs = <Log>[];
      try {
        if (model[i].logs.last.logType == 'IN') {
          logs.add(model[i].logs.last);
          if (model[i + 1].logs.length >= 4) {
            final removedLastLogIndex = model[i + 1].logs.reversed.skip(1);
            var logsTemp = <Log>[];
            logsTemp.addAll(removedLastLogIndex);
            logs.addAll(logsTemp.reversed);
          } else {
            logs.addAll(model[i + 1].logs);
          }
        }
      } catch (e) {
        debugPrint('$e else');
      }
      // _cleanData[i].logs = logs;
      return logs;
    }

    // for (int i = 0; i < _cleanData.length; i++) {
    //   for (int j = 0; j < _cleanData[i].logs.length; j++) {
    //     log("${_cleanData[i].logs[j].logType} ${_cleanData[i].logs[j].timeStamp}");
    //   }
    //   log('--------');
    // }
  }

  // void arrangeDataEvening(int i) {
  //   if (i == 0) {
  //     var logs = <Log>[];
  //     try {
  //       if (_cleanData[i].logs.last.logType == 'IN') {
  //         logs.add(_cleanData[i].logs.last);
  //         if (_cleanData[i + 1].logs.length >= 4) {
  //           final removedLastLogIndex = _cleanData[i + 1].logs.reversed.skip(1);
  //           var logsTemp = <Log>[];
  //           logsTemp.addAll(removedLastLogIndex);
  //           logs.addAll(logsTemp.reversed);
  //         } else {
  //           logs.addAll(_cleanData[i + 1].logs);
  //         }
  //       }
  //     } catch (e) {
  //       debugPrint('$e if');
  //     }
  //     _cleanData[i].logs = logs;
  //   } else if (i == _cleanData.length - 1) {
  //     try {
  //       _cleanData.removeLast();
  //     } catch (e) {
  //       debugPrint('$e else if');
  //     }
  //   } else {
  //     var logs = <Log>[];
  //     try {
  //       if (_cleanData[i].logs.last.logType == 'IN') {
  //         logs.add(_cleanData[i].logs.last);
  //         if (_cleanData[i + 1].logs.length >= 4) {
  //           final removedLastLogIndex = _cleanData[i + 1].logs.reversed.skip(1);
  //           var logsTemp = <Log>[];
  //           logsTemp.addAll(removedLastLogIndex);
  //           logs.addAll(logsTemp.reversed);
  //         } else {
  //           logs.addAll(_cleanData[i + 1].logs);
  //         }
  //       }
  //     } catch (e) {
  //       debugPrint('$e else');
  //     }
  //     _cleanData[i].logs = logs;
  //   }

  //   // for (int i = 0; i < _cleanData.length; i++) {
  //   //   for (int j = 0; j < _cleanData[i].logs.length; j++) {
  //   //     log("${_cleanData[i].logs[j].logType} ${_cleanData[i].logs[j].timeStamp}");
  //   //   }
  //   //   log('--------');
  //   // }
  // }

  List<Log> arrangeDataMorning2(CleanDataModel model) {
    var logs = <Log>[];
    try {
      if (model.logs.first.logType == 'OUT' && model.logs.length > 1) {
        logs.addAll(model.logs.skip(1));
      } else {
        logs.addAll(model.logs);
      }
    } catch (e) {
      debugPrint('$e arrangeDataMorning');
    }
    return logs;
  }

  // void arrangeDataMorning(int i) {
  //   var logs = <Log>[];
  //   try {
  //     if (_cleanData[i].logs.first.logType == 'OUT' &&
  //         _cleanData[i].logs.length > 1) {
  //       logs.addAll(_cleanData[i].logs.skip(1));
  //     } else {
  //       logs.addAll(_cleanData[i].logs);
  //     }
  //   } catch (e) {
  //     debugPrint('$e arrangeDataMorning');
  //   }
  //   _cleanData[i].logs = logs;

  //   // for (int i = 0; i < _cleanData.length; i++) {
  //   //   for (int j = 0; j < _cleanData[i].logs.length; j++) {
  //   //     log("${_cleanData[i].logs[j].logType} ${_cleanData[i].logs[j].timeStamp}");
  //   //   }
  //   //   log('--------');
  //   // }
  // }

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
                    .add(Duration(seconds: _lateThreshold)))
                .inSeconds;

            // late
            if (inDifference > 0) {
              latePenaltyIn = latePenaltyIn + inDifference + _lateThreshold;
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
                      .add(Duration(seconds: _lateThreshold)))
                  .inSeconds;
              // late
              if (inDifference > 0) {
                latePenaltyBreak =
                    latePenaltyBreak + inDifference + _lateThreshold;
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
  LateModel calcDurationInOut({
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
    seconds = seconds + _lateThreshold;
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
    }
    return finalOtString;
  }

  CleanDataModel calcLogs2(CleanDataModel model) {
    try {
      // for (int i = 0; i < model.length; i++) {
      var duration = calcDurationInOut(
        logs: model.logs,
        name: model.firstName,
        sched: model.currentSched,
      );

      var finalOtString =
          calcOvertimeHour(duration.overtime, model.firstName, dt: model.date);
      model.duration = duration.hour.toString();
      model.lateIn = duration.lateIn.toString();
      model.lateBreak = duration.lateBreak.toString();
      model.overtime = finalOtString;
      // c[i].undertimeIn = duration.undertimeIn.toString();
      // c[i].undertimeBreak = duration.undertimelateBreak.toString();
      // }
    } catch (e) {
      debugPrint('$e calcLogs');
    }
    return model;
  }

  // void calcLogs() {
  //   try {
  //     for (int i = 0; i < _cleanData.length; i++) {
  //       var duration = calcDurationInOut(
  //         logs: _cleanData[i].logs,
  //         name: _cleanData[i].firstName,
  //         sched: _cleanData[i].currentSched,
  //       );

  //       var finalOtString = calcOvertimeHour(
  //           duration.overtime, _cleanData[i].firstName,
  //           dt: _cleanData[i].date);
  //       _cleanData[i].duration = duration.hour.toString();
  //       _cleanData[i].lateIn = duration.lateIn.toString();
  //       _cleanData[i].lateBreak = duration.lateBreak.toString();
  //       _cleanData[i].overtime = finalOtString;
  //       // c[i].undertimeIn = duration.undertimeIn.toString();
  //       // c[i].undertimeBreak = duration.undertimelateBreak.toString();
  //     }
  //   } catch (e) {
  //     debugPrint('$e calcLogs');
  //   }
  // }

  void finalizeData2(List<List<CleanDataModel>> listOfListCleanData) {
    var count = 0;
    _cleanExcelData.clear();

    try {
      for (int i = 0; i < listOfListCleanData.length; i++) {
        for (int j = 0; j < listOfListCleanData[i].length; j++) {
          count++;
          // log('kani $count');
          _cleanExcelData.add(
            CleanExcelDataModel(
              employeeId: listOfListCleanData[i][j].employeeId,
              name: fullName(listOfListCleanData[i][j]),
              currentSched: listOfListCleanData[i][j].currentSched,
              date: listOfListCleanData[i][j].date,
              logs: listOfListCleanData[i][j].logs,
              duration: listOfListCleanData[i][j].duration!,
              lateIn: listOfListCleanData[i][j].lateIn!,
              lateBreak: listOfListCleanData[i][j].lateBreak!,
              overtime: listOfListCleanData[i][j].overtime!,
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
        log('i $i listOfListCleanData ${listOfListCleanData.length}');
        if (i + 1 != listOfListCleanData.length) {
          count = 0;
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
                  description: ''),
              date: DateTime.now(),
              logs: <Log>[],
              duration: '',
              lateIn: '',
              lateBreak: '',
              overtime: '',
              // undertimeIn: c[i].undertimeIn!,
              // undertimeBreak: c[i].undertimeBreak!,
              rowCount: '',
              in1: TimeLog(),
              out1: TimeLog(),
              in2: TimeLog(),
              out2: TimeLog(),
            ),
          );
        }
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
      debugPrint('$e finalizeData2');
    }
  }

  // void finalizeData() {
  //   _cleanExcelData.clear();
  //   var count = 0;
  //   try {
  //     for (int i = 0; i < _cleanData.length; i++) {
  //       count = count + 1;
  //       _cleanExcelData.add(
  //         CleanExcelDataModel(
  //           employeeId: _cleanData[i].employeeId,
  //           name: fullName(_cleanData[i]),
  //           currentSched: _cleanData[i].currentSched,
  //           date: _cleanData[i].date,
  //           logs: _cleanData[i].logs,
  //           duration: _cleanData[i].duration!,
  //           lateIn: _cleanData[i].lateIn!,
  //           lateBreak: _cleanData[i].lateBreak!,
  //           overtime: _cleanData[i].overtime!,
  //           // undertimeIn: c[i].undertimeIn!,
  //           // undertimeBreak: c[i].undertimeBreak!,
  //           rowCount: '$count',
  //           in1: TimeLog(),
  //           out1: TimeLog(),
  //           in2: TimeLog(),
  //           out2: TimeLog(),
  //         ),
  //       );
  //     }
  //     for (var cxd in _cleanExcelData) {
  //       // ignore: prefer_is_empty
  //       if (cxd.logs.length >= 1) {
  //         cxd.in1.timestamp = formatPrettyDate(cxd.logs[0].timeStamp);
  //         cxd.in1.isSelfie = cxd.logs[0].isSelfie;
  //         cxd.in1.id = cxd.logs[0].id;
  //       }
  //       if (cxd.logs.length >= 2) {
  //         cxd.out1.timestamp = formatPrettyDate(cxd.logs[1].timeStamp);
  //         cxd.out1.isSelfie = cxd.logs[1].isSelfie;
  //         cxd.out1.id = cxd.logs[1].id;
  //       }
  //       if (cxd.logs.length >= 3) {
  //         cxd.in2.timestamp = formatPrettyDate(cxd.logs[2].timeStamp);
  //         cxd.in2.isSelfie = cxd.logs[2].isSelfie;
  //         cxd.in2.id = cxd.logs[2].id;
  //       }
  //       if (cxd.logs.length >= 4) {
  //         cxd.out2.timestamp = formatPrettyDate(cxd.logs[3].timeStamp);
  //         cxd.out2.isSelfie = cxd.logs[3].isSelfie;
  //         cxd.out2.id = cxd.logs[3].id;
  //       }
  //       if (cxd.duration == '0') cxd.duration = '';
  //       if (cxd.lateIn == '0') cxd.lateIn = '';
  //       if (cxd.lateBreak == '0') cxd.lateBreak = '';
  //       if (cxd.overtime == '0') cxd.overtime = '';
  //       // if (cxd.undertimeIn == '0') cxd.undertimeIn = '';
  //       // if (cxd.undertimeBreak == '0') cxd.undertimeBreak = '';
  //     }
  //   } catch (e) {
  //     debugPrint('$e finalizeData');
  //   }
  // }

  String fullName(CleanDataModel c) {
    return '${c.lastName}, ${c.firstName} ${c.middleName}';
  }

  String fullNameHistory(HistoryModel h) {
    return '${h.lastName}, ${h.firstName} ${h.middleName}';
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
      duration = calcDurationInOut(
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
    }
    return model;
  }

  CleanExcelDataModel reCalcNewTime({required CleanExcelDataModel model}) {
    try {
      var duration = calcDurationInOut(
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
    }
    return model;
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
      // CleanExcelDataModel(
      //   rowCount: '0',
      //   employeeId: '',
      //   name: '',
      //   date: DateTime.now(),
      //   logs: [],
      //   currentSched: ScheduleModel(
      //       schedId: '',
      //       schedType: '',
      //       schedIn: '',
      //       breakStart: '',
      //       breakEnd: '',
      //       schedOut: '',
      //       description: ''),
      //   duration: '',
      //   lateIn: '',
      //   lateBreak: '',
      //   overtime: '',
      //   in1: '',
      //   out1: ''
      // )
      var tempCleanData = <CleanExcelDataModel>[_cleanExcelData.first];

      tempCleanData.addAll(_cleanExcelData);

      for (int i = 1; i < tempCleanData.length; i++) {
        var idName = '';
        if (tempCleanData[i].name != '') {
          idName = '${tempCleanData[i].employeeId} / ${tempCleanData[i].name}';
        }
        var duration = int.tryParse(tempCleanData[i].duration);
        var lateIn = int.tryParse(tempCleanData[i].lateIn);
        var lateBreak = int.tryParse(tempCleanData[i].lateBreak);
        var overtime = tempCleanData[i].overtime;
        // var undertimeIn = int.tryParse(tempCleanData[i].undertimeIn);
        // var undertimeBreak = int.tryParse(tempCleanData[i].undertimeBreak);

        List<dynamic> dataList = [
          idName,
          tempCleanData[i].in1.timestamp,
          tempCleanData[i].out1.timestamp,
          tempCleanData[i].in2.timestamp,
          tempCleanData[i].out2.timestamp,
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
          tempCleanData[i].in1.timestamp,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 2,
            rowIndex: i,
          ),
          tempCleanData[i].out1.timestamp,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 3,
            rowIndex: i,
          ),
          tempCleanData[i].in2.timestamp,
          cellStyle: cellStyleData,
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 4,
            rowIndex: i,
          ),
          tempCleanData[i].out2.timestamp,
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
    }
  }
}
