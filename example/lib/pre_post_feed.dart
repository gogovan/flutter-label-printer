import 'package:flutter/material.dart';
import 'package:flutter_label_printer_example/main.dart';

class PrePostFeed extends StatefulWidget {
  const PrePostFeed({Key? key}) : super(key: key);

  @override
  State<PrePostFeed> createState() => _PrePostFeedState();
}

class _PrePostFeedState extends State<PrePostFeed> {
  final prefeedController = TextEditingController();
  final postfeedController = TextEditingController();

  Future<void> _onPrefeedPressed(context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await MyApp.printer?.prefeed(int.parse(prefeedController.text));
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Prefeed Set")));
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _onPostfeedPressed(context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await MyApp.printer?.postfeed(int.parse(postfeedController.text));
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Postfeed Set")));
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Set Print Area Size'),
        ),
        body: Column(children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Prefeed',
            ),
            keyboardType: TextInputType.number,
            controller: prefeedController,
          ),
          ElevatedButton(
              onPressed: () => _onPrefeedPressed(context),
              child: const Text("Set prefeed")),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Postfeed',
            ),
            keyboardType: TextInputType.number,
            controller: postfeedController,
          ),
          ElevatedButton(
              onPressed: () => _onPostfeedPressed(context),
              child: const Text("Set postfeed")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"))
        ]));
  }
}
