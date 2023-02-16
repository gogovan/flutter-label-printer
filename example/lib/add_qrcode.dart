import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer_example/main.dart';

class AddQRCode extends StatefulWidget {
  const AddQRCode({Key? key}) : super(key: key);

  @override
  State<AddQRCode> createState() => _AddQRCodeState();
}

class _AddQRCodeState extends State<AddQRCode> {
  var _orientation = PrintOrientation.horizontal;
  var _qrModel = QRCodeModel.normal;
  final _xController = TextEditingController();
  final _yController = TextEditingController();
  final _unitSizeController = TextEditingController();
  final _dataController = TextEditingController();

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      await MyApp.printer?.addQRCode(QRCodeParams(
          orientation: _orientation,
        xPosition: int.parse(_xController.text),
        yPosition: int.parse(_yController.text),
        model: _qrModel,
        unitSize: int.parse(_unitSizeController.text),
        data: _dataController.text
      ));
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
                    const Text('Orientation'),
                    DropdownButton<PrintOrientation>(
                      items: const [
                        DropdownMenuItem(
                            value: PrintOrientation.horizontal,
                            child: Text('Horizontal')),
                        DropdownMenuItem(
                            value: PrintOrientation.vertical,
                            child: Text('Vertical')),
                      ],
                      onChanged: (item) {
                        _orientation = item!;
                        setState(() {});
                      },
                      value: _orientation,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'x',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _xController,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'y',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _yController,
                    ),
                    const Text('Model'),
                    DropdownButton<QRCodeModel>(
                      items: const [
                        DropdownMenuItem(
                            value: QRCodeModel.normal,
                            child: Text('普通类型')),
                        DropdownMenuItem(
                            value: QRCodeModel.extraSymbols,
                            child: Text('在类型1的基础上增加了个别的符号')),
                      ],
                      onChanged: (item) {
                        _qrModel = item!;
                        setState(() {});
                      },
                      value: _qrModel,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'unit size',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _unitSizeController,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'data',
                      ),
                      keyboardType: TextInputType.text,
                      controller: _dataController,
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
