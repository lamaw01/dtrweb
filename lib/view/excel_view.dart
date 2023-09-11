import 'dart:developer';

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
    required CleanExcelDataModel model,
    required int i,
  }) async {
    var instance = Provider.of<HomeData>(context, listen: false);
    DateTime? dateResult;

    try {
      var d = await showDatePicker(
        context: context,
        initialDate: model.logs[i].timeStamp,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime.now(),
      );
      log('d ${d.toString()}');
      if (mounted) {
        var t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(model.logs[i].timeStamp),
        );
        log('t ${t.toString()}');
        if (d != null && t != null) {
          var fd = DateTime(d.year, d.month, d.day, t.hour, t.minute);
          log('fd ${fd.toString()}');
          dateResult = fd;
        }
      }
      if (dateResult != null) {
        if (i == 0) {
          model.logs[0].timeStamp = dateResult;
          model.in1.timestamp = instance.formatPrettyDate(dateResult);
        } else if (i == 1) {
          model.logs[1].timeStamp = dateResult;
          model.out1.timestamp = instance.formatPrettyDate(dateResult);
        } else if (i == 2) {
          model.logs[2].timeStamp = dateResult;
          model.in2.timestamp = instance.formatPrettyDate(dateResult);
        } else if (i == 3) {
          model.logs[3].timeStamp = dateResult;
          model.out2.timestamp = instance.formatPrettyDate(dateResult);
        }
        model = instance.reCalcNewTime(model: model);
      }
      debugPrint('${model.duration} ${model.lateIn} ${model.lateBreak}');
    } catch (e) {
      debugPrint('$e showTimeDialog');
    }
    return model;
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
    var timelogw = 160.0;
    var durw = 100.0;
    var tardyw = 100.0;
    var tardybw = 120.0;
    var otw = 100.0;
    var udiw = 100.0;
    var udbw = 100.0;

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
                  Container(
                    width: rcw,
                    decoration: const BoxDecoration(
                      // color: Colors.orange,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      '',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: schedidw,
                    decoration: const BoxDecoration(
                      // color: Colors.green,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'Sched ID',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: empidw,
                    decoration: const BoxDecoration(
                      // color: Colors.green,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'Emp ID',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: namew,
                    decoration: const BoxDecoration(
                      // color: Colors.blue,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'Name',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: timelogw,
                    decoration: const BoxDecoration(
                      // color: Colors.blue,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'IN',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: timelogw,
                    decoration: const BoxDecoration(
                      // color: Colors.blue,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'OUT',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: timelogw,
                    decoration: const BoxDecoration(
                      // color: Colors.blue,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'IN',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: timelogw,
                    decoration: const BoxDecoration(
                      // color: Colors.blue,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'OUT',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: durw,
                    decoration: const BoxDecoration(
                      // color: Colors.cyan,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'Duration(hrs)',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: tardyw,
                    decoration: const BoxDecoration(
                      // color: Colors.indigo,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Tardy(mms)',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    width: tardybw,
                    decoration: const BoxDecoration(
                      // color: Colors.lime,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'Tardy Break(mms)',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: otw,
                    decoration: const BoxDecoration(
                      // color: Colors.teal,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'OT(mms)',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: udiw,
                    decoration: const BoxDecoration(
                      // color: Colors.teal,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'UD In(mms)',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: udbw,
                    decoration: const BoxDecoration(
                      // color: Colors.teal,
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'UD Break(mms)',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: rcw,
                          decoration: const BoxDecoration(
                            // color: Colors.orange,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].rowCount,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        InkWell(
                          hoverColor: Colors.grey[300],
                          onTap: () async {
                            dropdownValue = provider.scheduleList.singleWhere(
                                (e) =>
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
                          },
                          child: Ink(
                            width: schedidw,
                            decoration: const BoxDecoration(
                              // color: Colors.green,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.cleanExcelData[i].currentSched.schedId,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          width: empidw,
                          decoration: const BoxDecoration(
                            // color: Colors.green,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].employeeId,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          width: namew,
                          decoration: const BoxDecoration(
                            // color: Colors.blue,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].name,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          hoverColor: Colors.grey[300],
                          onTap: () async {
                            var result = await showTimeDialog(
                              context: context,
                              model: provider.cleanExcelData[i],
                              i: 0,
                            );
                            setState(() {
                              provider.cleanExcelData[i] = result;
                            });
                          },
                          child:
                              TimelogWidget(tl: provider.cleanExcelData[i].in1),
                        ),
                        InkWell(
                          hoverColor: Colors.grey[300],
                          onTap: () async {
                            var result = await showTimeDialog(
                              context: context,
                              model: provider.cleanExcelData[i],
                              i: 1,
                            );
                            setState(() {
                              provider.cleanExcelData[i] = result;
                            });
                          },
                          child: TimelogWidget(
                              tl: provider.cleanExcelData[i].out1),
                        ),
                        InkWell(
                          hoverColor: Colors.grey[300],
                          onTap: () async {
                            var result = await showTimeDialog(
                              context: context,
                              model: provider.cleanExcelData[i],
                              i: 2,
                            );
                            setState(() {
                              provider.cleanExcelData[i] = result;
                            });
                          },
                          child:
                              TimelogWidget(tl: provider.cleanExcelData[i].in2),
                        ),
                        InkWell(
                          hoverColor: Colors.grey[300],
                          onTap: () async {
                            var result = await showTimeDialog(
                              context: context,
                              model: provider.cleanExcelData[i],
                              i: 3,
                            );
                            setState(() {
                              provider.cleanExcelData[i] = result;
                            });
                          },
                          child: TimelogWidget(
                              tl: provider.cleanExcelData[i].out2),
                        ),
                        Container(
                          width: durw,
                          decoration: const BoxDecoration(
                            // color: Colors.cyan,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].duration,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: tardyw,
                          decoration: const BoxDecoration(
                            // color: Colors.indigo,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].lateIn,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: tardybw,
                          decoration: const BoxDecoration(
                            // color: Colors.lime,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].lateBreak,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: otw,
                          decoration: const BoxDecoration(
                            // color: Colors.teal,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].overtime,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: udiw,
                          decoration: const BoxDecoration(
                            // color: Colors.teal,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].undertimeIn,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: udbw,
                          decoration: const BoxDecoration(
                            // color: Colors.teal,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].undertimeBreak
                                .toString(),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
