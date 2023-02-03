import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_label_printer/printer/HM_A300L_printer.dart';
import 'package:flutter_label_printer/printer_searcher/HM_A300L_searcher.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer_example/add_text.dart';
import 'package:flutter_label_printer_example/set_print_area_size.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static HMA300LPrinter? printer;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final HMA300LSearcher _searcher = HMA300LSearcher();

  List<PrinterSearchResult> _searchResults = [];
  bool _searching = false;
  bool _connected = false;

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
      MyApp.printer = HMA300LPrinter(result);
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
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Test page printed.")));
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _print() async {
    try {
      await MyApp.printer?.print();
      setState(() {
        _connected = false;
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
                      ElevatedButton(
                          onPressed: _connect, child: const Text('Connect')),
                      Text('Connected = $_connected\n'),
                      ElevatedButton(
                          onPressed: () => _printTestPage(context),
                          child: const Text('Print Test Page')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SetPrintAreaSize()));
                          }, child: const Text('Set Print Area Size')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddText()));
                          }, child: const Text('Add Text')),
                      ElevatedButton(
                          onPressed: _print,
                          child: const Text('Print')),
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
