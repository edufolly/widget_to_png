import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

///
///
///
class _InternalHolder<T> {
  final T? value;

  ///
  ///
  ///
  const _InternalHolder(this.value);
}

///
///
///
class WidgetImageController<T> extends ValueNotifier<_InternalHolder<T>> {
  bool _process = false;

  ///
  ///
  ///
  WidgetImageController({T? value}) : super(_InternalHolder(value));

  ///
  ///
  ///
  Future<void> process(T value) async {
    print('Process');
    _process = true;
    this.value = _InternalHolder(value);
  }
}

///
///
///
class WidgetImageRenderer<T> extends StatefulWidget {
  final WidgetImageController<T> controller;
  final Widget Function(BuildContext context, T? value, Widget? child) builder;
  final Widget? child;

  ///
  ///
  ///
  const WidgetImageRenderer({
    required this.controller,
    required this.builder,
    this.child,
    Key? key,
  }) : super(key: key);

  ///
  ///
  ///
  @override
  State<WidgetImageRenderer> createState() => _WidgetImageRendererState<T>();
}

///
///
///
class _WidgetImageRendererState<T> extends State<WidgetImageRenderer<T>> {
  final GlobalKey _globalKey = GlobalKey();
  late _InternalHolder<T> value;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    value = widget.controller.value;
    widget.controller.addListener(_valueChanged);
  }

  ///
  ///
  ///
  @override
  void didUpdateWidget(WidgetImageRenderer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_valueChanged);
      value = widget.controller.value;
      widget.controller.addListener(_valueChanged);
    }
  }

  ///
  ///
  ///
  @override
  void dispose() {
    widget.controller.removeListener(_valueChanged);
    super.dispose();
  }

  ///
  ///
  ///
  void _valueChanged() {
    setState(() {
      value = widget.controller.value;
    });
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    print('Build');
    WidgetsBinding.instance.endOfFrame.then((value) => _endOfFrame());
    return RepaintBoundary(
      key: _globalKey,
      child: widget.builder(context, value.value, widget.child),
    );
  }

  ///
  ///
  ///
  Future<void> _endOfFrame() async {
    print('End of Frame!');

    if (widget.controller._process) {
      print('Save');

      DateTime now = DateTime.now();

      BuildContext? context = _globalKey.currentContext;

      if (context != null) {
        RenderRepaintBoundary boundary =
            context.findRenderObject() as RenderRepaintBoundary;

        ui.Image image = await boundary.toImage(
          pixelRatio: MediaQuery.of(context).devicePixelRatio,
        );

        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          File file = File('test_${now.millisecond}.png');

          file.writeAsBytesSync(byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        }
      }

      widget.controller._process = false;
    }
  }
}
