import 'package:flutter/material.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer_example/main.dart';

class AddLine extends StatefulWidget {
  const AddLine({Key? key}) : super(key: key);

  @override
  State<AddLine> createState() => _AddRectangleState();
}

class _AddRectangleState extends State<AddLine> {
  final _x0Controller = TextEditingController();
  final _y0Controller = TextEditingController();
  final _x1Controller = TextEditingController();
  final _y1Controller = TextEditingController();
  final _widthController = TextEditingController();

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      MyApp.printer?.addLine(PrintRect(
          rect: Rect.fromLTRB(
              double.parse(_x0Controller.text),
              double.parse(_y0Controller.text),
              double.parse(_x1Controller.text),
              double.parse(_y1Controller.text)),
          strokeWidth: double.parse(_widthController.text)));
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
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'x0',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _x0Controller,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'y0',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _y0Controller,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'x1',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _x1Controller,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'y1',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _y1Controller,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'width',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _widthController,
                    ),
                    ElevatedButton(
                        onPressed: () => _onPressed(context),
                        child: const Text("Add Line")),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Back"))
                  ])));
        }));
  }
}
