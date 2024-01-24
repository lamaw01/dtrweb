import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/excel_provider.dart';
import '../model/log_model.dart';

class LogsWidget extends StatefulWidget {
  const LogsWidget({super.key, required this.logs});
  final List<Log> logs;

  @override
  State<LogsWidget> createState() => _LogsWidgetState();
}

class _LogsWidgetState extends State<LogsWidget> {
  var textStyleImage = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  static const String imageFolder = 'http://103.62.153.74:53000/field_api/';

  static const String googleMapsUrl = 'https://maps.google.com/maps?q=loc:';

  @override
  Widget build(BuildContext context) {
    var excel = Provider.of<ExcelProvider>(context, listen: false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int j = 0; j < widget.logs.length; j++) ...[
          if (widget.logs[j].isSelfie == '1') ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.logs[j].logType,
                  style: textStyleImage,
                ),
                const SizedBox(height: 5.0),
                Text(
                  excel.dateFormat12or24Web(widget.logs[j].timeStamp),
                  style: textStyleImage,
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (String value) {
                String latlng = widget.logs[j].latlng.replaceAll(' ', ',');
                log('kani $latlng');

                if (value == 'Show Image') {
                  launchUrl(
                    Uri.parse('$imageFolder${widget.logs[j].imagePath}'),
                  );
                } else {
                  launchUrl(
                    Uri.parse('$googleMapsUrl$latlng'),
                  );
                }
              },
              tooltip: 'Menu',
              splashRadius: 15.0,
              padding: const EdgeInsets.all(0.0),
              itemBuilder: (BuildContext context) {
                return {'Show Image', 'Show Map'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ] else ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.logs[j].logType,
                ),
                const SizedBox(height: 5.0),
                Text(
                  excel.dateFormat12or24Web(widget.logs[j].timeStamp),
                ),
              ],
            ),
            const SizedBox(width: 30.0),
          ],
        ],
      ],
    );
  }
}
