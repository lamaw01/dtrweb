import 'package:dtrweb/data/home_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test View'),
      ),
      body: Consumer<HomeData>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.cleanData.length,
            itemBuilder: ((context, i) {
              var name = provider.fullName(provider.cleanData[i]);
              return Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(name),
                    const SizedBox(width: 50.0),
                    for (var log in provider.cleanData[i].logs) ...[
                      Text(
                          '${log.logType} ${provider.dateFormat2.format(log.timeStamp)}'),
                      const SizedBox(width: 50.0),
                    ],
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
