import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/home_data.dart';

class ExcelView extends StatefulWidget {
  const ExcelView({super.key});

  @override
  State<ExcelView> createState() => _ExcelViewState();
}

class _ExcelViewState extends State<ExcelView> {
  @override
  Widget build(BuildContext context) {
    const String title = 'UC-1 DTR History';

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: Consumer<HomeData>(builder: (ctx, provider, widget) {
        return ListView.builder(
          itemCount: provider.excelList.length,
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
                  if (i == 0) ...[
                    Container(
                      width: 50.0,
                      decoration: const BoxDecoration(
                        // color: Colors.orange,
                        border: Border(
                          right: BorderSide(width: 1, color: Colors.grey),
                        ),
                      ),
                      child: const Text(
                        '',
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
                      child: const Text(
                        'Emp ID',
                        maxLines: 1,
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
                      child: const Text(
                        'Name',
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
                      child: const Text(
                        'In',
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
                      child: const Text(
                        'Out',
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
                      child: const Text(
                        'In',
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
                      child: const Text(
                        'Out',
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
                      child: const Text(
                        'Duration(Hours)',
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
                      child: const Text(
                        'Late In(Minutes)',
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
                      child: const Text(
                        'Late Break(Minutes)',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 50.0,
                      decoration: const BoxDecoration(
                        // color: Colors.orange,
                        border: Border(
                          right: BorderSide(width: 1, color: Colors.grey),
                        ),
                      ),
                      child: Text(
                        provider.excelList[i].rowCount == 0
                            ? ''
                            : provider.excelList[i].rowCount.toString(),
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
                        provider.excelList[i].duration == 0
                            ? ''
                            : provider.excelList[i].duration.toString(),
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
                        provider.excelList[i].lateIn == 0
                            ? ''
                            : provider.excelList[i].lateIn.toString(),
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
                        provider.excelList[i].lateBreak == 0
                            ? ''
                            : provider.excelList[i].lateBreak.toString(),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
