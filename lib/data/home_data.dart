import 'dart:developer';

// import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../model/clean_data_model.dart';
import '../model/clean_excel_model.dart';
import '../model/department_model.dart';
// import '../model/excel_model.dart';
import '../model/late_model.dart';
import '../model/log_model.dart';
import '../model/schedule_model.dart';
import '../model/history_model.dart';
import '../services/http_service.dart';

class HomeData with ChangeNotifier {
  var _historyList = <HistoryModel>[];
  List<HistoryModel> get historyList => _historyList;

  // var _excelList = <ExcelModel>[];

  var _uiList = <HistoryModel>[];
  List<HistoryModel> get uiList => _uiList;

  final _departmentList = <DepartmentModel>[];
  List<DepartmentModel> get departmentList => _departmentList;

  final _scheduleList = <ScheduleModel>[];
  List<ScheduleModel> get scheduleList => _scheduleList;

  var _appVersion = "";
  String get appVersion => _appVersion;

  DateTime selectedFrom = DateTime.now();
  DateTime selectedTo = DateTime.now();

  final _isLogging = ValueNotifier(false);
  ValueNotifier<bool> get isLogging => _isLogging;

  final _is24HourFormat = ValueNotifier(false);
  ValueNotifier<bool> get is24HourFormat => _is24HourFormat;

  final _dateFormat1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  final _dateFormat2 = DateFormat('yyyy-MM-dd hh:mm:ss aa');
  DateFormat get dateFormat2 => _dateFormat2;
  // final _dateFormatFileExcel = DateFormat().add_yMMMMd();

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
      return DateFormat('HH:mm:ss').format(dateTime);
    } else {
      return DateFormat('hh:mm:ss aa').format(dateTime);
    }
  }

  // String dateFormat12or24Time() {
  //   if (_is24HourFormat.value) {
  //     return 'HH:mm';
  //   } else {
  //     return 'hh:mm aa';
  //   }
  // }

  String dateFormat12or24Excel(DateTime dateTime) {
    if (_is24HourFormat.value) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd hh:mm:ss aa').format(dateTime);
    }
  }

  // void changeTimeFormat(bool state) {
  //   _is24HourFormat.value = state;
  //   debugPrint(_is24HourFormat.value.toString());
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

  // void exportExcel(bool isExcel) {
  //   final historyListExcel = <HistoryModel>[..._historyList];

  //   // sort list alphabetically and by date, very important
  //   historyListExcel.sort((a, b) {
  //     var valueA = '${a.lastName.toLowerCase()} ${a.date}';
  //     var valueB = '${b.lastName.toLowerCase()} ${b.date}';
  //     return valueA.compareTo(valueB);
  //   });

  //   final result = <ExcelModel>[
  //     ExcelModel(
  //       rowCount: '',
  //       employeeId: 'Emp ID',
  //       name: 'Name',
  //       duration: 'Duration(Hours)',
  //       lateIn: 'Tardy(Minutes)',
  //       lateBreak: 'Late Break(Minutes)',
  //       overtime: 'Overtime(Hours)',
  //       scheduleModel: ScheduleModel(
  //         schedId: 'Sched Code',
  //         schedIn: '',
  //         schedOut: '',
  //         schedType: '',
  //         breakStart: '',
  //         breakEnd: '',
  //         description: '',
  //       ),
  //       logs: <Log>[],
  //       // timeLogIn1: TimeLog(timeLog: 'In', isSelfie: ''),
  //       // timeLogOut1: TimeLog(timeLog: 'Out', isSelfie: ''),
  //       // timeLogIn2: TimeLog(timeLog: 'In', isSelfie: ''),
  //       // timeLogOut2: TimeLog(timeLog: 'Out', isSelfie: ''),
  //     )
  //   ];

  //   try {
  //     var excel = Excel.createExcel();
  //     Sheet sheetObject = excel['Sheet1'];
  //     var cellStyle = CellStyle(
  //       backgroundColorHex: '#dddddd',
  //       fontFamily: getFontFamily(FontFamily.Arial),
  //       horizontalAlign: HorizontalAlign.Center,
  //     );

  //     var column1 = sheetObject.cell(CellIndex.indexByString('A1'));
  //     column1
  //       ..value = ''
  //       ..cellStyle = cellStyle;

  //     var column2 = sheetObject.cell(CellIndex.indexByString('B1'));
  //     column2
  //       ..value = 'Sched Code'
  //       ..cellStyle = cellStyle;

  //     var column3 = sheetObject.cell(CellIndex.indexByString('C1'));
  //     column3
  //       ..value = 'Emp ID'
  //       ..cellStyle = cellStyle;

  //     var column4 = sheetObject.cell(CellIndex.indexByString('D1'));
  //     column4
  //       ..value = 'Name'
  //       ..cellStyle = cellStyle;

  //     var column5 = sheetObject.cell(CellIndex.indexByString('E1'));
  //     column5
  //       ..value = 'In'
  //       ..cellStyle = cellStyle;

  //     var column6 = sheetObject.cell(CellIndex.indexByString('F1'));
  //     column6
  //       ..value = 'Out'
  //       ..cellStyle = cellStyle;

  //     var column7 = sheetObject.cell(CellIndex.indexByString('G1'));
  //     column7
  //       ..value = 'In'
  //       ..cellStyle = cellStyle;

  //     var column8 = sheetObject.cell(CellIndex.indexByString('H1'));
  //     column8
  //       ..value = 'Out'
  //       ..cellStyle = cellStyle;

  //     var column9 = sheetObject.cell(CellIndex.indexByString('I1'));
  //     column9
  //       ..value = 'Duration(Hours)'
  //       ..cellStyle = cellStyle;

  //     var column10 = sheetObject.cell(CellIndex.indexByString('J1'));
  //     column10
  //       ..value = 'Tardy(Minutes)'
  //       ..cellStyle = cellStyle;

  //     var column11 = sheetObject.cell(CellIndex.indexByString('K1'));
  //     column11
  //       ..value = 'Late Break(Minutes)'
  //       ..cellStyle = cellStyle;

  //     var column12 = sheetObject.cell(CellIndex.indexByString('L1'));
  //     column12
  //       ..value = 'Overtime'
  //       ..cellStyle = cellStyle;

  //     var column13 = sheetObject.cell(CellIndex.indexByString('M1'));
  //     column13
  //       ..value = 'Undertime'
  //       ..cellStyle = cellStyle;

  //     var rowCountUser = 0;

  //     try {
  //       for (int k = 0; k < historyListExcel.length; k++) {
  //         if (historyListExcel[k].logs.isNotEmpty) {
  //           if (k == 0 &&
  //               historyListExcel[k].logs.length == 1 &&
  //               historyListExcel[k].logs.first.logType == 'OUT') {
  //             historyListExcel.removeAt(k);
  //           } else if (k > 0) {
  //             //remove solo out and move to yesterday
  //             if (historyListExcel[k].logs.length == 1 &&
  //                 historyListExcel[k].logs.first.logType == 'OUT' &&
  //                 historyListExcel[k - 1].logs.last.logType == 'IN') {
  //               if (nameIndex(historyListExcel[k]) ==
  //                   nameIndex(historyListExcel[k - 1])) {
  //                 historyListExcel[k - 1]
  //                     .logs
  //                     .add(historyListExcel[k].logs.first);
  //               }
  //               if (k - 1 == 0) {
  //                 historyListExcel[k - 1].logs.removeAt(0);
  //                 // log('remove solo 0');
  //               }
  //               if (historyListExcel[k].logs.isEmpty) {
  //                 historyListExcel.removeAt(k);
  //               }
  //               // log('remove solo 1');
  //             }
  //           } else if (k > 0 && k < 3) {
  //             if (nameIndex(historyListExcel[k]) !=
  //                     nameIndex(historyListExcel[k - 1]) &&
  //                 nameIndex(historyListExcel[k]) !=
  //                     nameIndex(historyListExcel[k + 1])) {
  //               // log('remove solo 2');
  //               historyListExcel.removeAt(k);
  //             }
  //           }
  //           if (k + 1 < historyListExcel.length &&
  //               nameIndex(historyListExcel[k]) ==
  //                   nameIndex(historyListExcel[k + 1]) &&
  //               historyListExcel[k].logs.first.logType == 'OUT' &&
  //               historyListExcel[k].logs.length == 1) {
  //             // log('remove solo 3');
  //             historyListExcel.removeAt(k);
  //           }
  //           if (k == historyListExcel.length - 1) {
  //             if (nameIndex(historyListExcel[k - 1]) !=
  //                     nameIndex(historyListExcel[k]) &&
  //                 historyListExcel[k].logs.first.logType == 'OUT') {
  //               historyListExcel[k].logs.removeAt(0);
  //             }
  //           }
  //           if (k != historyListExcel.length - 1 && k != 0) {
  //             if (nameIndex(historyListExcel[k - 1]) !=
  //                     nameIndex(historyListExcel[k]) &&
  //                 historyListExcel[k].logs.first.logType == 'OUT') {
  //               historyListExcel[k].logs.removeAt(0);
  //             }
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       debugPrint('$e remove solo out and move to yesterday');
  //     }

  //     for (int i = 0; i < historyListExcel.length; i++) {
  //       try {
  //         //remove first out if logs more than 2
  //         if (historyListExcel[i].logs.isNotEmpty) {
  //           if (historyListExcel[i].logs.first.logType == 'OUT' &&
  //               historyListExcel[i].logs.length > 2 &&
  //               rowCountUser == 1) {
  //             if (historyListExcel[i].logs.isNotEmpty) {
  //               historyListExcel[i].logs.removeAt(0);
  //             }
  //           }
  //         }
  //       } catch (e) {
  //         debugPrint('$e remove first out if logs more than 2');
  //       }

  //       rowCountUser = rowCountUser + 1;

  //       var duration = LateModel(hour: 0, lateIn: 0, lateBreak: 0, overtime: 0);
  //       var timeLogs = <Log>[];

  //       if (i > 0) {
  //         //reset user logs count and add space
  //         if (nameIndex(historyListExcel[i - 1]) !=
  //             nameIndex(historyListExcel[i])) {
  //           List<dynamic> emptyRow = [
  //             '',
  //             '',
  //             '',
  //             '',
  //             '',
  //             '',
  //             '',
  //             '',
  //             '',
  //             '',
  //             '',
  //             '',
  //           ];
  //           sheetObject.appendRow(emptyRow);
  //           result.add(ExcelModel(
  //             rowCount: '',
  //             employeeId: '',
  //             name: '',
  //             // timeIn1: '',
  //             // timeOut1: '',
  //             // timeIn2: '',
  //             // timeOut2: '',
  //             duration: '',
  //             lateIn: '',
  //             lateBreak: '',
  //             overtime: '',
  //             scheduleModel: ScheduleModel(
  //               schedId: '',
  //               schedIn: '',
  //               schedOut: '',
  //               schedType: '',
  //               breakStart: '',
  //               breakEnd: '',
  //               description: '',
  //             ),
  //             logs: <Log>[],
  //             // timeLogIn1: TimeLog(timeLog: '', isSelfie: ''),
  //             // timeLogOut1: TimeLog(timeLog: '', isSelfie: ''),
  //             // timeLogIn2: TimeLog(timeLog: '', isSelfie: ''),
  //             // timeLogOut2: TimeLog(timeLog: '', isSelfie: ''),
  //           ));
  //           rowCountUser = 1;
  //         }
  //       }
  //       var dayOfWeek = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  //       var todaySched = scheduleList.singleWhere(
  //         (element) =>
  //             element.schedId ==
  //             selectDay(day: dayOfWeek, model: historyListExcel[i]),
  //       );

  //       // if last log is in, then date out is tommorrow
  //       if (historyListExcel[i].logs.isNotEmpty) {
  //         if (historyListExcel[i].logs.last.logType == 'IN') {
  //           try {
  //             if (i + 1 < historyListExcel.length) {
  //               if (nameIndex(historyListExcel[i]) ==
  //                   nameIndex(historyListExcel[i + 1])) {
  //                 // log('dire 0');
  //                 duration = calcDurationInOutOtherDay(
  //                   logs1: historyListExcel[i].logs,
  //                   logs2: historyListExcel[i + 1].logs,
  //                   name: historyListExcel[i].firstName,
  //                   sched: todaySched,
  //                 );
  //                 var differenceForgotOut = 0;
  //                 if (historyListExcel[i + 1].logs[0].logType == 'OUT' &&
  //                     historyListExcel[i + 1].logs[1].logType == 'IN') {
  //                   differenceForgotOut = historyListExcel[i + 1]
  //                       .logs[1]
  //                       .timeStamp
  //                       .difference(historyListExcel[i + 1].logs[0].timeStamp)
  //                       .inMinutes;
  //                   // log('test2 $differenceForgotOut differenceForgotOut ${historyListExcel[i].firstName} ${historyListExcel[i + 1].logs[0].logType} ${historyListExcel[i + 1].logs[0].timeStamp} ${historyListExcel[i + 1].logs[1].logType} ${historyListExcel[i + 1].logs[1].timeStamp}');
  //                   // dont calc if out and in if less than 30 minutes gap
  //                   // means user forgot to out
  //                   if (differenceForgotOut > 30) {
  //                     timeLogs.add(historyListExcel[i].logs.last);
  //                   }
  //                 }
  //                 // move first log other day to yesterday if out
  //                 if (todaySched.schedId.substring(0, 1).toUpperCase() == 'E') {
  //                   timeLogs.add(historyListExcel[i + 1].logs[0]);
  //                 } else {
  //                   timeLogs.add(historyListExcel[i].logs[0]);
  //                 }
  //                 // if next log is out and is solo, remove
  //                 if (historyListExcel[i + 1].logs.isNotEmpty) {
  //                   historyListExcel[i + 1].logs.removeAt(0);
  //                 }
  //               } else {
  //                 //remove first log of n+1 index if out, because already move to i
  //                 if (historyListExcel[i + 1].logs.isNotEmpty) {
  //                   if (historyListExcel[i + 1].logs[0].logType == 'OUT' &&
  //                       nameIndex(historyListExcel[i]) ==
  //                           nameIndex(historyListExcel[i + 1])) {
  //                     historyListExcel[i + 1].logs.removeAt(0);
  //                   }
  //                 }
  //                 // log('dire 1');
  //                 duration = calcDurationInOutSameDay(
  //                   logs: historyListExcel[i].logs,
  //                   name: historyListExcel[i].firstName,
  //                   sched: todaySched,
  //                 );
  //                 // timeLogs.add(historyListExcel[i].logs.last);
  //                 if (historyListExcel[i].logs.isNotEmpty) {
  //                   timeLogs.addAll(historyListExcel[i].logs);
  //                 }
  //               }
  //             } else {
  //               // log('dire 2');
  //               // if last log is in and last index, do in out same day, otherwise dont calc duration
  //               if (historyListExcel[i].logs.isNotEmpty) {
  //                 duration = calcDurationInOutSameDay(
  //                   logs: historyListExcel[i].logs,
  //                   name: historyListExcel[i].firstName,
  //                   sched: todaySched,
  //                 );
  //                 timeLogs.addAll(historyListExcel[i].logs);
  //               }
  //             }
  //           } catch (e) {
  //             debugPrint('$e if in');
  //           }
  //         } else {
  //           try {
  //             if (historyListExcel[i].logs.isNotEmpty) {
  //               // log('dire 3');
  //               // if date is out, then date in and out same
  //               duration = calcDurationInOutSameDay(
  //                 logs: historyListExcel[i].logs,
  //                 name: historyListExcel[i].firstName,
  //                 sched: todaySched,
  //               );
  //               timeLogs.addAll(historyListExcel[i].logs);
  //             }
  //           } catch (e) {
  //             debugPrint('$e else out');
  //           }
  //         }
  //       }

  //       // var timeIn1 = TimeLog(timeLog: '', isSelfie: '');
  //       // var timeOut1 = TimeLog(timeLog: '', isSelfie: '');
  //       // var timeIn2 = TimeLog(timeLog: '', isSelfie: '');
  //       // var timeOut2 = TimeLog(timeLog: '', isSelfie: '');

  //       var timeIn1 = '';
  //       var timeOut1 = '';
  //       var timeIn2 = '';
  //       var timeOut2 = '';

  //       try {
  //         if (timeLogs.length > 1 &&
  //             (timeLogs[0].logType == 'OUT' && timeLogs[1].logType == 'IN')) {
  //           var tempList = <Log>[];
  //           tempList.add(timeLogs[1]);
  //           tempList.add(timeLogs[0]);
  //           timeLogs[0] = tempList[0];
  //           timeLogs[1] = tempList[1];
  //         }

  //         if (timeLogs.isNotEmpty) {
  //           timeIn1 = dateFormat12or24Excel(timeLogs[0].timeStamp);
  //         }

  //         // timeIn1.timeLog = dateFormat12or24Excel(timeLogs[0].timeStamp);
  //         // timeIn1.isSelfie = timeLogs[0].isSelfie;

  //         if (timeLogs.length >= 2) {
  //           // timeOut1.timeLog = dateFormat12or24Excel(timeLogs[1].timeStamp);
  //           // timeOut1.isSelfie = timeLogs[0].isSelfie;
  //           timeOut1 = dateFormat12or24Excel(timeLogs[1].timeStamp);
  //         }
  //         if (timeLogs.length >= 3) {
  //           // timeIn2.timeLog = dateFormat12or24Excel(timeLogs[2].timeStamp);
  //           // timeIn2.isSelfie = timeLogs[2].isSelfie;
  //           timeIn2 = dateFormat12or24Excel(timeLogs[2].timeStamp);
  //         }
  //         if (timeLogs.length >= 4) {
  //           // timeOut2.timeLog = dateFormat12or24Excel(timeLogs[3].timeStamp);
  //           // timeOut2.isSelfie = timeLogs[3].isSelfie;
  //           timeOut2 = dateFormat12or24Excel(timeLogs[3].timeStamp);
  //         }
  //         // if (timeLogs.length == 1) timeOut1 = '';
  //       } catch (e) {
  //         debugPrint('$e time slot');
  //       }

  //       var employeeId = int.tryParse(historyListExcel[i].employeeId);
  //       var finalOtString = calcOvertimeHour(duration.overtime);

  //       List<dynamic> dataList = [
  //         rowCountUser,
  //         todaySched.schedId,
  //         employeeId,
  //         nameIndex(historyListExcel[i]),
  //         timeIn1,
  //         timeOut1,
  //         timeIn2,
  //         timeOut2,
  //         duration.hour,
  //         duration.lateIn,
  //         duration.lateBreak,
  //         finalOtString,
  //       ];
  //       result.add(ExcelModel(
  //         rowCount: rowCountUser.toString(),
  //         employeeId: historyListExcel[i].employeeId,
  //         name: nameIndex(historyListExcel[i]),
  //         // timeIn1: timeIn1,
  //         // timeOut1: timeOut1,
  //         // timeIn2: timeIn2,
  //         // timeOut2: timeOut2,
  //         duration: duration.hour.toString(),
  //         lateIn: duration.lateIn.toString(),
  //         lateBreak: duration.lateBreak.toString(),
  //         overtime: finalOtString,
  //         scheduleModel: todaySched,
  //         logs: timeLogs,
  //         // timeLogIn1: timeIn1,
  //         // timeLogOut1: timeOut1,
  //         // timeLogIn2: timeIn2,
  //         // timeLogOut2: timeOut2,
  //       ));
  //       sheetObject.appendRow(dataList);
  //     }

  //     // sheetObject.setColWidth(3, 30);

  //     if (isExcel) {
  //       excel.save(
  //           fileName:
  //               'DTR ${_dateFormatFileExcel.format(selectedFrom)} - ${_dateFormatFileExcel.format(selectedTo)}.xlsx');
  //     }
  //   } catch (e) {
  //     debugPrint('$e exportExcel');
  //   } finally {
  //     _excelList = result;
  //     // finalizeData();
  //   }
  // }

  // void finalizeData() {
  //   var k = 0;
  //   try {
  //     for (int i = 0; i < _excelList.length; i++) {
  //       k = i;
  //       if (i + 1 < _excelList.length) {
  //         if (_excelList[i + 1].logs.length > 3) {
  //           if (_excelList[i + 1].employeeId == _excelList[i].employeeId &&
  //               _excelList[i].logs.length > 1) {
  //             var timeGapNight = 0;

  //             timeGapNight = _excelList[i + 1]
  //                 .logs[0]
  //                 .timeStamp
  //                 .difference(_excelList[i].logs[1].timeStamp)
  //                 .inHours;

  //             log('${_excelList[i].logs[1].timeStamp} ${_excelList[i + 1].logs[0].timeStamp}');
  //             log('${_excelList[i].name} ${_excelList[i].rowCount} $timeGapNight');

  //             late Log tempPlus1TimeIn1;
  //             late Log tempPlus1TimeOut1;
  //             if (_excelList[i + 1].logs.length > 3) {
  //               log('dire1');
  //               tempPlus1TimeIn1 = _excelList[i + 1].logs[2];
  //               tempPlus1TimeOut1 = _excelList[i + 1].logs[3];
  //             }
  //             if (timeGapNight <= 2 && _excelList[i + 1].logs.length < 3) {
  //               log('dire2');
  //               _excelList[i].logs[2] = _excelList[i + 1].logs[0];
  //               _excelList[i].logs[3] = _excelList[i + 1].logs[1];
  //               _excelList[i + 1].logs[0] = tempPlus1TimeIn1;
  //               _excelList[i + 1].logs[1] = tempPlus1TimeOut1;
  //               log('dire3');
  //               if (excelList[i + 1].logs.length == 4) {
  //                 log('dire0 ${_excelList[i + 1].logs.length}');
  //                 _excelList[i + 1].logs.removeAt(3);
  //                 _excelList[i + 1].logs.removeAt(2);
  //               }
  //               log('dire4');

  //               var duration1 = calcDurationInOutSameDay(
  //                 logs: _excelList[i].logs,
  //                 name: _excelList[i].name,
  //                 sched: _excelList[i].scheduleModel,
  //               );

  //               log('${_excelList[i].name} $duration1 duration1');

  //               _excelList[i].duration = duration1.hour.toString();
  //               _excelList[i].lateIn = duration1.lateIn.toString();
  //               _excelList[i].lateBreak = duration1.lateBreak.toString();

  //               var duration2 = calcDurationInOutSameDay(
  //                 logs: _excelList[i + 1].logs,
  //                 name: _excelList[i + 1].name,
  //                 sched: _excelList[i + 1].scheduleModel,
  //               );

  //               log('${_excelList[i + 1].name} $duration2 duration2');

  //               _excelList[i + 1].duration = duration2.hour.toString();
  //               _excelList[i + 1].lateIn = duration2.lateIn.toString();
  //               _excelList[i + 1].lateBreak = duration2.lateBreak.toString();
  //             }
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('$e finalizeData');
  //     log('err ${_excelList[k].name} ${_excelList[k].rowCount}');
  //   }
  // }

  // void reCalcLate({
  //   required ExcelModel model,
  //   required ScheduleModel newSchedule,
  // }) {
  //   var duration = LateModel(hour: 0, lateIn: 0, lateBreak: 0, overtime: 0);
  //   try {
  //     duration = calcDurationInOutSameDay(
  //       logs: model.logs,
  //       name: model.name,
  //       sched: newSchedule,
  //     );
  //     var finalOtString = calcOvertimeHour(duration.overtime);
  //     model.duration = duration.hour.toString();
  //     model.lateIn = duration.lateIn.toString();
  //     model.lateBreak = duration.lateBreak.toString();
  //     model.overtime = finalOtString;
  //     model.scheduleModel = newSchedule;
  //   } catch (e) {
  //     debugPrint('$e reCalcLate');
  //   }
  // }

  // void remakeExcel() {
  //   try {
  //     var excel = Excel.createExcel();
  //     Sheet sheetObject = excel['Sheet1'];
  //     var cellStyle = CellStyle(
  //       backgroundColorHex: '#dddddd',
  //       fontFamily: getFontFamily(FontFamily.Arial),
  //       horizontalAlign: HorizontalAlign.Center,
  //     );

  //     var column1 = sheetObject.cell(CellIndex.indexByString('A1'));
  //     column1
  //       ..value = ''
  //       ..cellStyle = cellStyle;

  //     var column2 = sheetObject.cell(CellIndex.indexByString('B1'));
  //     column2
  //       ..value = 'Sched Code'
  //       ..cellStyle = cellStyle;

  //     var column3 = sheetObject.cell(CellIndex.indexByString('C1'));
  //     column3
  //       ..value = 'Emp ID'
  //       ..cellStyle = cellStyle;

  //     var column4 = sheetObject.cell(CellIndex.indexByString('D1'));
  //     column4
  //       ..value = 'Name'
  //       ..cellStyle = cellStyle;

  //     var column5 = sheetObject.cell(CellIndex.indexByString('E1'));
  //     column5
  //       ..value = 'In'
  //       ..cellStyle = cellStyle;

  //     var column6 = sheetObject.cell(CellIndex.indexByString('F1'));
  //     column6
  //       ..value = 'Out'
  //       ..cellStyle = cellStyle;

  //     var column7 = sheetObject.cell(CellIndex.indexByString('G1'));
  //     column7
  //       ..value = 'In'
  //       ..cellStyle = cellStyle;

  //     var column8 = sheetObject.cell(CellIndex.indexByString('H1'));
  //     column8
  //       ..value = 'Out'
  //       ..cellStyle = cellStyle;

  //     var column9 = sheetObject.cell(CellIndex.indexByString('I1'));
  //     column9
  //       ..value = 'Duration(Hours)'
  //       ..cellStyle = cellStyle;

  //     var column10 = sheetObject.cell(CellIndex.indexByString('J1'));
  //     column10
  //       ..value = 'Tardy(Minutes)'
  //       ..cellStyle = cellStyle;

  //     var column11 = sheetObject.cell(CellIndex.indexByString('K1'));
  //     column11
  //       ..value = 'Late Break(Minutes)'
  //       ..cellStyle = cellStyle;

  //     var column12 = sheetObject.cell(CellIndex.indexByString('L1'));
  //     column12
  //       ..value = 'Overtime'
  //       ..cellStyle = cellStyle;

  //     var column13 = sheetObject.cell(CellIndex.indexByString('M1'));
  //     column13
  //       ..value = 'Undertime'
  //       ..cellStyle = cellStyle;

  //     for (int i = 0; i < _excelList.length; i++) {
  //       var rowCount = int.tryParse(_excelList[i].rowCount);
  //       var employeeId = int.tryParse(_excelList[i].employeeId);
  //       var duration = int.tryParse(_excelList[i].duration);
  //       var lateIn = int.tryParse(_excelList[i].lateIn);
  //       var lateBreak = int.tryParse(_excelList[i].lateBreak);
  //       var overtime = double.tryParse(_excelList[i].overtime);
  //       var schedCode = _excelList[i].scheduleModel.schedId;

  //       var timeIn1 = '';
  //       var timeOut1 = '';
  //       var timeIn2 = '';
  //       var timeOut2 = '';

  //       try {
  //         if (_excelList[i].logs.isNotEmpty) {
  //           timeIn1 = dateFormat12or24Excel(_excelList[i].logs[0].timeStamp);
  //         }
  //         if (_excelList[i].logs.length > 1) {
  //           timeOut1 = dateFormat12or24Excel(_excelList[i].logs[1].timeStamp);
  //         }
  //         if (_excelList[i].logs.length > 2) {
  //           timeIn2 = dateFormat12or24Excel(_excelList[i].logs[2].timeStamp);
  //         }
  //         if (_excelList[i].logs.length > 3) {
  //           timeOut2 = dateFormat12or24Excel(_excelList[i].logs[3].timeStamp);
  //         }
  //       } catch (e) {
  //         debugPrint('$e time slot');
  //       }

  //       if (i != 0) {
  //         List<dynamic> dataList = [
  //           rowCount,
  //           schedCode,
  //           employeeId,
  //           _excelList[i].name,
  //           timeIn1,
  //           timeOut1,
  //           timeIn2,
  //           timeOut2,
  //           duration,
  //           lateIn,
  //           lateBreak,
  //           overtime,
  //         ];
  //         sheetObject.appendRow(dataList);
  //       }
  //     }

  //     // sheetObject.setColWidth(3, 30);

  //     excel.save(
  //         fileName:
  //             'DTR ${_dateFormatFileExcel.format(selectedFrom)} - ${_dateFormatFileExcel.format(selectedTo)}.xlsx');
  //   } catch (e) {
  //     debugPrint('$e remakeExcel');
  //   }
  // }

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

  var _cleanData = <CleanDataModel>[];
  List<CleanDataModel> get cleanData => _cleanData;

  List<CleanDataModel> dayCleanData({
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

      log('${c[i].duration} $finalOtString');
    }

    _cleanData = c;
  }

  final _cleanExcelData = <CleanExcelDataModel>[];
  List<CleanExcelDataModel> get cleanExcelData => _cleanExcelData;

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
      ),
    );
    for (int i = 0; i < c.length; i++) {
      count = count + 1;
      if (i != c.length - 1 && c[i].employeeId != c[i + 1].employeeId) {
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
        ),
      );
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
        // log('kani ${c.logs[0].timeStamp} ${c.logs[1].timeStamp}');
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
        // log('kani ${c.logs[1].timeStamp} ${c.logs[2].timeStamp}');

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

  // bool isLogtypeOut(String logtype) {
  //   if (logtype == 'OUT') {
  //     return true;
  //   }
  //   return false;
  // }

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
      // log('last $finalOtString');
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
      // debugPrint(newselectedFrom.toString());
      // debugPrint(newselectedTo.toString());
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
