import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomProxy extends SingleChildRenderObjectWidget {
  final Widget child;

  CustomProxy({Key key, this.child}) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomProxy();
  }
}

class RenderCustomProxy extends RenderProxyBox {
  //RenderProxyBox extends RenderBox and it adapts everything from RenderBox
  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.saveLayer(offset & size, Paint()..blendMode = BlendMode.difference);
    context.paintChild(child, offset);
    canvas.restore();
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) => false;
}
