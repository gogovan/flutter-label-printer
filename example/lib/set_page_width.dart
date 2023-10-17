import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer_example/main.dart';

class SetPageWidth extends StatefulWidget {
  const SetPageWidth({Key? key}) : super(key: key);

  @override
  State<SetPageWidth> createState() => _SetPageWidthState();
}

class _SetPageWidthState extends State<SetPageWidth> {
  final pageWidthController = TextEditingController();

  Future<void> _onPressed(context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await (MyApp.printer as HMA300LPrinter).setPageWidth(int.parse(pageWidthController.text));
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Page Width Set")));
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
              hintText: 'Page Width',
            ),
            keyboardType: const TextInputType.numberWithOptions(),
            controller: pageWidthController,
          ),
          ElevatedButton(
              onPressed: () => _onPressed(context),
              child: const Text("Set Page Width")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"))
        ]));
  }
}
