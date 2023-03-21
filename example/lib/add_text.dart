import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer_example/main.dart';

class AddText extends StatefulWidget {
  const AddText({Key? key}) : super(key: key);

  @override
  State<AddText> createState() => _AddTextState();
}

class _AddTextState extends State<AddText> {
  var rotation = HMA300LRotation90.text;
  var font = HMA300LFont.font0;
  final xController = TextEditingController();
  final yController = TextEditingController();
  final textController = TextEditingController();

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      await MyApp.printer?.addTextParams(HMA300LTextParams(
        rotate: rotation,
        font: font,
        xPosition: int.parse(xController.text),
        yPosition: int.parse(yController.text),
        text: textController.text,
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
              DropdownButton<HMA300LRotation90>(
                items: const [
                  DropdownMenuItem(
                      value: HMA300LRotation90.text,
                      child: Text('0 counterclockwise')),
                  DropdownMenuItem(
                      value: HMA300LRotation90.text90,
                      child: Text('90 counterclockwise')),
                  DropdownMenuItem(
                      value: HMA300LRotation90.text180,
                      child: Text('180 counterclockwise')),
                  DropdownMenuItem(
                      value: HMA300LRotation90.text270,
                      child: Text('270 counterclockwise')),
                ],
                onChanged: (item) {
                  rotation = item!;
                  setState(() {});
                },
                value: rotation,
              ),
              const Text('Font'),
              DropdownButton<HMA300LFont>(
                items: const [
                  DropdownMenuItem(
                      value: HMA300LFont.font0, child: Text('Font 0:12x24。')),
                  DropdownMenuItem(
                      value: HMA300LFont.font1,
                      child: Text('Font 1:12x24(中文模式下打印繁体)，英文模式下字体变成(9x17)大小')),
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
                  font = item!;
                  setState(() {});
                },
                value: font,
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
                  hintText: 'Text',
                ),
                keyboardType: TextInputType.text,
                controller: textController,
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
