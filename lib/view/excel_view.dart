import 'package:dtrweb/model/department_model.dart';
import 'package:dtrweb/model/excel_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/home_data.dart';
import '../model/schedule_model.dart';

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

  @override
  void initState() {
    super.initState();
    var instance = Provider.of<HomeData>(context, listen: false);
    if (instance.scheduleList.isNotEmpty) {
      dropdownValue = instance.scheduleList[0];
    }
  }

  Future<ExcelModel> showChangeScheduleDialog({
    required BuildContext context,
    required ExcelModel model,
  }) async {
    var instance = Provider.of<HomeData>(context, listen: false);
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
                instance.reCalcLate(model: model, newSchedule: dropdownValue);
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
    debugPrint('${model.duration} ${model.lateIn} ${model.lateBreak}');
    return model;
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<HomeData>(context, listen: false);
    const String title = 'UC-1 DTR History';

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          InkWell(
            onTap: () {
              instance.remakeExcel();
            },
            child: Ink(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(10),
                color: Colors.orange[300],
              ),
              padding: const EdgeInsets.all(5.0),
              child: const Row(
                children: [
                  Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  Text(
                    'Export excel',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<HomeData>(builder: (ctx, provider, widget) {
        return Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: instance.isLogging,
              builder: (context, value, child) {
                if (value) {
                  return LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    color: Colors.orange[300],
                    minHeight: 10,
                  );
                }
                return const SizedBox();
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.excelList.length,
                itemBuilder: (ctx, i) {
                  var schedCode = '';
                  if (provider.excelList[i].scheduleModel != null) {
                    schedCode = provider.excelList[i].scheduleModel!.schedId;
                  }

                  return InkWell(
                    hoverColor: Colors.lightBlue,
                    onTap: () async {
                      try {
                        dropdownValue = provider.scheduleList.singleWhere((e) =>
                            e.schedId ==
                            provider.excelList[i].scheduleModel!.schedId);
                        var result = await showChangeScheduleDialog(
                          context: context,
                          model: provider.excelList[i],
                        );
                        setState(() {
                          provider.excelList[i] = result;
                        });
                      } catch (e) {
                        debugPrint('$e showChangeScheduleDialog');
                      }
                    },
                    child: Ink(
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
                            width: 50.0,
                            decoration: const BoxDecoration(
                              // color: Colors.orange,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].rowCount.toString(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 80.0,
                            decoration: const BoxDecoration(
                              // color: Colors.green,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              schedCode,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 80.0,
                            decoration: const BoxDecoration(
                              // color: Colors.green,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].employeeId,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 200.0,
                            decoration: const BoxDecoration(
                              // color: Colors.blue,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].name,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180.0,
                            decoration: const BoxDecoration(
                              // color: Colors.red,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].timeIn1,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180.0,
                            decoration: const BoxDecoration(
                              // color: Colors.yellow,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].timeOut1,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180.0,
                            decoration: const BoxDecoration(
                              // color: Colors.purple,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].timeIn2,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180.0,
                            decoration: const BoxDecoration(
                              // color: Colors.pink,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].timeOut2,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180.0,
                            decoration: const BoxDecoration(
                              // color: Colors.cyan,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].duration.toString(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180.0,
                            decoration: const BoxDecoration(
                              // color: Colors.indigo,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].lateIn.toString(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180.0,
                            decoration: const BoxDecoration(
                              // color: Colors.lime,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].lateBreak.toString(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180.0,
                            decoration: const BoxDecoration(
                              // color: Colors.teal,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              provider.excelList[i].overtime.toString(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
