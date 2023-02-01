import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/printer_searcher/HM_A300L_searcher.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  HMA300LSearcher _searcher = HMA300LSearcher();

  String _searchResultString = '';
  List<PrinterSearchResult> _searchResults = [];
  bool _searching = false;
  bool _connected = false;

  final connectIndexController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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
      _searcher.stopSearch();
      setState(() {
        _searching = false;
      });
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _connect() async {
    try {
      PrinterSearchResult? result = _searchResults[int.parse(connectIndexController.text)];
      if (result != null) {
        _searcher.connect(result);
        setState(() {
          _connected = true;
        });
      }
    } catch (ex, st) {
      print('Exception: $ex\n$st');
    }
  }

  Future<void> _disconnect() async {
    try {
      _searcher.disconnect();
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
        body: Center(
          child: Column(
            children: [
              Text('Searching = $_searching'),
              ElevatedButton(onPressed: _startSearch, child: const Text('Start search')),
              Text('Search Result = ${_searchResults.toString()}\n'),
              ElevatedButton(onPressed: _stopSearch, child: const Text('Stop search')),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Index of Search result to Connect Bluetooth to',
                ),
                keyboardType: TextInputType.number,
                controller: connectIndexController,
              ),
              ElevatedButton(onPressed: _connect, child: const Text('Connect')),
              Text('Connected = $_connected\n'),
              ElevatedButton(onPressed: _disconnect, child: const Text('Disconnect')),
            ],
          )
        ),
      ),
    );
  }
}
