import 'dart:developer';

import 'package:dtrweb/model/log_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/home_data.dart';
import '../model/clean_excel_model.dart';
import '../model/department_model.dart';
import '../model/schedule_model.dart';
import '../widget/timelog_widget.dart';

class ExcelView extends StatefulWidget {
  const ExcelView({
    super.key,
    required this.idController,
    required this.dropdownValue,
  });
  final TextEditingController idController;
  final DepartmentModel dropdownValue;

  @override
  State<ExcelView> createState() => _ExcelViewState();
}

class _ExcelViewState extends State<ExcelView> {
  late ScheduleModel dropdownValue;
  final scl = ScrollController();
  final sc1 = ScrollController();
  final sc2 = ScrollController();

  SnackBar showError(String e) {
    var snackBar = SnackBar(
      content: Text(e),
      duration: const Duration(seconds: 3),
    );
    return snackBar;
  }

  @override
  void initState() {
    super.initState();
    var instance = Provider.of<HomeData>(context, listen: false);
    if (instance.scheduleList.isNotEmpty) {
      dropdownValue = instance.scheduleList[0];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sc2.addListener(() {
        sc1.jumpTo(sc2.position.pixels);
      });
    });
  }

  Future<CleanExcelDataModel> showChangeScheduleDialog({
    required BuildContext context,
    required CleanExcelDataModel model,
  }) async {
    var instance = Provider.of<HomeData>(context, listen: false);
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Change Schedule'),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return DropdownButtonHideUnderline(
                child: DropdownButton<ScheduleModel>(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  borderRadius: BorderRadius.circular(5),
                  value: dropdownValue,
                  onChanged: (ScheduleModel? value) async {
                    if (value != null) {
                      setState(() {
                        dropdownValue = value;
                      });
                    }
                  },
                  items: instance.scheduleList
                      .map<DropdownMenuItem<ScheduleModel>>(
                          (ScheduleModel value) {
                    return DropdownMenuItem<ScheduleModel>(
                      value: value,
                      child: Text(
                        '${value.schedId} | ${value.description}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Ok',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  model = instance.reCalcLateModel(
                      model: model, newSchedule: dropdownValue);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('$e showChangeScheduleDialog');
    }

    debugPrint('${model.duration} ${model.lateIn} ${model.lateBreak}');
    return model;
  }

  Future<CleanExcelDataModel> showTimeDialog({
    required BuildContext context,
    required CleanExcelDataModel c,
    required int i,
  }) async {
    var instance = Provider.of<HomeData>(context, listen: false);
    DateTime? dateResult;

    try {
      var d = await showDatePicker(
        context: context,
        initialDate: c.logs[i].timeStamp,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime.now(),
      );
      if (mounted) {
        var t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(c.logs[i].timeStamp),
        );
        if (d != null && t != null) {
          var fd = DateTime(d.year, d.month, d.day, t.hour, t.minute);
          log('fd ${fd.toString()}');
          dateResult = fd;
        }
      }
      if (dateResult != null) {
        if (i == 0) {
          c.logs[0].timeStamp = dateResult;
          c.in1.timestamp = instance.formatPrettyDate(dateResult);
        } else if (i == 1) {
          c.logs[1].timeStamp = dateResult;
          c.out1.timestamp = instance.formatPrettyDate(dateResult);
        } else if (i == 2) {
          c.logs[2].timeStamp = dateResult;
          c.in2.timestamp = instance.formatPrettyDate(dateResult);
        } else if (i == 3) {
          c.logs[3].timeStamp = dateResult;
          c.out2.timestamp = instance.formatPrettyDate(dateResult);
        }
        c = instance.reCalcNewTime(model: c);
      }
      debugPrint('${c.duration} ${c.lateIn} ${c.lateBreak}');
    } catch (e) {
      debugPrint('$e showTimeDialog');
    }
    return c;
  }

  Future<CleanExcelDataModel> addLog({
    required CleanExcelDataModel c,
    required int i,
    required BuildContext context,
  }) async {
    DateTime? dateResult;
    var instance = Provider.of<HomeData>(context, listen: false);
    try {
      if (i == 0 && c.currentSched.schedType.toLowerCase() == 'b') {
        var dateString1 = c.logs[0].timeStamp.toString().substring(0, 10);
        var dateWithTime1 = '$dateString1 ${c.currentSched.breakStart}';
        dateResult = instance.dateFormat1.parse(dateWithTime1);
      } else if (i == 0 && c.currentSched.schedType.toLowerCase() == 'a') {
        var dateString1 = c.logs[0].timeStamp.toString().substring(0, 10);
        var dateWithTime1 = '$dateString1 ${c.currentSched.schedOut}';
        dateResult = instance.dateFormat1.parse(dateWithTime1);
      } else if (i == 1) {
        var dateString2 = c.logs[1].timeStamp.toString().substring(0, 10);
        var dateWithTime2 = '$dateString2 ${c.currentSched.breakEnd}';
        dateResult = instance.dateFormat1.parse(dateWithTime2);
      } else if (i == 2) {
        var dateString3 = c.logs[2].timeStamp.toString().substring(0, 10);
        var dateWithTime3 = '$dateString3 ${c.currentSched.schedOut}';
        dateResult = instance.dateFormat1.parse(dateWithTime3);
      }

      var d = await showDatePicker(
        context: context,
        initialDate: dateResult!,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime.now(),
      );

      if (mounted) {
        var t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(dateResult),
        );
        if (d != null && t != null) {
          var fd = DateTime(d.year, d.month, d.day, t.hour, t.minute);
          log('fd $fd');
          dateResult = fd;
        }
      }
      c.logs.add(Log(
        timeStamp: dateResult,
        logType: c.logs.last.logType == 'OUT' ? 'IN' : 'OUT',
        id: '',
        isSelfie: '0',
      ));
      // ignore: prefer_is_empty
      if (c.logs.length >= 1) {
        c.logs[0].timeStamp = c.logs[0].timeStamp;
        c.in1.timestamp = instance.formatPrettyDate(c.logs[0].timeStamp);
      }
      if (c.logs.length >= 2) {
        c.logs[1].timeStamp = c.logs[1].timeStamp;
        c.out1.timestamp = instance.formatPrettyDate(c.logs[1].timeStamp);
      }
      if (c.logs.length >= 3) {
        c.logs[2].timeStamp = c.logs[2].timeStamp;
        c.in2.timestamp = instance.formatPrettyDate(c.logs[2].timeStamp);
      }
      if (c.logs.length >= 4) {
        c.logs[3].timeStamp = c.logs[3].timeStamp;
        c.out2.timestamp = instance.formatPrettyDate(c.logs[3].timeStamp);
      }
      c = instance.reCalcNewTime(model: c);
    } catch (e) {
      debugPrint('$e addLog');
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<HomeData>(context, listen: false);
    const String title = 'UC-1 DTR History';
    var version = 'v${instance.appVersion}';
    var rcw = 50.0;
    var schedidw = 80.0;
    var empidw = 80.0;
    var namew = 200.0;
    var timelogw = 205.0;
    var durw = 100.0;
    var tardyw = 100.0;
    var tardybw = 120.0;
    var otw = 100.0;
    var udiw = 110.0;
    var udbw = 110.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(title),
            const SizedBox(
              width: 2.5,
            ),
            Text(
              version,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size(1920, 30),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            controller: sc1,
            child: Container(
              color: Colors.white,
              width: 1920.0,
              height: 30.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ExcelCell(w: rcw, c: Colors.orange, t: ''),
                  ExcelCell(w: schedidw, c: Colors.green, t: 'Sched ID'),
                  ExcelCell(w: empidw, c: Colors.red, t: 'Emp ID'),
                  ExcelCell(w: namew, c: Colors.blue, t: 'Name'),
                  ExcelCell(w: timelogw, c: Colors.brown, t: 'IN'),
                  ExcelCell(w: timelogw, c: Colors.cyan, t: 'OUT'),
                  ExcelCell(w: timelogw, c: Colors.pink, t: 'IN'),
                  ExcelCell(w: timelogw, c: Colors.purple, t: 'OUT'),
                  ExcelCell(w: durw, c: Colors.indigo, t: 'Duration(hrs)'),
                  ExcelCell(w: tardyw, c: Colors.amber, t: 'Tardy(mns)'),
                  ExcelCell(
                      w: tardybw, c: Colors.lightGreen, t: 'Tardy Break(mns)'),
                  ExcelCell(w: otw, c: Colors.lime, t: 'OT(hrs)'),
                  ExcelCell(w: udiw, c: Colors.teal, t: 'UD In(mns)'),
                  ExcelCell(w: udbw, c: Colors.yellow, t: 'UD Break(mns)'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              instance.exportExcel();
            },
            child: Ink(
              height: 50.0,
              width: 125.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.orange[300],
              ),
              padding: const EdgeInsets.all(5.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  Text(
                    'Export excel',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: sc2,
        child: SingleChildScrollView(
          controller: sc2,
          scrollDirection: Axis.horizontal,
          // primary: false,
          child: Consumer<HomeData>(builder: (ctx, provider, widget) {
            var w = MediaQuery.of(context).size.width;
            var h = MediaQuery.of(context).size.height;
            debugPrint('w $w h $h');
            return SizedBox(
              width: 1920.0,
              height: 1080.0,
              child: ListView.builder(
                shrinkWrap: true,
                controller: scl,
                itemCount: provider.cleanExcelData.length,
                itemBuilder: (ctx, i) {
                  return InkWell(
                    onLongPress: () {},
                    onHover: (_) {},
                    hoverColor: Colors.blueGrey[300],
                    child: Ink(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1, color: Colors.grey),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ExcelCell(
                            w: rcw,
                            c: Colors.orange,
                            t: provider.cleanExcelData[i].rowCount,
                          ),
                          InkWell(
                            onTap: () async {
                              try {
                                dropdownValue = provider.scheduleList
                                    .singleWhere((e) =>
                                        e.schedId ==
                                        provider.cleanExcelData[i].currentSched
                                            .schedId);
                                var result = await showChangeScheduleDialog(
                                  context: context,
                                  model: provider.cleanExcelData[i],
                                );
                                setState(() {
                                  provider.cleanExcelData[i] = result;
                                });
                              } catch (e) {
                                debugPrint('$e');
                              }
                            },
                            child: ExcelCell(
                              w: schedidw,
                              c: Colors.green,
                              t: provider
                                  .cleanExcelData[i].currentSched.schedId,
                            ),
                          ),
                          ExcelCell(
                            w: empidw,
                            c: Colors.red,
                            t: provider.cleanExcelData[i].employeeId,
                          ),
                          ExcelCell(
                            w: namew,
                            c: Colors.blue,
                            t: provider.cleanExcelData[i].name,
                          ),
                          InkWell(
                            onTap: () async {
                              var result = await showTimeDialog(
                                context: context,
                                c: provider.cleanExcelData[i],
                                i: 0,
                              );
                              setState(() {
                                provider.cleanExcelData[i] = result;
                              });
                            },
                            child: TimelogWidget(
                              tl: provider.cleanExcelData[i].in1,
                              w: timelogw,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (provider.cleanExcelData[i].logs.length == 1) {
                                await addLog(
                                  context: context,
                                  c: provider.cleanExcelData[i],
                                  i: 0,
                                ).then((r) {
                                  setState(() {
                                    provider.cleanExcelData[i] = r;
                                  });
                                });
                              } else {
                                await showTimeDialog(
                                  context: context,
                                  c: provider.cleanExcelData[i],
                                  i: 1,
                                ).then((r) {
                                  log('${r.logs.length} ${r.in2}');
                                  setState(() {
                                    provider.cleanExcelData[i] = r;
                                  });
                                });
                              }
                            },
                            child: TimelogWidget(
                              tl: provider.cleanExcelData[i].out1,
                              w: timelogw,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (provider.cleanExcelData[i].logs.length == 2) {
                                await addLog(
                                  context: context,
                                  c: provider.cleanExcelData[i],
                                  i: 1,
                                ).then((r) {
                                  setState(() {
                                    provider.cleanExcelData[i] = r;
                                  });
                                });
                              } else {
                                await showTimeDialog(
                                  context: context,
                                  c: provider.cleanExcelData[i],
                                  i: 2,
                                ).then((r) {
                                  setState(() {
                                    provider.cleanExcelData[i] = r;
                                  });
                                });
                              }
                            },
                            child: TimelogWidget(
                              tl: provider.cleanExcelData[i].in2,
                              w: timelogw,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (provider.cleanExcelData[i].logs.length == 3) {
                                await addLog(
                                  context: context,
                                  c: provider.cleanExcelData[i],
                                  i: 2,
                                ).then((r) {
                                  setState(() {
                                    provider.cleanExcelData[i] = r;
                                  });
                                });
                              } else {
                                await showTimeDialog(
                                  context: context,
                                  c: provider.cleanExcelData[i],
                                  i: 3,
                                ).then((r) {
                                  setState(() {
                                    provider.cleanExcelData[i] = r;
                                  });
                                });
                              }
                            },
                            child: TimelogWidget(
                              tl: provider.cleanExcelData[i].out2,
                              w: timelogw,
                            ),
                          ),
                          ExcelCell(
                            w: durw,
                            c: Colors.indigo,
                            t: provider.cleanExcelData[i].duration,
                          ),
                          ExcelCell(
                            w: tardyw,
                            c: Colors.amber,
                            t: provider.cleanExcelData[i].lateIn,
                            tc: Colors.red,
                          ),
                          ExcelCell(
                            w: tardybw,
                            c: Colors.lightGreen,
                            t: provider.cleanExcelData[i].lateBreak,
                            tc: Colors.red,
                          ),
                          ExcelCell(
                            w: otw,
                            c: Colors.lime,
                            t: provider.cleanExcelData[i].overtime,
                          ),
                          ExcelCell(
                            w: udiw,
                            c: Colors.teal,
                            t: provider.cleanExcelData[i].undertimeIn,
                          ),
                          ExcelCell(
                            w: udbw,
                            c: Colors.yellow,
                            t: provider.cleanExcelData[i].undertimeBreak,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ExcelCell extends StatelessWidget {
  const ExcelCell({
    super.key,
    required this.w,
    this.c,
    required this.t,
    this.tc,
  });
  final double w;
  final Color? c;
  final String t;
  final Color? tc;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      decoration: const BoxDecoration(
        color: null,
        border: Border(
          // right: BorderSide(width: 1, color: Colors.grey),
          left: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: Text(
        t,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: tc),
      ),
    );
  }
}
