import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/printer/n31_printer.dart';
import 'package:flutter_label_printer/printer/printer_interface.dart';
import 'package:flutter_label_printer/printer_searcher/bluetooth_printer_searcher.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/templating/printer_template/hm_a300l_printer_template.dart';
import 'package:flutter_label_printer/templating/template.dart';
import 'package:flutter_label_printer/templating/template_printer.dart';
import 'package:flutter_label_printer_example/add_barcode.dart';
import 'package:flutter_label_printer_example/add_image.dart';
import 'package:flutter_label_printer_example/add_line.dart';
import 'package:flutter_label_printer_example/add_qrcode.dart';
import 'package:flutter_label_printer_example/add_rectangle.dart';
import 'package:flutter_label_printer_example/add_text.dart';
import 'package:flutter_label_printer_example/prefeed.dart';
import 'package:flutter_label_printer_example/set_page_width.dart';
import 'package:flutter_label_printer_example/set_print_area_size.dart';
import 'package:flutter_label_printer_example/set_text_size.dart';

void main() {
  runApp(const MyApp());
}

enum PrinterModel { HMA300, N31 }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static PrinterInterface? printer;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BluetoothPrinterSearcher _searcher = BluetoothPrinterSearcher();

  List<PrinterSearchResult> _searchResults = [];
  bool _searching = false;
  bool _connected = false;

  PrinterModel _printerModel = PrinterModel.HMA300;

  final connectIndexController = TextEditingController();

  @override
  void dispose() {
    connectIndexController.dispose();
    super.dispose();
  }

  Future<void> _startSearch() async {
    try {
      setState(() {
        _searching = true;
      });

      _searcher.search().listen((event) {
        setState(() {
          _searchResults = event;
        });
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _stopSearch() async {
    try {
      await _searcher.stopSearch();
      setState(() {
        _searching = false;
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _connect() async {
    try {
      PrinterSearchResult? result =
          _searchResults[int.parse(connectIndexController.text)];

      switch (_printerModel) {
        case PrinterModel.HMA300:
          MyApp.printer = HMA300LPrinterTemplate(result);
          break;
        case PrinterModel.N31:
          MyApp.printer = N31Printer(result);
          break;
      }

      await MyApp.printer?.connect();
      setState(() {
        _connected = true;
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
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
    }
  }

  Future<void> _print() async {
    try {
      switch (_printerModel) {
        case PrinterModel.HMA300:
          await (MyApp.printer as HMA300LPrinter).print();
          break;
        case PrinterModel.N31:
          await (MyApp.printer as N31Printer).print();
          break;
      }
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _printTemplate() async {
    try {
      final yml = await rootBundle.loadString('assets/template.yaml');
      final template = Template.fromYaml(yml);

      switch (_printerModel) {
        case PrinterModel.HMA300:
          await TemplatePrinter(
              MyApp.printer as HMA300LPrinterTemplate, template,
              replaceStrings: {'world': 'Earth'}).printTemplate();
          break;
        case PrinterModel.N31:
          throw UnsupportedError('TODO');
          break;
      }
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _setPaperType(BuildContext context) async {
    try {
      final answer = await showDialog<HMA300LPaperType>(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                    title: const Text('Set Paper Type'),
                    children: [
                      SimpleDialogOption(
                        child: const Text('Continuous'),
                        onPressed: () {
                          Navigator.pop(context, HMA300LPaperType.continuous);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('Label'),
                        onPressed: () {
                          Navigator.pop(context, HMA300LPaperType.label);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('2 Inch Black Mark'),
                        onPressed: () {
                          Navigator.pop(
                              context, HMA300LPaperType.blackMark2Inch);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('3 Inch Black Mark'),
                        onPressed: () {
                          Navigator.pop(
                              context, HMA300LPaperType.blackMark3Inch);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('4 Inch Black Mark'),
                        onPressed: () {
                          Navigator.pop(
                              context, HMA300LPaperType.blackMark4Inch);
                        },
                      ),
                    ]);
              }) ??
          HMA300LPaperType.continuous;
      switch (_printerModel) {
        case PrinterModel.HMA300:
          await (MyApp.printer as HMA300LPrinter).setPaperType(answer);
          break;
        case PrinterModel.N31:
          throw UnsupportedError('TODO');
          break;
      }
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _setBold(BuildContext context) async {
    try {
      final answer = await showDialog<int>(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                    title: const Text('Set Bold'),
                    children: List.generate(
                        6,
                        (index) => SimpleDialogOption(
                              child: Text(index.toString()),
                              onPressed: () {
                                Navigator.pop(context, index);
                              },
                            )));
              }) ??
          0;
      switch (_printerModel) {
        case PrinterModel.HMA300:
          await (MyApp.printer as HMA300LPrinter).setBold(answer);
          break;
        case PrinterModel.N31:
          throw UnsupportedError('TODO');
          break;
      }
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _getStatus(BuildContext context) async {
    try {
      final HMA300LPrinterStatus result;
      switch (_printerModel) {
        case PrinterModel.HMA300:
          result = await (MyApp.printer as HMA300LPrinter).getStatus();
          break;
        case PrinterModel.N31:
          throw UnsupportedError('TODO');
          break;
      }

      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(title: Text('Status = $result'));
          });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _setAlign(BuildContext context) async {
    try {
      final answer = await showDialog<HMA300LPrinterTextAlign>(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(title: const Text('Set Align'), children: [
                  SimpleDialogOption(
                    child: const Text('Left'),
                    onPressed: () {
                      Navigator.pop(context, HMA300LPrinterTextAlign.left);
                    },
                  ),
                  SimpleDialogOption(
                    child: const Text('Center'),
                    onPressed: () {
                      Navigator.pop(context, HMA300LPrinterTextAlign.center);
                    },
                  ),
                  SimpleDialogOption(
                    child: const Text('Right'),
                    onPressed: () {
                      Navigator.pop(context, HMA300LPrinterTextAlign.right);
                    },
                  ),
                ]);
              }) ??
          HMA300LPrinterTextAlign.left;
      switch (_printerModel) {
        case PrinterModel.HMA300:
          await (MyApp.printer as HMA300LPrinter).setAlign(answer);
          break;
        case PrinterModel.N31:
          throw UnsupportedError('TODO');
          break;
      }
    } catch (ex, st) {
      print('Exception: $ex\n$st');
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
                      ElevatedButton(
                          onPressed: _startSearch,
                          child: const Text('Start search')),
                      Text('Searching = $_searching'),
                      Text('Search Result = ${_searchResults.toString()}\n'),
                      ElevatedButton(
                          onPressed: _stopSearch,
                          child: const Text('Stop search')),
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
                              value: PrinterModel.HMA300,
                              child: Text('HM-A300L'),
                            ),
                            DropdownMenuItem(
                              value: PrinterModel.N31,
                              child: Text('N31'),
                            ),
                          ],
                          value: _printerModel,
                          onChanged: (value) {
                            setState(() {
                              _printerModel = value ?? PrinterModel.HMA300;
                            });
                          }),
                      ElevatedButton(
                          onPressed: _connect, child: const Text('Connect')),
                      Text('Connected = $_connected\n'),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () => _getStatus(context),
                            child: const Text('Get Status')),
                      ElevatedButton(
                          onPressed: () => _printTestPage(context),
                          child: const Text('Print Test Page')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () => _setPaperType(context),
                            child: const Text('Set Paper Type')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SetPrintAreaSize()));
                          },
                          child: const Text('Set Print Area Size')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SetPageWidth()));
                            },
                            child: const Text('Set Page Width')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Prefeed()));
                            },
                            child: const Text('Prefeed')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () => _setBold(context),
                            child: const Text('Set Bold')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SetTextSize()));
                            },
                            child: const Text('Set Text Size')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () => _setAlign(context),
                            child: const Text('Set Align')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddText()));
                          },
                          child: const Text('Add Text')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddBarcode()));
                            },
                            child: const Text('Add Barcode')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddQRCode()));
                            },
                            child: const Text('Add QRCode')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddRectangle()));
                            },
                            child: const Text('Add Rectangle')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddLine()));
                            },
                            child: const Text('Add Line')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddImage()));
                            },
                            child: const Text('Add Image')),
                      ElevatedButton(
                          onPressed: _print, child: const Text('Print')),
                      if (_printerModel == PrinterModel.HMA300)
                        ElevatedButton(
                            onPressed: _printTemplate,
                            child: const Text('Print Template')),
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
