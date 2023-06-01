import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/home_data.dart';
import '../widget/logs_widget.dart';
// import '../model/user_model.dart';

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
  static const branchList = <String>[
    'Balingasag',
    'Bansabai',
    'Barra',
    'BCTV',
    'Centrio',
    'Corrales',
    'El Salvador',
    'Headend',
    'Iponan',
    'Jade',
    'JR Borja',
    'Ketkai',
    'Main Office',
    'MBLY Headend',
    'MBLY Office',
    'Manolo',
    'Puerto',
    'UC-1',
    'Uptown',
    'Villanueva'
  ];
  String dropdownValue = branchList.first;
  bool valideID = false;
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();
  // final userList = <UserModel>[
  //   UserModel(
  //     id: 01152,
  //     name: 'Janrey Dumaog',
  //     date: 'May 15, 2023 (Mon)',
  //     outam: '',
  //     inpm: '20:56:32',
  //   ),
  //   UserModel(
  //     id: 01152,
  //     name: 'Janrey Dumaog',
  //     date: 'May 16, 2023 (Tue)',
  //     outam: '06:03:55',
  //     inpm: '06:01:29',
  //   ),
  //   UserModel(
  //     id: 01152,
  //     name: 'Janrey Dumaog',
  //     date: 'May 17, 2023 (Wed)',
  //     outam: '06:01:29',
  //     inpm: '20:55:24',
  //   ),
  //   UserModel(
  //     id: 01152,
  //     name: 'Janrey Dumaog',
  //     date: 'May 18, 2023 (Thu)',
  //     outam: '06:01:35',
  //     inpm: '21:02:13',
  //   ),
  //   UserModel(
  //     id: 01152,
  //     name: 'Janrey Dumaog',
  //     date: 'May 19, 2023 (Fri)',
  //     outam: '06:03:26',
  //     inpm: '20:58:04',
  //   ),
  //   UserModel(
  //     id: 01152,
  //     name: 'Janrey Dumaog',
  //     date: 'May 20, 2023 (Sat)',
  //     outam: '06:01:36',
  //     inpm: '20:55:37',
  //   ),
  //   UserModel(
  //     id: 01152,
  //     name: 'Janrey Dumaog',
  //     date: 'May 21, 2023 (Sun)',
  //     outam: '06:03:01',
  //     inpm: '',
  //   ),
  // ];

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  Future<DateTime> showDateDialog({required BuildContext context}) async {
    DateTime value = DateTime.now();
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
              initialDateTime: DateTime.now(),
              onDateTimeChanged: (DateTime newDateTime) {
                value = newDateTime;
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
    return value;
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<HomeData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UC-1 DTR History'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10.0,
            ),
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
                                contentPadding:
                                    EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                              ),
                              controller: fromController,
                              onTap: () async {
                                var fromSelected =
                                    await showDateDialog(context: context);
                                debugPrint(fromSelected.toString());
                                setState(() {
                                  fromController.text =
                                      DateFormat.yMEd().format(fromSelected);
                                });
                                debugPrint(fromController.text);
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
                                contentPadding:
                                    EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                              ),
                              controller: toController,
                              onTap: () async {
                                var toSelected =
                                    await showDateDialog(context: context);
                                debugPrint(toSelected.toString());
                                setState(() {
                                  toController.text =
                                      DateFormat.yMEd().format(toSelected);
                                });
                                debugPrint(fromController.text);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              elevation: 8,
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownValue = value!;
                                });
                                debugPrint(dropdownValue);
                              },
                              items: branchList.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: TextField(
                              style: const TextStyle(fontSize: 20.0),
                              decoration: InputDecoration(
                                label: const Text('*ID number'),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                errorText:
                                    valideID ? 'Value Can\'t Be Empty' : null,
                                contentPadding: const EdgeInsets.fromLTRB(
                                    12.0, 12.0, 12.0, 12.0),
                              ),
                              controller: idController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
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
                            setState(() {
                              idController.text.isEmpty
                                  ? valideID = true
                                  : valideID = false;
                            });
                            if (idController.text.isNotEmpty) {
                              instance.getRecords(
                                  employeeId: idController.text.trim());
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
              SizedBox(
                // color: Colors.orange,
                // width: 1200.0,
                height: 600.0,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'ID No.',
                          style: TextStyle(),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'NAME',
                          style: TextStyle(),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'DATE',
                          style: TextStyle(),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'LOGS',
                          style: TextStyle(),
                        ),
                      ),
                    ),
                  ],
                  rows: <DataRow>[
                    for (int i = 0; i < instance.historyList.length; i++) ...[
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text(instance.historyList[i].employeeId)),
                          DataCell(Text(instance.historyList[i].name)),
                          DataCell(Text(DateFormat.yMMMEd()
                              .format(instance.historyList[i].date))),
                          DataCell(
                              LogsWidget(logs: instance.historyList[i].logs)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
