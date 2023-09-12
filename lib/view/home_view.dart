import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/home_data.dart';
import '../model/department_model.dart';
import '../widget/logs_widget.dart';
import 'excel_view.dart';

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
  var dropdownValue =
      DepartmentModel(departmentId: '000', departmentName: 'All');

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
    instance.departmentList.add(dropdownValue);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await instance.getPackageInfo();
      await instance.getDepartment();
      await instance.getSchedule();
      instance.errorString.addListener(() => ScaffoldMessenger.of(context)
          .showSnackBar(showError(instance.errorString.value)));
    });
  }

  @override
  void dispose() {
    super.dispose();
    idController.dispose();
    fromController.dispose();
    toController.dispose();
  }

  Future<DateTime> showDateFromDialog({required BuildContext context}) async {
    var instance = Provider.of<HomeData>(context, listen: false);
    var dateFrom = await showDatePicker(
      context: context,
      initialDate: instance.selectedFrom,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
    );
    if (dateFrom != null) {
      instance.selectedFrom = dateFrom;
    }
    return instance.selectedFrom;
  }

  Future<DateTime> showDateToDialog({required BuildContext context}) async {
    var instance = Provider.of<HomeData>(context, listen: false);
    var dateTo = await showDatePicker(
      context: context,
      initialDate: instance.selectedTo,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
    );
    if (dateTo != null) {
      instance.selectedTo = dateTo;
    }
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
          if (instance.historyList.isNotEmpty) ...[
            InkWell(
              onTap: () async {
                instance.changeLoadingState(true);
                await Future.delayed(const Duration(seconds: 1));
                if (idController.text.isEmpty) {
                  // get records all
                  await instance.getRecordsAll(department: dropdownValue);
                } else {
                  // get records with id or name
                  await instance.getRecords(
                      employeeId: idController.text.trim(),
                      department: dropdownValue);
                }
                instance.changeLoadingState(false);
                instance.sortData();

                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExcelView(
                        idController: idController,
                        dropdownValue: dropdownValue,
                      ),
                    ),
                  );
                }
              },
              child: Ink(
                padding: const EdgeInsets.all(5.0),
                child: const Row(
                  children: [
                    Text(
                      'Advanced Mode',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      body: Scrollbar(
        // thickness: 18,
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
                const SizedBox(height: 10.0),
                SizedBox(
                  height: 280.0,
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
                                  style: const TextStyle(fontSize: 18.0),
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    isDense: true,
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
                                  style: const TextStyle(fontSize: 18.0),
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    isDense: true,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Department: ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                height: 40.0,
                                width: 640.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.grey,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<DepartmentModel>(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    borderRadius: BorderRadius.circular(5),
                                    value: dropdownValue,
                                    onChanged: (DepartmentModel? value) async {
                                      if (value != null) {
                                        setState(() {
                                          dropdownValue = value;
                                        });
                                      }
                                    },
                                    items: instance.departmentList
                                        .map<DropdownMenuItem<DepartmentModel>>(
                                            (DepartmentModel value) {
                                      return DropdownMenuItem<DepartmentModel>(
                                        value: value,
                                        child: Text(value.departmentName),
                                      );
                                    }).toList(),
                                  ),
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
                                  style: const TextStyle(fontSize: 18.0),
                                  decoration: const InputDecoration(
                                    label: Text('ID no. or Name'),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    isDense: true,
                                    contentPadding: EdgeInsets.fromLTRB(
                                        12.0, 12.0, 12.0, 12.0),
                                  ),
                                  controller: idController,
                                  onSubmitted: (data) async {
                                    instance.changeLoadingState(true);
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    if (idController.text.isEmpty) {
                                      // get records all
                                      await instance.getRecordsAll(
                                          department: dropdownValue);
                                    } else {
                                      // get records with id or name
                                      await instance.getRecords(
                                          // employeeId: idController.text.trim(),
                                          employeeId: idController.text.trim(),
                                          department: dropdownValue);
                                    }
                                    instance.changeLoadingState(false);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '24 Hour format: ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: instance.is24HourFormat,
                                builder: (_, value, __) {
                                  return Checkbox(
                                    value: instance.is24HourFormat.value,
                                    onChanged: (newCheckboxState) {
                                      instance.is24HourFormat.value =
                                          newCheckboxState!;
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            color: Colors.green[300],
                            width: double.infinity,
                            height: 50.0,
                            child: TextButton(
                              onPressed: () async {
                                instance.changeLoadingState(true);
                                await Future.delayed(
                                    const Duration(seconds: 1));
                                if (idController.text.isEmpty) {
                                  // get records all
                                  await instance.getRecordsAll(
                                      department: dropdownValue);
                                } else {
                                  // get records with id or name
                                  await instance.getRecords(
                                      employeeId: idController.text.trim(),
                                      department: dropdownValue);
                                }
                                instance.changeLoadingState(false);
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
                            'Name',
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
                      for (int i = 0; i < instance.uiList.length; i++) ...[
                        DataRow(
                          // onSelectChanged: (value) {},
                          selected: i % 2 == 0 ? true : false,
                          cells: <DataCell>[
                            DataCell(
                                SelectableText(instance.uiList[i].employeeId)),
                            DataCell(SelectableText(
                                '${instance.uiList[i].lastName}, ${instance.uiList[i].firstName} ${instance.uiList[i].middleName}')),
                            DataCell(SelectableText(DateFormat.yMMMEd()
                                .format(instance.uiList[i].date))),
                            DataCell(LogsWidget(logs: instance.uiList[i].logs)),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 25.0),
                  if (instance.uiList.length < instance.historyList.length) ...[
                    SizedBox(
                      height: 50.0,
                      width: 180.0,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green[300],
                        ),
                        onPressed: () {
                          if (instance.uiList.length <
                              instance.historyList.length) {
                            instance.loadMore();
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
                    'Showing ${instance.uiList.length} out of ${instance.historyList.length} results.',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 50.0),
                ] else if (instance.historyList.isEmpty) ...[
                  const SizedBox(height: 25.0),
                  if (instance.selectedFrom.isAfter(instance.selectedTo)) ...[
                    const Text(
                      'Date From is advance than Date To.',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'No data found.',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ]
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
