import 'package:flutter/material.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer_example/main.dart';

class AddBarcode extends StatefulWidget {
  const AddBarcode({Key? key}) : super(key: key);

  @override
  State<AddBarcode> createState() => _AddBarcodeState();
}

class _AddBarcodeState extends State<AddBarcode> {
  var _orientation = HMA300LPrintOrientation.horizontal;
  var _type = HMA300LBarcodeType.code128;
  var _ratio = HMA300LBarcodeRatio.ratio0;
  var _showData = false;
  var _dataTextFont = HMA300LFont.font0;
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
      await MyApp.printer?.addBarcode(HMA300LBarcodeParams(
        orientation: _orientation,
        type: _type,
        ratio: _ratio,
        xPosition: int.parse(_xController.text),
        yPosition: int.parse(_yController.text),
        barWidthUnit: int.parse(_widthController.text),
        height: int.parse(_heightController.text),
        data: _dataController.text,
        dataTextParams: HMA300LBarcodeDataTextParams(
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
                    DropdownButton<HMA300LPrintOrientation>(
                      items: const [
                        DropdownMenuItem(
                            value: HMA300LPrintOrientation.horizontal,
                            child: Text('Horizontal')),
                        DropdownMenuItem(
                            value: HMA300LPrintOrientation.vertical,
                            child: Text('Vertical')),
                      ],
                      onChanged: (item) {
                        _orientation = item!;
                        setState(() {});
                      },
                      value: _orientation,
                    ),
                    const Text('Type'),
                    DropdownButton<HMA300LBarcodeType>(
                      items: const [
                        DropdownMenuItem(
                            value: HMA300LBarcodeType.upca, child: Text('UPC-A')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeType.upce, child: Text('UPC-E')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeType.code39, child: Text('code39')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeType.code93, child: Text('code93')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeType.code128, child: Text('code128')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeType.ean8, child: Text('EAN-8')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeType.ean13, child: Text('EAN-13')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeType.codabar, child: Text('CODABAR')),
                      ],
                      onChanged: (item) {
                        _type = item!;
                        setState(() {});
                      },
                      value: _type,
                    ),
                    const Text('Ratio'),
                    DropdownButton<HMA300LBarcodeRatio>(
                      items: const [
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio0, child: Text('0=1:5:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio1, child: Text('1=2:0:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio2, child: Text('2=2:5:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio3, child: Text('3=3:0:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio4, child: Text('4=3:5:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio20,
                            child: Text('20=2:0:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio21,
                            child: Text('21=2:1:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio22,
                            child: Text('22=2:2:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio23,
                            child: Text('23=2:3:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio24,
                            child: Text('24=2:4:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio25,
                            child: Text('25=2:5:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio26,
                            child: Text('26=2:6:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio27,
                            child: Text('27=2:7:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio28,
                            child: Text('28=2:8:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio29,
                            child: Text('29=2:9:1')),
                        DropdownMenuItem(
                            value: HMA300LBarcodeRatio.ratio30,
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
