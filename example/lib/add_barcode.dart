import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer_example/main.dart';

class AddBarcode extends StatefulWidget {
  const AddBarcode({Key? key}) : super(key: key);

  @override
  State<AddBarcode> createState() => _AddBarcodeState();
}

class _AddBarcodeState extends State<AddBarcode> {
  var _orientation = PrintOrientation.horizontal;
  var _type = BarcodeType.code128;
  var _ratio = BarcodeRatio.ratio0;
  var _showData = false;
  var _dataTextFont = Font.font0;
  final _xController = TextEditingController();
  final _yController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _dataController = TextEditingController();
  final _dataTextSizeController = TextEditingController();
  final _dataTextOffsetController = TextEditingController();

  Future<void> _onPressed(context) async {
    final navigator = Navigator.of(context);
    try {
      await MyApp.printer?.addBarcode(BarcodeParams(
        orientation: _orientation,
        type: _type,
        ratio: _ratio,
        xPosition: int.parse(_xController.text),
        yPosition: int.parse(_yController.text),
        barWidthUnit: int.parse(_widthController.text),
        height: int.parse(_heightController.text),
        data: _dataController.text,
        dataTextParams: BarcodeDataTextParams(
          font: _dataTextFont,
          size: int.parse(_dataTextSizeController.text),
          offset: int.parse(_dataTextOffsetController.text),
        )
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
                    const Text('Type'),
                    DropdownButton<BarcodeType>(
                      items: const [
                        DropdownMenuItem(
                            value: BarcodeType.upca, child: Text('UPC-A')),
                        DropdownMenuItem(
                            value: BarcodeType.upce, child: Text('UPC-E')),
                        DropdownMenuItem(
                            value: BarcodeType.code39, child: Text('code39')),
                        DropdownMenuItem(
                            value: BarcodeType.code93, child: Text('code93')),
                        DropdownMenuItem(
                            value: BarcodeType.code128, child: Text('code128')),
                        DropdownMenuItem(
                            value: BarcodeType.ean8, child: Text('EAN-8')),
                        DropdownMenuItem(
                            value: BarcodeType.ean13, child: Text('EAN-13')),
                        DropdownMenuItem(
                            value: BarcodeType.codabar, child: Text('CODABAR')),
                      ],
                      onChanged: (item) {
                        _type = item!;
                        setState(() {});
                      },
                      value: _type,
                    ),
                    const Text('Ratio'),
                    DropdownButton<BarcodeRatio>(
                      items: const [
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio0, child: Text('0=1:5:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio1, child: Text('1=2:0:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio2, child: Text('2=2:5:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio3, child: Text('3=3:0:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio4, child: Text('4=3:5:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio20,
                            child: Text('20=2:0:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio21,
                            child: Text('21=2:1:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio22,
                            child: Text('22=2:2:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio23,
                            child: Text('23=2:3:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio24,
                            child: Text('24=2:4:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio25,
                            child: Text('25=2:5:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio26,
                            child: Text('26=2:6:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio27,
                            child: Text('27=2:7:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio28,
                            child: Text('28=2:8:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio29,
                            child: Text('29=2:9:1')),
                        DropdownMenuItem(
                            value: BarcodeRatio.ratio30,
                            child: Text('30=3:0:1')),
                      ],
                      onChanged: (item) {
                        _ratio = item!;
                        setState(() {});
                      },
                      value: _ratio,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'bar width unit',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _widthController,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'height',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _heightController,
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
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'data',
                      ),
                      keyboardType: TextInputType.text,
                      controller: _dataController,
                    ),
                    const Text('Show Data'),
                    Checkbox(value: _showData, onChanged: (value) {
                      _showData = value ?? false;
                      setState(() {});
                    }),
                    const Text('Data Font'),
                    DropdownButton<Font>(
                      items: const [
                        DropdownMenuItem(
                            value: Font.font0, child: Text('Font 0:12x24。')),
                        DropdownMenuItem(
                            value: Font.font1,
                            child: Text('Font 1:12x24(中文模式下打印繁体)，英文模式下字体变成(9x17)大小')),
                        DropdownMenuItem(
                            value: Font.font2, child: Text('Font 2:8x16。')),
                        DropdownMenuItem(
                            value: Font.font3, child: Text('Font 3:20x20。')),
                        DropdownMenuItem(
                            value: Font.font4,
                            child: Text('Font 4:32x32或者16x32，由ID3字体宽高各放大两倍。')),
                        DropdownMenuItem(
                            value: Font.font7,
                            child: Text('Font 7:24x24或者12x24，视中英文而定。')),
                        DropdownMenuItem(
                            value: Font.font8,
                            child: Text('Font 8:24x24或者12x24，视中英文而定。')),
                        DropdownMenuItem(
                            value: Font.font20,
                            child: Text('Font 20:16x16或者8x16，视中英文而定。')),
                        DropdownMenuItem(
                            value: Font.font28,
                            child: Text('Font 24:24x24或者12x24，视中英文而定。')),
                        DropdownMenuItem(
                            value: Font.font55,
                            child: Text('Font 55:16x16或者8x16，视中英文而定。')),
                      ],
                      onChanged: (item) {
                        _dataTextFont = item!;
                        setState(() {});
                      },
                      value: _dataTextFont,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Data text size',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _dataTextSizeController,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Data text offset',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _dataTextOffsetController,
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
