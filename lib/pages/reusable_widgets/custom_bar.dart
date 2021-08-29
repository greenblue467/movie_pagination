import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomBar extends LeafRenderObjectWidget {
  final double thumbSize;
  final Color thumbColor;
  final Color dotColor;

  CustomBar(
      {Key key,
      this.thumbSize = 10.0,
      this.thumbColor = Colors.deepPurpleAccent,
      this.dotColor = Colors.amber})
      : assert(thumbSize >= 3.0 && thumbSize <= 15.0),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomBar(
        thumbSize: thumbSize, thumbColor: thumbColor, dotColor: dotColor);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderCustomBar renderObject) {
    renderObject
      ..thumbSize = thumbSize
      ..thumbColor = thumbColor
      ..dotColor = dotColor;
  }
}

class RenderCustomBar extends RenderBox {
  RenderCustomBar(
      {@required double thumbSize,
      @required Color thumbColor,
      @required Color dotColor})
      : _thumbSize = thumbSize,
        _thumbColor = thumbColor,
        _dotColor = dotColor {
    _dragGestureRecognizer = HorizontalDragGestureRecognizer()
      ..onStart = (DragStartDetails details) {
        _updateValue(details.localPosition);
      }
      ..onUpdate = (DragUpdateDetails details) {
        _updateValue(details.localPosition);
      };
  }

  double _thumbSize;
  Color _thumbColor;
  Color _dotColor;

  double get thumbSize => _thumbSize;

  Color get thumbColor => _thumbColor;

  Color get dotColor => _dotColor;

  set thumbSize(double value) {
    assert(value >= 1.0);
    if (_thumbSize == value) {
      return;
    }
    _thumbSize = value;
    markNeedsLayout();
  }

  set thumbColor(Color color) {
    if (_thumbColor == color) {
      return;
    }
    _thumbColor = color;
    markNeedsPaint();
  }

  set dotColor(Color color) {
    if (_dotColor == color) {
      return;
    }
    _dotColor = color;
    markNeedsPaint();
  }

  double _currentValue = 0.5;
  HorizontalDragGestureRecognizer _dragGestureRecognizer;

  @override
  void performLayout() {
    double childWidth = constraints.maxWidth;
    double childHeight = thumbSize < 10.0 ? 10.0 : thumbSize;
    size = Size(childWidth, childHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    //move canvas to starting point otherwise it always starts from top-left corner
    canvas.translate(offset.dx, offset.dy);
    double strokeWid = thumbSize / 2 > 4.0 ? 4.0 : thumbSize / 2;
    final paintBase = Paint()
      ..color = dotColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWid;

    final paintThumb = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    final paintSelected = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWid;

    //paint baseline
    canvas.drawLine(Offset(size.width * _currentValue, 0.0),
        Offset(size.width, 0.0), paintBase);

    //paint each point
    final calcSpace = size.width / 10;
    for (var i = 0; i <= 10; i++) {
      Offset pointUp =
          Offset(calcSpace * i, -size.height * (i % 5 == 0 ? 1 : 0.5));
      Offset pointDown =
          Offset(calcSpace * i, size.height * (i % 5 == 0 ? 1 : 0.5));
      canvas.drawLine(
          pointUp,
          pointDown,
          calcSpace * i < size.width * _currentValue
              ? paintSelected
              : paintBase);
    }

    //paint selected part
    canvas.drawLine(
        Offset.zero, Offset(size.width * _currentValue, 0.0), paintSelected);

    //paint thumb
    canvas.drawCircle(
        Offset(size.width * _currentValue, 0), thumbSize * 1.5, paintThumb);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _dragGestureRecognizer.addPointer(event);
    }
  }

  _updateValue(Offset location) {
    double dx = location.dx.clamp(0.0, size.width);
    _currentValue = double.parse((dx / size.width).toStringAsFixed(1));
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void detach() {
    _dragGestureRecognizer.dispose();
    super.detach();
  }
}
