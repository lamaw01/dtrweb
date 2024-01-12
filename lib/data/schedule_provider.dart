import 'package:flutter/material.dart';

import '../model/schedule_model.dart';
import '../services/http_service.dart';

class ScheduleProvider with ChangeNotifier {
  final _scheduleList = <ScheduleModel>[];
  List<ScheduleModel> get scheduleList => _scheduleList;

  Future<void> getSchedule() async {
    try {
      final result = await HttpService.geSchedule();
      _scheduleList.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e getSchedule');
    }
  }
}
