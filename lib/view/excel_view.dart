import 'package:dtrweb/model/department_model.dart';
import 'package:dtrweb/model/excel_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/home_data.dart';
import '../model/schedule_model.dart';
import '../services/http_service.dart';

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
              instance.remakeExcel();
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
                itemCount: provider.excelList.length,
                itemBuilder: (ctx, i) {
                  var schedCode = '';
                  var timeLogIn2isSelfie =
                      provider.excelList[i].timeLogIn2?.isSelfie ?? '';
                  var timeLogOut2isSelfie =
                      provider.excelList[i].timeLogOut2?.isSelfie ?? '';
                  if (provider.excelList[i].scheduleModel != null) {
                    schedCode = provider.excelList[i].scheduleModel!.schedId;
                  }

                  var in1 = provider.friendlyDateFormat(
                      provider.excelList[i].timeLogIn1.timeLog);
                  var out1 = provider.friendlyDateFormat(
                      provider.excelList[i].timeLogOut1.timeLog);

                  var in2 = provider.friendlyDateFormat(
                      provider.excelList[i].timeLogIn2?.timeLog ?? '');
                  var out2 = provider.friendlyDateFormat(
                      provider.excelList[i].timeLogOut2?.timeLog ?? '');

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
                            provider.excelList[i].rowCount,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        InkWell(
                          hoverColor: Colors.grey,
                          onTap: () async {
                            try {
                              dropdownValue = provider.scheduleList.singleWhere(
                                  (e) =>
                                      e.schedId ==
                                      provider
                                          .excelList[i].scheduleModel!.schedId);
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
                        InkWell(
                          onTap: () {
                            if (provider.excelList[i].timeLogIn1.isSelfie ==
                                '1') {
                              launchUrl(
                                Uri.parse(
                                    '${HttpService.serverUrl}/show_image.php?id=${provider.excelList[i].logs![0].id}'),
                              );
                            }
                          },
                          child: Ink(
                            width: 220.0,
                            decoration: const BoxDecoration(
                              // color: Colors.red,
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              in1,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    provider.excelList[i].timeLogIn1.isSelfie ==
                                            '1'
                                        ? Colors.blue
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 220.0,
                          decoration: const BoxDecoration(
                            // color: Colors.yellow,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            out1,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  provider.excelList[i].timeLogOut1.isSelfie ==
                                          '1'
                                      ? Colors.blue
                                      : Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 220.0,
                          decoration: const BoxDecoration(
                            // color: Colors.purple,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            in2,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: timeLogIn2isSelfie == '1'
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 220.0,
                          decoration: const BoxDecoration(
                            // color: Colors.pink,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            out2,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: timeLogOut2isSelfie == '1'
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 150.0,
                          decoration: const BoxDecoration(
                            // color: Colors.cyan,
                            border: Border(
                              right: BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            provider.excelList[i].duration,
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
                            provider.excelList[i].lateIn,
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
                            provider.excelList[i].lateBreak,
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
                            provider.excelList[i].overtime,
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
