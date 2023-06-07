import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'data/generate_qr_data.dart';
import 'data/home_data.dart';
import 'view/generate_qr_view.dart';
import 'view/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeData>(
          create: (_) => HomeData(),
        ),
        ChangeNotifierProvider<GenerateQr>(
          create: (_) => GenerateQr(),
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
      initialRoute: HomeView.route,
      routes: {
        HomeView.route: (context) => const HomeView(),
        GenerateQrView.route: (context) => const GenerateQrView(),
      },
      scrollBehavior: CustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'UC-1 DTR History',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
