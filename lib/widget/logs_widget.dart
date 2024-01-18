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

  @override
  Widget build(BuildContext context) {
    var excel = Provider.of<ExcelProvider>(context, listen: false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int j = 0; j < widget.logs.length; j++) ...[
          if (widget.logs[j].isSelfie == '1') ...[
            InkWell(
              hoverColor: Colors.transparent,
              onTap: () {
                launchUrl(
                  Uri.parse('$imageFolder${widget.logs[j].imagePath}'),
                );
              },
              child: Column(
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
            ),
            const SizedBox(width: 30.0),
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
