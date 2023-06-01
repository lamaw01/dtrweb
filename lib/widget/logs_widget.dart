import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/user_model.dart';

class LogsWidget extends StatefulWidget {
  const LogsWidget({super.key, required this.logs});
  final List<Log> logs;

  @override
  State<LogsWidget> createState() => _LogsWidgetState();
}

class _LogsWidgetState extends State<LogsWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int j = 0; j < widget.logs.length; j++) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.logs[j].logType),
              const SizedBox(height: 5.0),
              Text(DateFormat('hh:mm:ss aa').format(widget.logs[j].timeStamp)),
            ],
          ),
          const SizedBox(width: 30.0),
        ],
      ],
    );
  }
}
