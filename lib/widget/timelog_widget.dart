import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/log_model.dart';
import '../services/http_service.dart';

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

    if (tl.isSelfie == '1') {
      return InkWell(
        hoverColor: Colors.grey[300],
        onTap: () {
          if (tl.isSelfie == '1') {
            launchUrl(
              Uri.parse('${HttpService.serverUrl}/show_image.php?id=${tl.id}'),
            );
          }
        },
        child: Ink(
          width: 220.0,
          decoration: const BoxDecoration(
            // color: Colors.red,
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
        ),
      );
    }
    return Container(
      width: 220.0,
      decoration: const BoxDecoration(
        // color: Colors.red,
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
