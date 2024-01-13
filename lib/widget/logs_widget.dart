import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/excel_provider.dart';
import '../model/log_model.dart';
import '../services/http_service.dart';

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
                  Uri.parse(
                      '${HttpService.serverUrl}/show_image.php?id=${widget.logs[j].id}'),
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
