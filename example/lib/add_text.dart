import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer/printer/n31_classes.dart';
import 'package:flutter_label_printer/printer/n31_printer.dart';
import 'package:flutter_label_printer_example/main.dart';

class AddText extends StatefulWidget {
  const AddText({Key? key}) : super(key: key);

  @override
  State<AddText> createState() => _AddTextState();
}

class _AddTextState extends State<AddText> {
  var rotation = Rotation90.text;

  final xController = TextEditingController();
  final yController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final textController = TextEditingController();

  var hma300font = HMA300LFont.font0;
  var n31font = N31Font.fontChinese;

  var alignment = N31PrinterTextAlign.left;

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      final printer = MyApp.printer;
      if (printer is HMA300LPrinter) {
        await printer.addTextParams(HMA300LTextParams(
          rotate: rotation,
          font: hma300font,
          xPosition: int.parse(xController.text),
          yPosition: int.parse(yController.text),
          text: textController.text,
        ));
      } else if (printer is N31Printer) {
        await printer.addTextParams(
          N31TextParams(
            xPos: int.parse(xController.text),
            yPos: int.parse(yController.text),
            text: textController.text,
            rotate: rotation,
            font: n31font,
            alignment: alignment,
          ),
        );
      }
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
              if (MyApp.printer is HMA300LPrinter)
                DropdownButton<HMA300LFont>(
                  items: const [
                    DropdownMenuItem(
                        value: HMA300LFont.font0, child: Text('Font 0:12x24。')),
                    DropdownMenuItem(
                        value: HMA300LFont.font1,
                        child:
                            Text('Font 1:12x24(中文模式下打印繁体)，英文模式下字体变成(9x17)大小')),
                    DropdownMenuItem(
                        value: HMA300LFont.font2, child: Text('Font 2:8x16。')),
                    DropdownMenuItem(
                        value: HMA300LFont.font3, child: Text('Font 3:20x20。')),
                    DropdownMenuItem(
                        value: HMA300LFont.font4,
                        child: Text('Font 4:32x32或者16x32，由ID3字体宽高各放大两倍。')),
                    DropdownMenuItem(
                        value: HMA300LFont.font7,
                        child: Text('Font 7:24x24或者12x24，视中英文而定。')),
                    DropdownMenuItem(
                        value: HMA300LFont.font8,
                        child: Text('Font 8:24x24或者12x24，视中英文而定。')),
                    DropdownMenuItem(
                        value: HMA300LFont.font20,
                        child: Text('Font 20:16x16或者8x16，视中英文而定。')),
                    DropdownMenuItem(
                        value: HMA300LFont.font28,
                        child: Text('Font 24:24x24或者12x24，视中英文而定。')),
                    DropdownMenuItem(
                        value: HMA300LFont.font55,
                        child: Text('Font 55:16x16或者8x16，视中英文而定。')),
                  ],
                  onChanged: (item) {
                    setState(() {
                      hma300font = item!;
                    });
                  },
                  value: hma300font,
                ),
              if (MyApp.printer is N31Printer)
                DropdownButton<N31Font>(
                  items: const [
                    DropdownMenuItem(
                        value: N31Font.fontTriumvirate,
                        child: Text(
                            'Font 0: Monotye CG Triumvirate Bold Condensed, font width and height is stretchable')),
                    DropdownMenuItem(
                        value: N31Font.font1,
                        child: Text('Font 1: 8 x 12 fixed pitch dot font')),
                    DropdownMenuItem(
                        value: N31Font.font2,
                        child: Text('Font 2: 12 x 20 fixed pitch dot font')),
                    DropdownMenuItem(
                        value: N31Font.font3,
                        child: Text('Font 3: 16 x 24 fixed pitch dot font')),
                    DropdownMenuItem(
                        value: N31Font.font4,
                        child: Text('Font 4: 24 x 32 fixed pitch dot font')),
                    DropdownMenuItem(
                        value: N31Font.font5,
                        child: Text('Font 5: 32 x 48 dot fixed pitch font')),
                    DropdownMenuItem(
                        value: N31Font.font6,
                        child:
                            Text('Font 6: 14 x 19 dot fixed pitch font OCR-B')),
                    DropdownMenuItem(
                        value: N31Font.font7,
                        child:
                            Text('Font 7: 21 x 27 dot fixed pitch font OCR-B')),
                    DropdownMenuItem(
                        value: N31Font.font8,
                        child:
                            Text('Font 8: 14 x25 dot fixed pitch font OCR-A')),
                    DropdownMenuItem(
                        value: N31Font.fontChinese,
                        child: Text('Font 9:只有这个字体能够打印中文。')),
                  ],
                  onChanged: (item) {
                    setState(() {
                      n31font = item!;
                    });
                  },
                  value: n31font,
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
              if (MyApp.printer is N31Printer)
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'width',
                  ),
                  keyboardType: TextInputType.number,
                  controller: widthController,
                ),
              if (MyApp.printer is N31Printer)
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
              if (MyApp.printer is N31Printer) const Text('Align'),
              if (MyApp.printer is N31Printer)
                DropdownButton<N31PrinterTextAlign>(
                  items: const [
                    DropdownMenuItem(
                        value: N31PrinterTextAlign.left, child: Text('Left')),
                    DropdownMenuItem(
                        value: N31PrinterTextAlign.center,
                        child: Text('Center')),
                    DropdownMenuItem(
                        value: N31PrinterTextAlign.right, child: Text('Right')),
                  ],
                  onChanged: (item) {
                    setState(() {
                      alignment = item!;
                    });
                  },
                  value: alignment,
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
