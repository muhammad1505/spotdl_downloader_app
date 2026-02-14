import 'package:flutter/material.dart';
import 'package:chaquopy/chaquopy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotDL Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _pythonResponse = '...';

  @override
  void initState() {
    super.initState();
    _callPython();
  }

  Future<void> _callPython() async {
    final result = await Chaquopy.executeCode('import spotdl_service\nprint(spotdl_service.hello_python())');
    setState(() {
      _pythonResponse = result['textOutput'] ?? 'Error';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotDL Downloader'),
      ),
      body: Center(
        child: Text(
          'Response from Python: $_pythonResponse',
        ),
      ),
    );
  }
}
