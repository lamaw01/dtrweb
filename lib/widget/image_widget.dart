import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/user_model.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key, required this.images});
  final List<ImageId> images;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int j = 0; j < widget.images.length; j++) ...[
          InkWell(
            child: Text(
              DateFormat('hh:mm aa').format(widget.images[j].selfieTimestamp),
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () async {
              await launchUrl(Uri.parse(
                  'http://uc-1.dnsalias.net:55083/dtrwebapi/show_image.php?id=${widget.images[j].id}'));
            },
          ),
          const SizedBox(width: 15.0),
        ],
      ],
    );
  }
}
