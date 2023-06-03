import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/user_model.dart';

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int j = 0; j < widget.logs.length; j++) ...[
          InkWell(
            onTap: () async {
              if (widget.logs[j].isSelfie == '1') {
                await launchUrl(Uri.parse(
                    'http://uc-1.dnsalias.net:55083/dtrwebapi/show_image.php?id=${widget.logs[j].id}'));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.logs[j].logType,
                  style: widget.logs[j].isSelfie == '1' ? textStyleImage : null,
                ),
                const SizedBox(height: 5.0),
                Text(
                  DateFormat('hh:mm:ss aa').format(
                    widget.logs[j].timeStamp,
                  ),
                  style: widget.logs[j].isSelfie == '1' ? textStyleImage : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 30.0),
        ],
      ],
    );
  }
}
