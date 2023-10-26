import 'package:flutter/material.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer_example/main.dart';

class SetPrintAreaSize extends StatefulWidget {
  const SetPrintAreaSize({Key? key}) : super(key: key);

  @override
  State<SetPrintAreaSize> createState() => _SetPrintAreaSizeState();
}

class _SetPrintAreaSizeState extends State<SetPrintAreaSize> {
  var printPaperType = PrintPaperType.label;
  final originXController = TextEditingController();
  final originYController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final quantityController = TextEditingController();

  Future<void> _onPressed(context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      MyApp.printer?.setPrintAreaSize(PrintAreaSize(
        paperType: printPaperType,
        originX: double.tryParse(originXController.text),
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
        body: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(children: [
                    const Text('Model'),
                    DropdownButton<PrintPaperType>(
                      items: const [
                        DropdownMenuItem(
                            value: PrintPaperType.label,
                            child: Text('label paper')),
                        DropdownMenuItem(
                            value: PrintPaperType.continuous,
                            child: Text('continuous paper (e.g. Receipts)')),
                      ],
                      onChanged: (item) {
                        printPaperType = item!;
                        setState(() {});
                      },
                      value: printPaperType,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Origin X',
                      ),
                      keyboardType: TextInputType.number,
                      controller: originXController,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Origin Y',
                      ),
                      keyboardType: TextInputType.number,
                      controller: originYController,
                    ),
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
