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
  final void Function(ByteData data) callback;
  final Widget? child;
  final double? pixelRatio;
  final ui.ImageByteFormat imageByteFormat;

  ///
  ///
  ///
  const WidgetImageRenderer({
    required this.controller,
    required this.builder,
    required this.callback,
    this.child,
    this.pixelRatio,
    this.imageByteFormat = ui.ImageByteFormat.png,
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

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: ValueListenableBuilder<_InternalHolder<T?>>(
        valueListenable: widget.controller,
        child: widget.child,
        builder: (
          BuildContext context,
          _InternalHolder<T?> value,
          Widget? child,
        ) {
          WidgetsBinding.instance.endOfFrame.then((value) => _endOfFrame());
          return widget.builder(context, value.value, child);
        },
      ),
    );
  }

  ///
  ///
  ///
  Future<void> _endOfFrame() async {
    if (widget.controller._process) {
      BuildContext? context = _globalKey.currentContext;

      if (context != null) {
        RenderRepaintBoundary boundary =
            context.findRenderObject() as RenderRepaintBoundary;

        ui.Image image = await boundary.toImage(
          pixelRatio:
              widget.pixelRatio ?? MediaQuery.of(context).devicePixelRatio,
        );

        ByteData? byteData =
            await image.toByteData(format: widget.imageByteFormat);

        if (byteData != null) {
          widget.callback(byteData);
        }
      }

      widget.controller._process = false;
    }
  }
}
