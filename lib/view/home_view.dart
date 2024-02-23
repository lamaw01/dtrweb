import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/department_provider.dart';
import '../data/excel_provider.dart';
import '../data/history_provider.dart';
import '../data/schedule_provider.dart';
import '../data/version_provider.dart';
import '../model/department_model.dart';
import '../widget/logs_widget.dart';
import 'excel_view.dart';

final _is24HourFormat = ValueNotifier(false);
ValueNotifier<bool> get is24HourFormat => _is24HourFormat;

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

  @override
  void initState() {
    super.initState();
    final department = Provider.of<DepartmentProvider>(context, listen: false);
    final schedule = Provider.of<ScheduleProvider>(context, listen: false);
    final version = Provider.of<VersionProvider>(context, listen: false);
    final excel = Provider.of<ExcelProvider>(context, listen: false);
    department.departmentList.add(dropdownValue);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await version.getPackageInfo();
      await department.getDepartment();
      await schedule.getSchedule();
      await excel.getSettings();
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
    var history = Provider.of<HistoryProvider>(context, listen: false);
    var dateFrom = await showDatePicker(
      context: context,
      initialDate: history.selectedFrom,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
    );
    if (dateFrom != null) {
      history.selectedFrom = dateFrom;
    }
    return history.selectedFrom;
  }

  Future<DateTime> showDateToDialog({required BuildContext context}) async {
    var history = Provider.of<HistoryProvider>(context, listen: false);
    var dateTo = await showDatePicker(
      context: context,
      initialDate: history.selectedTo,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
    );
    if (dateTo != null) {
      history.selectedTo = dateTo;
    }
    return history.selectedTo;
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
    const String title = 'UC-1 DTR History';
    final department = Provider.of<DepartmentProvider>(context, listen: false);

    final version = Provider.of<VersionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(title),
            const SizedBox(
              width: 2.5,
            ),
            Text(
              "v${version.version}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          Consumer<HistoryProvider>(builder: (context, history, widget) {
            if (history.historyList.isNotEmpty && history.isSoloUser()) {
              return InkWell(
                onTap: () async {
                  history.changeLoadingState(true);
                  await Future.delayed(const Duration(seconds: 1));
                  history.changeLoadingState(false);

                  if (mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ExcelView(historyList: history.historyList),
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
              );
            }
            return const SizedBox();
          }),
        ],
      ),
      body: Consumer<HistoryProvider>(builder: (ctx, history, widget) {
        return Scrollbar(
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
                    valueListenable: history.isLoading,
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
                  if (MediaQuery.of(context).size.width > 600) ...[
                    SizedBox(
                      height: 315.0,
                      width: 800.0,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        history.selectedFrom =
                                            await showDateFromDialog(
                                                context: context);
                                        setState(() {
                                          fromController.text =
                                              DateFormat.yMEd()
                                                  .format(history.selectedFrom);
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
                                        history.selectedTo =
                                            await showDateToDialog(
                                                context: context);
                                        setState(() {
                                          toController.text = DateFormat.yMEd()
                                              .format(history.selectedTo);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        onChanged:
                                            (DepartmentModel? value) async {
                                          if (value != null) {
                                            setState(() {
                                              dropdownValue = value;
                                            });
                                          }
                                        },
                                        items: department.departmentList.map<
                                                DropdownMenuItem<
                                                    DepartmentModel>>(
                                            (DepartmentModel value) {
                                          return DropdownMenuItem<
                                              DepartmentModel>(
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
                                        history.changeLoadingState(true);
                                        await Future.delayed(
                                            const Duration(seconds: 1));
                                        if (idController.text.isEmpty) {
                                          // get records all
                                          await history.getRecordsAll(
                                              department: dropdownValue);
                                        } else {
                                          // get records with id or name
                                          await history.getRecords(
                                              employeeId:
                                                  idController.text.trim(),
                                              department: dropdownValue);
                                        }
                                        history.changeLoadingState(false);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 5.0),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '24 Hour format: ',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: is24HourFormat,
                                    builder: (_, value, __) {
                                      return Checkbox(
                                        value: is24HourFormat.value,
                                        onChanged: (newCheckboxState) {
                                          is24HourFormat.value =
                                              newCheckboxState!;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (history.historyList.isNotEmpty) ...[
                                const SizedBox(height: 5.0),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        history.exportRawLogsExcel();
                                      },
                                      child: Ink(
                                        height: 30.0,
                                        width: 150.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: Colors.orange[300],
                                        ),
                                        padding: const EdgeInsets.all(5.0),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.download,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              'Export Raw Log excel',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15.0),
                                    InkWell(
                                      onTap: () {
                                        history.saveTextFile();
                                        // history.testTime();
                                      },
                                      child: Ink(
                                        height: 30.0,
                                        width: 150.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: Colors.orange[300],
                                        ),
                                        padding: const EdgeInsets.all(5.0),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.download,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              'Export EXF File',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10.0),
                              Container(
                                color: Colors.green[300],
                                width: double.infinity,
                                height: 50.0,
                                child: TextButton(
                                  onPressed: () async {
                                    history.changeLoadingState(true);
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    if (idController.text.isEmpty) {
                                      // get records all
                                      await history.getRecordsAll(
                                          department: dropdownValue);
                                    } else {
                                      // get records with id or name
                                      await history.getRecords(
                                          employeeId: idController.text.trim(),
                                          department: dropdownValue);
                                    }
                                    history.changeLoadingState(false);
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
                    if (history.historyList.isNotEmpty) ...[
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
                          for (int i = 0; i < history.uiList.length; i++) ...[
                            DataRow(
                              // onSelectChanged: (value) {},
                              selected: i % 2 == 0 ? true : false,
                              cells: <DataCell>[
                                DataCell(SelectableText(
                                  history.uiList[i].employeeId,
                                  style: const TextStyle(fontSize: 13.0),
                                )),
                                DataCell(SelectableText(
                                  '${history.uiList[i].lastName}, ${history.uiList[i].firstName} ${history.uiList[i].middleName}',
                                  style: const TextStyle(fontSize: 13.0),
                                )),
                                DataCell(SelectableText(
                                  DateFormat.yMMMEd()
                                      .format(history.uiList[i].date),
                                  style: const TextStyle(fontSize: 13.0),
                                )),
                                DataCell(
                                    LogsWidget(logs: history.uiList[i].logs)),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      if (history.uiList.length <
                          history.historyList.length) ...[
                        SizedBox(
                          height: 50.0,
                          width: 180.0,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green[300],
                            ),
                            onPressed: () {
                              if (history.uiList.length <
                                  history.historyList.length) {
                                history.loadMore();
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
                        'Showing ${history.uiList.length} out of ${history.historyList.length} results.',
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 50.0),
                    ] else if (history.historyList.isEmpty) ...[
                      const SizedBox(height: 25.0),
                      if (history.selectedFrom.isAfter(history.selectedTo)) ...[
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
                  ] else ...[
                    SizedBox(
                      height: 350.0,
                      width: 400.0,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 35.0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'From :',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 250.0,
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
                                          history.selectedFrom =
                                              await showDateFromDialog(
                                                  context: context);
                                          setState(() {
                                            fromController.text =
                                                DateFormat.yMEd().format(
                                                    history.selectedFrom);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              SizedBox(
                                height: 35.0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'To :',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 250.0,
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
                                          history.selectedTo =
                                              await showDateToDialog(
                                                  context: context);
                                          setState(() {
                                            toController.text =
                                                DateFormat.yMEd()
                                                    .format(history.selectedTo);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              SizedBox(
                                height: 35.0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Department: ',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      height: 35.0,
                                      width: 250.0,
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
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          value: dropdownValue,
                                          onChanged:
                                              (DepartmentModel? value) async {
                                            if (value != null) {
                                              setState(() {
                                                dropdownValue = value;
                                              });
                                            }
                                          },
                                          items: department.departmentList.map<
                                                  DropdownMenuItem<
                                                      DepartmentModel>>(
                                              (DepartmentModel value) {
                                            return DropdownMenuItem<
                                                DepartmentModel>(
                                              value: value,
                                              child: Text(value.departmentName),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              SizedBox(
                                height: 35.0,
                                child: Row(
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
                                          history.changeLoadingState(true);
                                          await Future.delayed(
                                              const Duration(seconds: 1));
                                          if (idController.text.isEmpty) {
                                            // get records all
                                            await history.getRecordsAll(
                                                department: dropdownValue);
                                          } else {
                                            // get records with id or name
                                            await history.getRecords(
                                                // employeeId: idController.text.trim(),
                                                employeeId:
                                                    idController.text.trim(),
                                                department: dropdownValue);
                                          }
                                          history.changeLoadingState(false);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              SizedBox(
                                height: 30.0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '24 Hour format: ',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: is24HourFormat,
                                      builder: (_, value, __) {
                                        return Checkbox(
                                          value: is24HourFormat.value,
                                          onChanged: (newCheckboxState) {
                                            is24HourFormat.value =
                                                newCheckboxState!;
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (history.historyList.isNotEmpty) ...[
                                const SizedBox(height: 5.0),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        history.exportRawLogsExcel();
                                      },
                                      child: Ink(
                                        height: 30.0,
                                        width: 150.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: Colors.orange[300],
                                        ),
                                        padding: const EdgeInsets.all(5.0),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.download,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              'Export Raw Log excel',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15.0),
                                    InkWell(
                                      onTap: () {
                                        history.saveTextFile();
                                        // history.testTime();
                                      },
                                      child: Ink(
                                        height: 30.0,
                                        width: 150.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: Colors.orange[300],
                                        ),
                                        padding: const EdgeInsets.all(5.0),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.download,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              'Export EXF File',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10.0),
                              Container(
                                color: Colors.green[300],
                                width: double.infinity,
                                height: 40.0,
                                child: TextButton(
                                  onPressed: () async {
                                    history.changeLoadingState(true);
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    if (idController.text.isEmpty) {
                                      // get records all
                                      await history.getRecordsAll(
                                          department: dropdownValue);
                                    } else {
                                      // get records with id or name
                                      await history.getRecords(
                                          employeeId: idController.text.trim(),
                                          department: dropdownValue);
                                    }
                                    history.changeLoadingState(false);
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
                    if (history.historyList.isNotEmpty) ...[
                      for (int i = 0; i < history.uiList.length; i++) ...[
                        Container(
                          height: 100.0,
                          color: i % 2 == 0 ? null : Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: 200.0,
                                    // color: Colors.green,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Date: '),
                                        Text(
                                          DateFormat.yMMMEd()
                                              .format(history.uiList[i].date),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style:
                                              const TextStyle(fontSize: 13.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150.0,
                                    // color: Colors.blue,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Id No: '),
                                        Text(history.uiList[i].employeeId),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              SizedBox(
                                width: 400.0,
                                // color: Colors.red,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Name: '),
                                    Text(
                                      '${history.uiList[i].lastName}, ${history.uiList[i].firstName} ${history.uiList[i].middleName}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 13.0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2.5),
                              const Divider(height: 5.0),
                              const SizedBox(height: 2.5),
                              LogsWidget(logs: history.uiList[i].logs)
                            ],
                          ),
                        ),
                      ],
                    ]
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
