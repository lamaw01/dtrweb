import 'package:flutter/material.dart';

import '../model/log_model.dart';

class TimelogWidget extends StatelessWidget {
  const TimelogWidget({super.key, required this.tl});
  final TimeLog tl;

  @override
  Widget build(BuildContext context) {
    Color colorIsSelfie(String selfie) {
      if (selfie == '1') {
        return Colors.blue;
      }
      return Colors.black;
    }

    return Container(
      width: 180.0,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: Text(
        tl.timestamp,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colorIsSelfie(tl.isSelfie),
        ),
      ),
    );
  }
}
