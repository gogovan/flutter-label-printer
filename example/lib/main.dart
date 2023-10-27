import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_printer.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_printer.dart';
import 'dart:async';

import 'package:flutter_label_printer/printer_searcher/bluetooth_printer_searcher.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/printer_template/hanin_cpcl_printer_template.dart';
import 'package:flutter_label_printer/templating/printer_template/hanin_tspl_printer_template.dart';
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

void main() {
  runApp(const MyApp());
}

enum PrinterModel { cpcl, tspl }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static TemplatablePrinterInterface? printer;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BluetoothPrinterSearcher _searcher = BluetoothPrinterSearcher();

  List<PrinterSearchResult> _searchResults = [];
  bool _searching = false;
  bool _connected = false;

  PrinterModel _printerModel = PrinterModel.cpcl;

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
        case PrinterModel.cpcl:
          MyApp.printer = HaninCPCLPrinterTemplate(result);
          break;
        case PrinterModel.tspl:
          MyApp.printer = HaninTSPLPrinterTemplate(result);
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
    await MyApp.printer?.print();
  }

  Future<void> _printTemplate() async {
    try {
      final yml = await rootBundle.loadString('assets/template.yaml');
      final template = Template.fromYaml(yml);

      await TemplatePrinter(MyApp.printer!, template,
          replaceStrings: {'world': 'Earth'}).printTemplate();
    } catch (ex, st) {
      print('Exception: $ex\n$st');
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
                              value: PrinterModel.cpcl,
                              child: Text('Hanin CPCL (e.g. HM-A300L)'),
                            ),
                            DropdownMenuItem(
                              value: PrinterModel.tspl,
                              child: Text('Hanin TSPL (e.g. N31)'),
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
                          onPressed: _print, child: const Text('Print')),
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
