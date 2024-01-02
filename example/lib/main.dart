import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_printer.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_printer.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_label_printer/printer_searcher/bluetooth_printer_searcher.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/templating/printer_template/hanin_cpcl_template_printer.dart';
import 'package:flutter_label_printer/templating/printer_template/hanin_tspl_template_printer.dart';
import 'package:flutter_label_printer/templating/printer_template/image_template_printer.dart';
import 'dart:io';

import 'package:flutter_label_printer/printer_searcher/bluetooth_printer_searcher.dart';
import 'package:flutter_label_printer/printer_searcher/usb_printer_searcher.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';
import 'package:flutter_label_printer/templating/template.dart';
import 'package:flutter_label_printer/templating/template_printer.dart';
import 'package:flutter_label_printer_example/add_barcode.dart';
import 'package:flutter_label_printer_example/add_image.dart';
import 'package:flutter_label_printer_example/add_line.dart';
import 'package:flutter_label_printer_example/add_qrcode.dart';
import 'package:flutter_label_printer_example/add_rectangle.dart';
import 'package:flutter_label_printer_example/add_text.dart';
import 'package:flutter_label_printer_example/set_print_area_size.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

enum PrinterModel { cpcl, tspl, image }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static TemplatablePrinterInterface? printer;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BluetoothPrinterSearcher _searcher = BluetoothPrinterSearcher();
  final UsbPrinterSearcher _usbSearcher = UsbPrinterSearcher();

  List<PrinterSearchResult> _searchResults = [];
  bool _searching = false;
  bool _connected = false;

  PrinterModel _printerModel = PrinterModel.image;

  final connectIndexController = TextEditingController();

  String? _filePath;

  String _exceptionText = '';

  @override
  void dispose() {
    connectIndexController.dispose();
    super.dispose();
  }

  StreamSubscription<List<PrinterSearchResult>>? _searchSubscription;
  Future<void> _startSearch() async {
    try {
      setState(() {
        _searching = true;
      });

      _searchSubscription = _searcher.search().listen((event) {
        setState(() {
          _searchResults = event;
        });
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  Future<void> _stopSearch() async {
    try {
      _searchSubscription?.cancel();
      setState(() {
        _searching = false;
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  StreamSubscription<List<PrinterSearchResult>>? _usbSearchSubscription;
  Future<void> _startUsbSearch() async {
    try {
      setState(() {
        _searching = true;
      });

      _usbSearchSubscription = _usbSearcher.search().listen((event) {
        setState(() {
          _searchResults = event;
        });
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  Future<void> _stopUsbSearch() async {
    try {
      _usbSearchSubscription?.cancel();
      setState(() {
        _searching = false;
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  Future<void> _connect() async {
    try {
      switch (_printerModel) {
        case PrinterModel.cpcl:
          PrinterSearchResult? result =
              _searchResults[int.parse(connectIndexController.text)];

          MyApp.printer = HaninCPCLTemplatePrinter(result);
          break;
        case PrinterModel.tspl:
          PrinterSearchResult? result =
              _searchResults[int.parse(connectIndexController.text)];

          MyApp.printer = HaninTSPLTemplatePrinter(result);
          break;
        case PrinterModel.image:
          _filePath = (await getDownloadsDirectory())?.path;
          MyApp.printer = ImageTemplatePrinter("$_filePath/output.png");
          break;
      }

      await MyApp.printer?.connect();
      setState(() {
        _connected = true;
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  Future<void> _disconnect() async {
    try {
      await MyApp.printer?.disconnect();
      setState(() {
        _connected = false;
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  Future<void> _printTestPage(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await MyApp.printer?.printTestPage();
      scaffoldMessenger
          .showSnackBar(const SnackBar(content: Text("Test page printed.")));
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  Future<void> _print(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await MyApp.printer?.print();

    if (_printerModel == PrinterModel.image) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content:
              Text('Print successful. Image saved to $_filePath/output.png.'),
        ),
      );
    } else {
      scaffoldMessenger
          .showSnackBar(const SnackBar(content: Text('Print successful.')));
    }
  }

  Future<void> _printTemplate(String templateName) async {
    try {
      final yml = await rootBundle.loadString('assets/$templateName.yaml');
      final template = Template.fromYaml(yml);

      await TemplatePrinter(MyApp.printer!, template,
          replaceStrings: {'world': 'Earth'}).printTemplate();
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  Future<void> _printImage() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/test.png';
      final data = await rootBundle.load('assets/test.png');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final file = File(path);
      try {
        await file.delete();
      } catch (_) {}
      await file.writeAsBytes(bytes);

      MyApp.printer!.setPrintAreaSize(PrintAreaSize(
        paperType: PrintPaperType.label,
        originX: 0,
        originY: 0,
        width: 80,
        height: 30,
      ));
      await MyApp.printer!
          .addImage(PrintImage(path: path, xPosition: 0, yPosition: 0));
      await MyApp.printer!.print();
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  Future<void> _getStatus(BuildContext context) async {
    try {
      dynamic result;
      switch (_printerModel) {
        case PrinterModel.cpcl:
          result = await (MyApp.printer as HaninCPCLPrinter).getStatus();
          break;
        case PrinterModel.tspl:
          result = await (MyApp.printer as HaninTSPLPrinter).getStatus();
          break;
      }

      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(title: Text('Status = $result'));
          });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
      setState(() {
        _exceptionText = ex.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('flutter_label_printer example app'),
          ),
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      Text('Exception = $_exceptionText'),
                      ElevatedButton(
                          onPressed: _startSearch,
                          child: const Text('Start Bluetooth search')),
                      ElevatedButton(
                          onPressed: _startUsbSearch,
                          child: const Text('Start USB search')),
                      Text('Searching = $_searching'),
                      Text('Search Result = ${_searchResults.toString()}\n'),
                      ElevatedButton(
                          onPressed: _stopSearch,
                          child: const Text('Stop Bluetooth search')),
                      ElevatedButton(
                          onPressed: _stopUsbSearch,
                          child: const Text('Stop USB search')),
                      TextField(
                        decoration: const InputDecoration(
                          hintText:
                              'Index of Search result to Connect Bluetooth to',
                        ),
                        keyboardType: TextInputType.number,
                        controller: connectIndexController,
                      ),
                      DropdownButton<PrinterModel>(
                          items: const [
                            DropdownMenuItem(
                              value: PrinterModel.cpcl,
                              child: Text('Hanin CPCL (e.g. HM-A300L)'),
                            ),
                            DropdownMenuItem(
                              value: PrinterModel.tspl,
                              child: Text('Hanin TSPL (e.g. N31)'),
                            ),
                            DropdownMenuItem(
                              value: PrinterModel.image,
                              child: Text('Image'),
                            ),
                          ],
                          value: _printerModel,
                          onChanged: (value) {
                            setState(() {
                              _printerModel = value ?? PrinterModel.cpcl;
                            });
                          }),
                      ElevatedButton(
                          onPressed: _connect, child: const Text('Connect')),
                      Text('Connected = $_connected\n'),
                      ElevatedButton(
                          onPressed: () => _getStatus(context),
                          child: const Text('Get Status')),
                      ElevatedButton(
                          onPressed: () => _printTestPage(context),
                          child: const Text('Print Test Page')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SetPrintAreaSize()));
                          },
                          child: const Text('Set Print Area Size')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddText()));
                          },
                          child: const Text('Add Text')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddBarcode()));
                          },
                          child: const Text('Add Barcode')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddQRCode()));
                          },
                          child: const Text('Add QRCode')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddRectangle()));
                          },
                          child: const Text('Add Rectangle')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddLine()));
                          },
                          child: const Text('Add Line')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddImage()));
                          },
                          child: const Text('Add Image')),
                      ElevatedButton(
                          onPressed: () => _print(context),
                          child: const Text('Print')),
                      ElevatedButton(
                          onPressed: () => _printTemplate('template'),
                          child: const Text('Print Template')),
                      ElevatedButton(
                          onPressed: () => _printTemplate('fonts'),
                          child: const Text('Print Font test')),
                      ElevatedButton(
                          onPressed: _printImage,
                          child: const Text('Print Image')),
                      ElevatedButton(
                          onPressed: _disconnect,
                          child: const Text('Disconnect')),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }
}
