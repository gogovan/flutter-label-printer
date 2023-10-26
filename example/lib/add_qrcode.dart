import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer_example/main.dart';

class AddQRCode extends StatefulWidget {
  const AddQRCode({Key? key}) : super(key: key);

  @override
  State<AddQRCode> createState() => _AddQRCodeState();
}

class _AddQRCodeState extends State<AddQRCode> {
  var rotation = Rotation90.text;
  final xController = TextEditingController();
  final yController = TextEditingController();
  final unitSizeController = TextEditingController();
  final dataController = TextEditingController();

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      MyApp.printer?.addQRCode(
        PrintQRCode(
          xPosition: double.parse(xController.text),
          yPosition: double.parse(yController.text),
          data: dataController.text,
          unitSize: double.parse(unitSizeController.text),
          rotation: rotation.rot.toDouble(),
        ),
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
                    const Text('Rotation'),
                    DropdownButton<Rotation90>(
                      items: const [
                        DropdownMenuItem(
                            value: Rotation90.text,
                            child: Text('0 counterclockwise')),
                        DropdownMenuItem(
                            value: Rotation90.text90,
                            child: Text('90 counterclockwise')),
                        DropdownMenuItem(
                            value: Rotation90.text180,
                            child: Text('180 counterclockwise')),
                        DropdownMenuItem(
                            value: Rotation90.text270,
                            child: Text('270 counterclockwise')),
                      ],
                      onChanged: (item) {
                        rotation = item!;
                        setState(() {});
                      },
                      value: rotation,
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
                    const Text('Model'),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'unit size',
                      ),
                      keyboardType: TextInputType.number,
                      controller: unitSizeController,
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
                        child: const Text("Add QR Code")),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Back"))
                  ])));
        }));
  }
}
