import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/printer_searcher/HM_A300L_searcher.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

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

  String _searchResult = '';
  bool _searching = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startSearch() async {
    try {
      setState(() {
        _searching = true;
      });

      _searcher.search().listen((event) {
        setState(() {
          _searchResult = event.toString();
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
              Text('Search Result = $_searchResult\n'),
              ElevatedButton(onPressed: _stopSearch, child: const Text('Stop search')),
            ],
          )
        ),
      ),
    );
  }
}
