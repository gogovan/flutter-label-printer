import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer_example/main.dart';

class SetTextSize extends StatefulWidget {
  const SetTextSize({Key? key}) : super(key: key);

  @override
  State<SetTextSize> createState() => _SetTextSizeState();
}

class _SetTextSizeState extends State<SetTextSize> {
  var width = 1;
  var height = 1;

  Future<void> _onPressed(context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await (MyApp.printer as HMA300LPrinter).setTextSize(width, height);
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Text Size Parameters Set")));
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Text Size'),
      ),
      body: Column(
        children: [
          const Text('Width'),
          DropdownButton<int>(
            items: List.generate(
                16,
                (index) => DropdownMenuItem(
                    value: index + 1, child: Text((index + 1).toString()))),
            onChanged: (item) {
              width = item!;
              setState(() {});
            },
            value: width,
          ),
          const Text('Height'),
          DropdownButton<int>(
            items: List.generate(
                16,
                    (index) => DropdownMenuItem(
                    value: index + 1, child: Text((index + 1).toString()))),
            onChanged: (item) {
              height = item!;
              setState(() {});
            },
            value: height,
          ),
          ElevatedButton(
              onPressed: () => _onPressed(context),
              child: const Text("Set Text Size")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"))
        ],
      ),
    );
  }
}
