import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_align.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_font.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_style.dart';
import 'package:flutter_label_printer_example/main.dart';

class AddText extends StatefulWidget {
  const AddText({Key? key}) : super(key: key);

  @override
  State<AddText> createState() => _AddTextState();
}

class _AddTextState extends State<AddText> {
  var rotation = Rotation90.text;
  var font = PrintTextFont.small;
  var align = PrintTextAlign.left;

  final xController = TextEditingController();
  final yController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final boldController = TextEditingController();
  final textController = TextEditingController();

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      MyApp.printer?.addText(PrintText(
        xPosition: double.parse(xController.text),
        yPosition: double.parse(yController.text),
        text: textController.text,
        rotation: rotation.rot.toDouble(),
        style: PrintTextStyle(
          font: font,
          width: double.tryParse(widthController.text),
          height: double.tryParse(heightController.text),
          bold: double.tryParse(boldController.text),
          align: align,
        ),
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
          title: const Text('Add Text'),
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
              const Text('Font'),
              DropdownButton<PrintTextFont>(
                  items: const [
                    DropdownMenuItem(
                        value: PrintTextFont.small, child: Text('Small')),
                    DropdownMenuItem(
                        value: PrintTextFont.medium, child: Text('Medium')),
                    DropdownMenuItem(
                        value: PrintTextFont.large, child: Text('Large')),
                    DropdownMenuItem(
                        value: PrintTextFont.vlarge, child: Text('Very large')),
                    DropdownMenuItem(
                        value: PrintTextFont.vvlarge,
                        child: Text('Very very large')),
                    DropdownMenuItem(
                        value: PrintTextFont.chinese, child: Text('Chinese')),
                    DropdownMenuItem(
                        value: PrintTextFont.chineseLarge,
                        child: Text('Chinese Large')),
                    DropdownMenuItem(
                        value: PrintTextFont.ocrSmall,
                        child: Text('OCR Small')),
                    DropdownMenuItem(
                        value: PrintTextFont.ocrLarge,
                        child: Text('OCR Large')),
                    DropdownMenuItem(
                        value: PrintTextFont.square, child: Text('Square')),
                    DropdownMenuItem(
                        value: PrintTextFont.triumvirate,
                        child: Text('Triumvirate')),
                  ],
                  onChanged: (item) {
                    setState(() {
                      font = item!;
                    });
                  },
                  value: font),
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
                  hintText: 'width',
                ),
                keyboardType: TextInputType.number,
                controller: widthController,
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
                  hintText: 'Text',
                ),
                keyboardType: TextInputType.text,
                controller: textController,
              ),
              const Text('Align'),
              DropdownButton<PrintTextAlign>(
                items: const [
                  DropdownMenuItem(
                      value: PrintTextAlign.left, child: Text('Left')),
                  DropdownMenuItem(
                      value: PrintTextAlign.center,
                      child: Text('Center')),
                  DropdownMenuItem(
                      value: PrintTextAlign.right, child: Text('Right')),
                ],
                onChanged: (item) {
                  setState(() {
                    align = item!;
                  });
                },
                value: align,
              ),
              ElevatedButton(
                  onPressed: () => _onPressed(context),
                  child: const Text("Add Text command")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Back"))
            ]),
          ));
        }));
  }
}
