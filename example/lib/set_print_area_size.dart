import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer/printer/n31_classes.dart';
import 'package:flutter_label_printer/printer/n31_printer.dart';
import 'package:flutter_label_printer_example/main.dart';

class SetPrintAreaSize extends StatefulWidget {
  const SetPrintAreaSize({Key? key}) : super(key: key);

  @override
  State<SetPrintAreaSize> createState() => _SetPrintAreaSizeState();
}

class _SetPrintAreaSizeState extends State<SetPrintAreaSize> {
  final offsetController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final quantityController = TextEditingController();

  Future<void> _onPressed(context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final printer = MyApp.printer;
      if (printer is HMA300LPrinter) {
        printer.setPrintAreaSizeParams(HaninCPCLPrintAreaSizeParams(
          offset: int.parse(offsetController.text),
          height: int.parse(heightController.text),
          quantity: int.parse(quantityController.text),
        ));
      } else if (printer is N31Printer) {
        printer.setPrintAreaSizeParams(HaninTSPLPrintAreaSizeParams(
          width: int.parse(widthController.text),
          height: int.parse(heightController.text),
        ));
      }
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
        body: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Offset',
                      ),
                      keyboardType: TextInputType.number,
                      controller: offsetController,
                    ),
                    if (MyApp.printer is N31Printer)
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Width',
                        ),
                        keyboardType: TextInputType.number,
                        controller: widthController,
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
                  ])));
        }));
  }
}
