import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer_example/main.dart';

class SetPaperType extends StatefulWidget {
  const SetPaperType({Key? key}) : super(key: key);

  @override
  State<SetPaperType> createState() => _SetPaperTypeState();
}

class _SetPaperTypeState extends State<SetPaperType> {
  PaperType paperType = PaperType.continuous;

  Future<void> _onPressed(context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await MyApp.printer?.setPaperType(paperType);
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Paper Type Set")));
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Set Paper Type'),
        ),
        body: Column(children: [
          DropdownButton<PaperType>(
            items: const [
              DropdownMenuItem(
                  value: PaperType.continuous, child: Text('Continuous')),
              DropdownMenuItem(
                  value: PaperType.label, child: Text('Label')),
              DropdownMenuItem(
                  value: PaperType.blackMark2Inch, child: Text('2 Inch Black Mark')),
              DropdownMenuItem(
                  value: PaperType.blackMark3Inch, child: Text('3 Inch Black Mark')),
              DropdownMenuItem(
                  value: PaperType.blackMark4Inch, child: Text('4 Inch Black Mark')),
            ],
            onChanged: (item) {
              paperType = item!;
              setState(() {});
            },
            value: paperType,
          ),
          ElevatedButton(
              onPressed: () => _onPressed(context),
              child: const Text("Set Paper Type")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"))
        ]));
  }
}
