import 'package:flutter/material.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer_example/main.dart';

class AddBarcode extends StatefulWidget {
  const AddBarcode({Key? key}) : super(key: key);

  @override
  State<AddBarcode> createState() => _AddBarcodeState();
}

class _AddBarcodeState extends State<AddBarcode> {
  var type = PrintBarcodeType.code39;
  var showData = false;
  final xController = TextEditingController();
  final yController = TextEditingController();
  final heightController = TextEditingController();
  final dataController = TextEditingController();

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      MyApp.printer?.addBarcode(
        PrintBarcode(
            type: type,
            xPosition: double.parse(xController.text),
            yPosition: double.parse(yController.text),
            data: dataController.text,
            height: double.parse(heightController.text)),
      );

      navigator.pop();
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Barcode'),
        ),
        body: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(children: [
                    const Text('Type'),
                    DropdownButton<PrintBarcodeType>(
                      items: const [
                        DropdownMenuItem(
                            value: PrintBarcodeType.code39,
                            child: Text('code39')),
                        DropdownMenuItem(
                            value: PrintBarcodeType.code93,
                            child: Text('code93')),
                        DropdownMenuItem(
                            value: PrintBarcodeType.code128,
                            child: Text('code128')),
                        DropdownMenuItem(
                            value: PrintBarcodeType.upca,
                            child: Text('UPC-A')),
                        DropdownMenuItem(
                            value: PrintBarcodeType.ean13,
                            child: Text('EAN-13')),
                      ],
                      onChanged: (item) {
                        type = item!;
                        setState(() {});
                      },
                      value: type,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'height',
                      ),
                      keyboardType: TextInputType.number,
                      controller: heightController,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'x',
                      ),
                      keyboardType: TextInputType.number,
                      controller: xController,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'y',
                      ),
                      keyboardType: TextInputType.number,
                      controller: yController,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'data',
                      ),
                      keyboardType: TextInputType.text,
                      controller: dataController,
                    ),
                    ElevatedButton(
                        onPressed: () => _onPressed(context),
                        child: const Text("Add Barcode")),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Back"))
                  ])));
        }));
  }
}
