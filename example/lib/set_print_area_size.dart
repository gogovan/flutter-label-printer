import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer_example/main.dart';

class SetPrintAreaSize extends StatefulWidget {
  const SetPrintAreaSize({Key? key}) : super(key: key);

  @override
  State<SetPrintAreaSize> createState() => _SetPrintAreaSizeState();
}

class _SetPrintAreaSizeState extends State<SetPrintAreaSize> {
  final offsetController = TextEditingController();
  final heightController = TextEditingController();
  final quantityController = TextEditingController();
  var hRes = LabelResolution.res200;
  var vRes = LabelResolution.res200;

  Future<void> _onPressed(context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await MyApp.printer?.setPrintAreaSize(PrintAreaSizeParams(
        offset: int.parse(offsetController.text),
        horizontalRes: hRes,
        verticalRes: vRes,
        height: int.parse(heightController.text),
        quantity: int.parse(quantityController.text),
      ));
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Print Area Size Parameters Set")));
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
              hintText: 'Offset',
            ),
            keyboardType: TextInputType.number,
            controller: offsetController,
          ),
          const Text('Horizontal Resolution'),
          DropdownButton<LabelResolution>(
            items: const [
              DropdownMenuItem(
                  value: LabelResolution.res100, child: Text('100')),
              DropdownMenuItem(
                  value: LabelResolution.res200, child: Text('200')),
            ],
            onChanged: (item) {
              hRes = item!;
              setState(() {});
            },
            value: hRes,
          ),
          const Text('Vertical Resolution'),
          DropdownButton<LabelResolution>(
            items: const [
              DropdownMenuItem(
                  value: LabelResolution.res100, child: Text('100')),
              DropdownMenuItem(
                  value: LabelResolution.res200, child: Text('200')),
            ],
            onChanged: (item) {
              vRes = item!;
              setState(() {});
            },
            value: vRes,
          ),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Height',
            ),
            keyboardType: TextInputType.number,
            controller: heightController,
          ),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Quantity',
            ),
            keyboardType: TextInputType.number,
            controller: quantityController,
          ),
          ElevatedButton(
              onPressed: () => _onPressed(context),
              child: const Text("Set Print Area Size")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"))
        ]));
  }
}
