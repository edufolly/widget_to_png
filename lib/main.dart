import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:widget_to_png/widget_image_renderer.dart';

///
///
///
void main() {
  runApp(const MyApp());
}

///
///
///
class MyApp extends StatelessWidget {
  ///
  ///
  ///
  const MyApp({super.key});

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget to PNG',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

///
///
///
class MyHomePage extends StatefulWidget {
  ///
  ///
  ///
  const MyHomePage({super.key});

  ///
  ///
  ///
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

///
///
///
class _MyHomePageState extends State<MyHomePage> {
  final WidgetImageController<String> _controller =
      WidgetImageController<String>();

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget to PNG'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              children: [
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Render Area',
                  ),
                  child: WidgetImageRenderer<String>(
                    controller: _controller,

                    /// Render widget
                    builder: (BuildContext context, String? value, _) {
                      return Card(
                        color: Colors.deepOrange,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(value ?? ''),
                        ),
                      );
                    },

                    /// Callback with image bytes.
                    callback: (ByteData data) {
                      DateTime now = DateTime.now();

                      File file = File('test_${now.millisecond}.png');

                      file.writeAsBytesSync(data.buffer
                          .asUint8List(data.offsetInBytes, data.lengthInBytes));
                    },
                  ),
                ),

                /// Save Button
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: ElevatedButton(
                    onPressed: () => _controller
                        .process('Test: ${DateTime.now().toIso8601String()}'),
                    child: const Text('SAVE IMAGE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  ///
  ///
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
