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
  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    var instance = Provider.of<HomeData>(context, listen: false);
    if (instance.scheduleList.isNotEmpty) {
      dropdownValue = instance.scheduleList[0];
    }
  }

  Future<CleanExcelDataModel> showChangeScheduleDialog({
    required BuildContext context,
    required CleanExcelDataModel model,
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
    var version = 'v${instance.appVersion}';

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
        child: SingleChildScrollView(
          primary: true,
          scrollDirection: Axis.horizontal,
          child: Consumer<HomeData>(builder: (ctx, provider, widget) {
            var w = MediaQuery.of(context).size.width;
            var h = MediaQuery.of(context).size.height;
            debugPrint('w $w h $h');
            return SizedBox(
              width: 1920.0,
              height: 1080.0,
              child: ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
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
                          width: 50.0,
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
                            try {
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
                            } catch (e) {
                              debugPrint('$e showChangeScheduleDialog');
                            }
                          },
                          child: Ink(
                            width: 80.0,
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
                          width: 80.0,
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
                          width: 200.0,
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
                        TimelogWidget(tl: provider.cleanExcelData[i].in1),
                        TimelogWidget(tl: provider.cleanExcelData[i].out1),
                        TimelogWidget(tl: provider.cleanExcelData[i].in2),
                        TimelogWidget(tl: provider.cleanExcelData[i].out2),
                        // InkWell(
                        //   hoverColor: Colors.grey[300],
                        //   onTap: () {
                        //     if (provider.cleanExcelData[i].in1.isSelfie ==
                        //         '1') {
                        //       launchUrl(
                        //         Uri.parse(
                        //             '${HttpService.serverUrl}/show_image.php?id=${provider.cleanExcelData[i].logs[0].id}'),
                        //       );
                        //     }
                        //   },
                        //   child: Ink(
                        //     width: 220.0,
                        //     decoration: const BoxDecoration(
                        //       // color: Colors.red,
                        //       border: Border(
                        //         right: BorderSide(width: 1, color: Colors.grey),
                        //       ),
                        //     ),
                        //     child: Text(
                        //       provider.cleanExcelData[i].in1.timestamp,
                        //       maxLines: 1,
                        //       textAlign: TextAlign.center,
                        //       overflow: TextOverflow.ellipsis,
                        //       style: TextStyle(
                        //         color: colorIsSelfie(
                        //             provider.cleanExcelData[i].in1.isSelfie),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // Ink(
                        //   width: 220.0,
                        //   decoration: const BoxDecoration(
                        //     // color: Colors.yellow,
                        //     border: Border(
                        //       right: BorderSide(width: 1, color: Colors.grey),
                        //     ),
                        //   ),
                        //   child: Text(
                        //     provider.cleanExcelData[i].out1.timestamp,
                        //     maxLines: 1,
                        //     textAlign: TextAlign.center,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: TextStyle(
                        //       color: colorIsSelfie(
                        //           provider.cleanExcelData[i].out1.isSelfie),
                        //     ),
                        //   ),
                        // ),
                        // Container(
                        //   width: 220.0,
                        //   decoration: const BoxDecoration(
                        //     // color: Colors.purple,
                        //     border: Border(
                        //       right: BorderSide(width: 1, color: Colors.grey),
                        //     ),
                        //   ),
                        //   child: Text(
                        //     provider.cleanExcelData[i].in2.timestamp,
                        //     maxLines: 1,
                        //     textAlign: TextAlign.center,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: TextStyle(
                        //       color: colorIsSelfie(
                        //           provider.cleanExcelData[i].in2.isSelfie),
                        //     ),
                        //   ),
                        // ),
                        // Container(
                        //   width: 220.0,
                        //   decoration: const BoxDecoration(
                        //     // color: Colors.pink,
                        //     border: Border(
                        //       right: BorderSide(width: 1, color: Colors.grey),
                        //     ),
                        //   ),
                        //   child: Text(
                        //     provider.cleanExcelData[i].out1.timestamp,
                        //     maxLines: 1,
                        //     textAlign: TextAlign.center,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: TextStyle(
                        //       color: colorIsSelfie(
                        //           provider.cleanExcelData[i].out1.isSelfie),
                        //     ),
                        //   ),
                        // ),
                        Container(
                          width: 150.0,
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
                          width: 150.0,
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
                          width: 150.0,
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
                          width: 150.0,
                          decoration: const BoxDecoration(
                            // color: Colors.teal,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.cleanExcelData[i].overtime.toString(),
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
