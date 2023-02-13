import 'package:flutter/material.dart';
import 'package:flutter_label_printer_example/main.dart';

class Prefeed extends StatefulWidget {
  const Prefeed({Key? key}) : super(key: key);

  @override
  State<Prefeed> createState() => _PrefeedState();
}

class _PrefeedState extends State<Prefeed> {
  final prefeedController = TextEditingController();

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
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            controller: prefeedController,
          ),
          ElevatedButton(
              onPressed: () => _onPrefeedPressed(context),
              child: const Text("Set prefeed")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"))
        ]));
  }
}
