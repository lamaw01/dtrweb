import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/home_data.dart';
import '../widget/logs_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final idController = TextEditingController();
  final fromController =
      TextEditingController(text: DateFormat.yMEd().format(DateTime.now()));
  final toController =
      TextEditingController(text: DateFormat.yMEd().format(DateTime.now()));
  final scrollController = ScrollController();

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  Future<DateTime> showDateFromDialog({required BuildContext context}) async {
    var instance = Provider.of<HomeData>(context, listen: false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick Date'),
          content: SizedBox(
            height: 200.0,
            width: 300.0,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: instance.selectedFrom,
              onDateTimeChanged: (DateTime newDateTime) {
                instance.selectedFrom = newDateTime;
              },
              use24hFormat: false,
              minuteInterval: 1,
              maximumYear: DateTime.now().year,
              minimumYear: 1999,
            ),
          ),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return instance.selectedFrom;
  }

  Future<DateTime> showDateToDialog({required BuildContext context}) async {
    var instance = Provider.of<HomeData>(context, listen: false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick Date'),
          content: SizedBox(
            height: 200.0,
            width: 300.0,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: instance.selectedTo,
              onDateTimeChanged: (DateTime newDateTime) {
                instance.selectedTo = newDateTime;
              },
              use24hFormat: false,
              minuteInterval: 1,
              maximumYear: DateTime.now().year,
              minimumYear: 1999,
            ),
          ),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return instance.selectedTo;
  }

  Color? getDataRowColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.grey[300];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<HomeData>(context);
    const String title = 'UC-1 DTR History';

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: Scrollbar(
        // thickness: 20,
        thumbVisibility: true,
        trackVisibility: true,
        // interactive: true,
        // radius: const Radius.circular(15),
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10.0),
                SizedBox(
                  height: 250.0,
                  width: 800.0,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'From :',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 300.0,
                                child: TextField(
                                  style: const TextStyle(fontSize: 20.0),
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        12.0, 12.0, 12.0, 12.0),
                                  ),
                                  controller: fromController,
                                  onTap: () async {
                                    instance.selectedFrom =
                                        await showDateFromDialog(
                                            context: context);
                                    setState(() {
                                      fromController.text = DateFormat.yMEd()
                                          .format(instance.selectedFrom);
                                    });
                                  },
                                ),
                              ),
                              const Text(
                                'To :',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 300.0,
                                child: TextField(
                                  style: const TextStyle(fontSize: 20.0),
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        12.0, 12.0, 12.0, 12.0),
                                  ),
                                  controller: toController,
                                  onTap: () async {
                                    instance.selectedTo =
                                        await showDateToDialog(
                                            context: context);
                                    setState(() {
                                      toController.text = DateFormat.yMEd()
                                          .format(instance.selectedTo);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(fontSize: 20.0),
                                  decoration: const InputDecoration(
                                    label: Text('*ID number or Name'),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        12.0, 12.0, 12.0, 12.0),
                                  ),
                                  controller: idController,
                                  onSubmitted: (data) {
                                    if (idController.text.isEmpty) {
                                      // get records all
                                      instance.getRecordsAll();
                                    } else {
                                      // get records with id or name
                                      instance.getRecords(
                                        employeeId: idController.text.trim(),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          Container(
                            color: Colors.green[300],
                            width: double.infinity,
                            height: 50.0,
                            child: TextButton(
                              onPressed: () {
                                if (idController.text.isEmpty) {
                                  // get records all
                                  instance.getRecordsAll();
                                } else {
                                  // get records with id or name
                                  instance.getRecords(
                                    employeeId: idController.text.trim(),
                                  );
                                }
                              },
                              child: const Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (instance.historyList.isNotEmpty) ...[
                  DataTable(
                    showCheckboxColumn: false,
                    dataRowColor:
                        MaterialStateProperty.resolveWith(getDataRowColor),
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'ID No.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'NAME',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'DATE',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'TIME',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    rows: <DataRow>[
                      for (int i = 0; i < instance.historyList.length; i++) ...[
                        DataRow(
                          // onSelectChanged: (value) {},
                          selected: i % 2 == 0 ? true : false,
                          cells: <DataCell>[
                            DataCell(SelectableText(
                                instance.historyList[i].employeeId)),
                            DataCell(
                                SelectableText(instance.historyList[i].name)),
                            DataCell(SelectableText(DateFormat.yMMMEd()
                                .format(instance.historyList[i].date))),
                            DataCell(
                                LogsWidget(logs: instance.historyList[i].logs)),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 25.0),
                  if (instance.historyList.length < instance.rowCount) ...[
                    SizedBox(
                      height: 50.0,
                      width: 200.0,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green[300],
                        ),
                        onPressed: () {
                          if (instance.historyList.length < instance.rowCount) {
                            if (idController.text.isEmpty) {
                              instance.loadMoreAll(
                                id: instance.getLowestId(
                                    instance.historyList.last.logs),
                                dateFrom: instance.selectedFrom,
                                dateTo: instance.historyList.last.date,
                              );
                            } else {
                              instance.loadMore(
                                employeeId: idController.text.trim(),
                                dateFrom: instance.selectedFrom,
                                dateTo: instance.historyList.last.date,
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Load more..',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                  ],
                  Text(
                    'Showing ${instance.historyList.length} out of ${instance.rowCount} results.',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 50.0),
                ] else if (instance.historyList.isEmpty &&
                    idController.text.isNotEmpty) ...[
                  const SizedBox(height: 25.0),
                  const Text(
                    'No data found.',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
