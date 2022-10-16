# widget_to_png

Simple example:

```dart
WidgetImageRenderer<String>(
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
)
```