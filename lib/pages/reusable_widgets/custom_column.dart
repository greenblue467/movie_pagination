import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomColumn extends MultiChildRenderObjectWidget {
  final List<Widget> children;
  final CustomColumnAlign align;
  final double rotation;

  CustomColumn(
      {Key key,
      this.children,
      this.align = CustomColumnAlign.start,
      this.rotation = 0.0})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomColumn(align: align, rotation: rotation);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderCustomColumn renderObject) {
    renderObject
      ..align = align
      ..rotation = rotation;
  }
}

enum CustomColumnAlign { start, center }

class CustomColumnParentData extends ContainerBoxParentData<RenderBox> {
  int flex;
}

class RenderCustomColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CustomColumnParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CustomColumnParentData> {
  RenderCustomColumn(
      {@required CustomColumnAlign align, @required double rotation})
      : _align = align,
        _rotation = rotation;
  CustomColumnAlign _align;
  double _rotation;

  CustomColumnAlign get align => _align;

  double get rotation => _rotation;

  set align(CustomColumnAlign value) {
    if (_align == value) {
      return;
    }
    _align = value;
    markNeedsLayout();
  }

  set rotation(double value) {
    if (_rotation == value) {
      return;
    }
    _rotation = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! CustomColumnParentData)
      child.parentData = CustomColumnParentData();
  }

  @override
  void performLayout() {
    double height = 0.0;
    double width = 0.0;
    RenderBox child = firstChild;
    int totalFlex = 0;
    //layout non-flex child's constraint
    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;
      final flex = childParentData.flex ?? 0;
      if (flex > 0) {
        totalFlex += flex;
      }
      child.layout(BoxConstraints(maxWidth: constraints.maxWidth),
          parentUsesSize: true);
      height += child.size.height;
      width = max(width, child.size.width);
      child = childParentData.nextSibling;
    }

    //layout flex child's height and constraint
    double remainingHeight = constraints.maxHeight - height;
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;
      final flex = childParentData.flex ?? 0;
      if (flex > 0) {
        child.layout(
            BoxConstraints(
                maxWidth: constraints.maxWidth,
                maxHeight: remainingHeight * (flex / totalFlex),
                minHeight: remainingHeight * (flex / totalFlex)),
            parentUsesSize: true);
        height += child.size.height;
        width = max(width, child.size.width);
      }
      child = childParentData.nextSibling;
    }

    //after laying out every child's constraint, set the painting position of every child
    child = firstChild;
    Offset childOffset = Offset(0.0, 0.0);
    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;
      childParentData.offset = Offset(
          align == CustomColumnAlign.center
              ? (constraints.biggest.width - child.size.width) / 2
              : 0.0,
          childOffset.dy);
      childOffset += Offset(0.0, child.size.height);
      child = childParentData.nextSibling;
    }
    // size = Size(width, height);
    size = Size(constraints.maxWidth, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    //can do some painting in here
    final canvas = context.canvas;

    //rotate before paint or after paint leads to different results
    //rotate may lead to failure of hitTest?
    //canvas.rotate(pi / 16);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.amber;

    double wid = size.width;

    final path = Path();
    path.moveTo(wid / 2, wid * 5 / 6);
    path.lineTo(wid / 6, wid * 11 / 6);
    path.lineTo(wid, wid * 7 / 6);
    path.lineTo(0.0, wid * 7 / 6);
    path.lineTo(wid * 5 / 6, wid * 11 / 6);
    path.lineTo(wid / 2, wid * 5 / 6);

    canvas.drawPath(path, paint);

    //save and restore create a new layer of canvas
    canvas.save();
    //move canvas starting point to the target position
    canvas.translate(size.width / 2, size.height / 4);
    //canvas rotates along the starting point
    canvas.rotate(rotation);
    final paint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.deepOrangeAccent.withOpacity(0.3);
    canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 100.0, height: 100.0),
        paint2);
    //canvas.drawRect(offset & size, paint2);for painting the whole canvas
    canvas.restore();
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
