import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/history_provider.dart';
import '../model/log_model.dart';

class LogsWidget extends StatefulWidget {
  const LogsWidget({super.key, required this.logs});
  final List<Log> logs;

  @override
  State<LogsWidget> createState() => _LogsWidgetState();
}

class _LogsWidgetState extends State<LogsWidget> {
  final textStyleImage = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
    fontSize: 13.0,
  );

  TextStyle fontStyleFunc(String logType) {
    return TextStyle(
      color: logType == 'IN' ? Colors.green : Colors.red,
      fontSize: 13.0,
    );
  }

  static const String imageFolder = 'http://103.62.153.74:53000/field_api/';

  static const String googleMapsUrl = 'https://maps.google.com/maps?q=loc:';

  @override
  Widget build(BuildContext context) {
    var history = Provider.of<HistoryProvider>(context, listen: false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int j = 0; j < widget.logs.length; j++) ...[
          if (widget.logs[j].isSelfie == '1') ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.logs[j].logType,
                    style: fontStyleFunc(widget.logs[j].logType)),
                Text(
                  history.dateFormat12or24Web(widget.logs[j].timeStamp),
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
              iconSize: 20.0,
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
                Text(widget.logs[j].logType,
                    style: fontStyleFunc(widget.logs[j].logType)),
                Text(history.dateFormat12or24Web(widget.logs[j].timeStamp),
                    style: fontStyleFunc(widget.logs[j].logType)),
              ],
            ),
            const SizedBox(width: 15.0),
          ],
        ],
      ],
    );
  }
}
