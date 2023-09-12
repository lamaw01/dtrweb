import 'package:flutter/material.dart';

import '../model/log_model.dart';

class TimelogWidget extends StatelessWidget {
  const TimelogWidget({
    super.key,
    required this.tl,
    required this.w,
  });
  final TimeLog tl;
  final double w;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      decoration: const BoxDecoration(
        // color: Colors.blueGrey,
        border: Border(
          // right: BorderSide(width: 1, color: Colors.grey),
          left: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: Text(
        tl.timestamp,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: tl.isSelfie == '1' ? Colors.blue : Colors.black,
        ),
      ),
    );
  }
}
