import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'data/department_provider.dart';
import 'data/excel_provider.dart';
import 'data/history_provider.dart';
import 'data/schedule_provider.dart';
import 'data/version_provider.dart';
import 'view/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DepartmentProvider>(
          create: (_) => DepartmentProvider(),
        ),
        ChangeNotifierProvider<ScheduleProvider>(
          create: (_) => ScheduleProvider(),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
        ),
        ChangeNotifierProvider<VersionProvider>(
          create: (_) => VersionProvider(),
        ),
        ChangeNotifierProvider<ExcelProvider>(
          create: (_) => ExcelProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // scrollBehavior: const MaterialScrollBehavior().copyWith(
      //   dragDevices: {
      //     PointerDeviceKind.mouse,
      //     PointerDeviceKind.touch,
      //     PointerDeviceKind.stylus,
      //     PointerDeviceKind.unknown
      //   },
      //   overscroll: true,
      //   scrollbars: true,
      // ),
      scrollBehavior: CustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'UC-1 DTR History',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      home: const HomeView(),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
