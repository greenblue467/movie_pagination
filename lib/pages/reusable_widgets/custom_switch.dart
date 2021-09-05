import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double _minimumRadius = 20.0;
const Color _defaultActiveColor = Colors.amber;
const Color _defaultInactiveColor = Color(0xffd0d0d0);
const Color _defaultThumbColor = Colors.white;
const Color _inactiveGradient2 = Color(0xfffe356a);
const Color _inactiveGradient1 = Color(0xffff9bb3);
const Color _activeGradient2 = Color(0xff86c9e1);
const Color _activeGradient1 = Color(0xff3d97f3);
const double _strokeWidth = 3.0;
const double _defaultRatio = 1.6;
const double _thumbRatio = 2.3;

class CustomSwitch extends StatefulWidget {
  final double thumbSize;
  final Color thumbColor;
  final Color activeColor;
  final Color inactiveColor;
  final bool value;
  final bool paintGradient;
  final bool withIcon;
  final void Function(bool val) onChange;

  CustomSwitch(
      {Key key,
      this.thumbSize = _minimumRadius,
      this.thumbColor = _defaultThumbColor,
      this.activeColor = _defaultActiveColor,
      this.inactiveColor = _defaultInactiveColor,
      @required this.value,
      this.paintGradient = true,
      this.withIcon = true,
      this.onChange})
      : assert(value != null),
        super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool _val;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
  }

  @override
  void didUpdateWidget(covariant CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (this.widget.value != oldWidget.value) {
      setState(() {
        _val = this.widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          child: CustomSwitchRender(
            thumbSize: widget.thumbSize,
            thumbColor: widget.thumbColor,
            activeColor: widget.activeColor,
            inactiveColor: widget.inactiveColor,
            value: widget.value,
            paintGradient: widget.paintGradient,
            withIcon: widget.withIcon,
            onChange: widget.onChange,
            state: this,
          ),
        ),
        if (widget.onChange == null)
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  color: _defaultInactiveColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100.0)),
            ),
          )
      ],
    );
  }
}

class CustomSwitchRender extends LeafRenderObjectWidget {
  final double thumbSize;
  final Color thumbColor;
  final Color activeColor;
  final Color inactiveColor;
  final bool value;
  final bool paintGradient;
  final bool withIcon;
  final void Function(bool val) onChange;
  final _CustomSwitchState state;

  CustomSwitchRender(
      {Key key,
      this.thumbSize = _minimumRadius,
      this.thumbColor = _defaultThumbColor,
      this.activeColor = _defaultActiveColor,
      this.inactiveColor = _defaultInactiveColor,
      @required this.value,
      this.paintGradient = false,
      this.withIcon = true,
      this.onChange,
      this.state})
      : assert(value != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomSwitch(
        thumbSize: thumbSize,
        thumbColor: thumbColor,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        value: value,
        paintGradient: paintGradient,
        withIcon: withIcon,
        onChange: onChange,
        state: state);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderCustomSwitch renderObject) {
    if (renderObject._originalState == null &&
            renderObject._currentValue >= 0.5 &&
            renderObject.state._val ||
        renderObject._originalState == null &&
            renderObject._currentValue < 0.5 &&
            renderObject.state._val == false) {
      return;
    }

    if (renderObject._originalState != null &&
        renderObject._originalState == renderObject.state._val) {
      return;
    }

    //tap behavior
    if (renderObject._currentValue < 0.5) {
      renderObject._slideToRight();
    } else {
      renderObject._slideToLeft();
    }

    renderObject
      ..thumbSize = thumbSize
      ..thumbColor = thumbColor
      ..activeColor = activeColor
      ..inactiveColor = inactiveColor
      ..paintGradient = paintGradient
      ..withIcon = withIcon
      ..onChange = onChange
      ..state = state;
  }
}

class RenderCustomSwitch extends RenderBox {
  RenderCustomSwitch(
      {@required double thumbSize,
      @required Color thumbColor,
      @required Color activeColor,
      @required Color inactiveColor,
      @required bool value,
      @required bool paintGradient,
      @required bool withIcon,
      @required void Function(bool val) onChange,
      @required _CustomSwitchState state})
      : _thumbSize = thumbSize,
        _thumbColor = thumbColor,
        _activeColor = activeColor,
        _inactiveColor = inactiveColor,
        _paintGradient = paintGradient,
        _withIcon = withIcon,
        _onChange = onChange,
        _state = state {
    _dragGestureRecognizer = HorizontalDragGestureRecognizer()
      ..onStart = (DragStartDetails details) {
        if (onChange == null) {
          return;
        }
        _updateValue(details.localPosition);
      }
      ..onUpdate = (DragUpdateDetails details) {
        if (onChange == null) {
          return;
        }
        _updateValue(details.localPosition);
      }
      ..onEnd = (_) {
        if (onChange == null) {
          return;
        }
        _setFinalValue();
      };

    _currentValue = value ? 1.0 : 0.0;
    _currentColor = value ? activeColor : inactiveColor;
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        if (onChange == null) {
          return;
        }
        _tapUpdate();
      };
  }

  double _thumbSize;
  Color _thumbColor;
  Color _activeColor;
  Color _inactiveColor;

  bool _paintGradient;
  bool _withIcon;
  _CustomSwitchState _state;
  void Function(bool val) _onChange;

  double get thumbSize => _thumbSize;

  Color get thumbColor => _thumbColor;

  Color get activeColor => _activeColor;

  Color get inactiveColor => _inactiveColor;

  bool get paintGradient => _paintGradient;

  bool get withIcon => _withIcon;

  _CustomSwitchState get state => _state;

  void Function(bool val) get onChange => _onChange;

  set thumbSize(double value) {
    assert(value >= _minimumRadius);
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

  set activeColor(Color color) {
    if (_activeColor == color) {
      return;
    }
    _activeColor = color;
    markNeedsPaint();
  }

  set inactiveColor(Color color) {
    if (_inactiveColor == color) {
      return;
    }
    _inactiveColor = color;
    markNeedsPaint();
  }

  set paintGradient(bool val) {
    if (_paintGradient == val) {
      return;
    }
    _paintGradient = val;
    markNeedsLayout();
  }

  set withIcon(bool val) {
    if (_withIcon == val) {
      return;
    }
    _withIcon = val;
    markNeedsLayout();
  }

  set onChange(void Function(bool val) onChange) {
    if (_onChange == onChange) {
      return;
    }
    _onChange = onChange;
    markNeedsLayout();
  }

  set state(_CustomSwitchState state) {
    if (_state == state) {
      return;
    }
    _state = state;
    markNeedsLayout();
  }

  HorizontalDragGestureRecognizer _dragGestureRecognizer;
  TapGestureRecognizer _tapGestureRecognizer;
  double _currentValue;
  Color _currentColor;
  ui.Gradient _currentGradient;
  double _enlargedValue = 0.0;
  double _originalVal;
  bool _originalState;

  @override
  void performLayout() {
    double childHeight = constraints.maxHeight;
    double childWidth = constraints.maxWidth;

    if (childWidth == ui.Size.infinite.width &&
        childHeight == ui.Size.infinite.height) {
      childHeight = thumbSize;
      childWidth = childHeight * _defaultRatio;
    } else {
      if (childWidth == ui.Size.infinite.width) {
        assert(childHeight >= thumbSize);
        childWidth = childHeight * _defaultRatio;
      } else {
        if (childHeight == ui.Size.infinite.height) {
          assert(childWidth >= thumbSize * _defaultRatio);
          childHeight = thumbSize;
        } else {
          assert(childHeight >= thumbSize);
          assert(childWidth >= childHeight * _defaultRatio);
        }
      }
    }

    size = Size(childWidth, childHeight);
    _setGradient(state._val ? _activeGradient1 : _inactiveGradient1,
        state._val ? _activeGradient2 : _inactiveGradient2);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.translate(offset.dx, offset.dy);
    final paint = Paint()
      ..color = _currentColor
      ..style = PaintingStyle.fill
      ..shader = _currentGradient;

    final paintIcon = Paint()
      ..color = _currentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth * size.height / 60.0
      ..strokeCap = StrokeCap.round
      ..shader = _currentGradient;

    if (_currentGradient != null) {
      paint.color = Colors.white;
      paintIcon.color = Colors.white;
    }
    final paintThumb = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;
    final paintShadow = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

    ///paint background
    final rect = Rect.fromLTRB(
        size.height / 2, 0, size.width - size.height / 2, size.height);

    final rectR =
        Rect.fromLTRB(size.width - size.height, 0, size.width, size.height);
    final rectL = Rect.fromLTRB(0, 0, size.height, size.height);
    final startAngle = -pi / 2;
    final sweepAngle = pi;
    final Path pathBase = Path()
      ..addArc(rectR, startAngle, sweepAngle) //right arc
      ..addArc(rectL, -startAngle, sweepAngle) //left arc
      ..addRect(rect); //middle part
    canvas.drawPath(pathBase, paint);

    canvas.save();

    ///paint foreground
    double dxThumb = _getHorizontalPosition(size.width * _currentValue);
    double dxShadow = _getShadowHorizontal(size.width * _currentValue);
    double dxEnlarged = _getEnlargedThumb(size.width * _currentValue);

    //rotating effect
    canvas.translate(dxThumb, size.height / 2);
    canvas.rotate(pi * _currentValue * 2);

    //since center point is translated, the original center must subtract the translated value
    //shadow
    canvas.drawCircle(
        Offset(dxShadow - dxThumb, size.height / 2 + 3.0 - size.height / 2),
        size.height / _thumbRatio,
        paintShadow);
    //thumb
    canvas.drawCircle(Offset(0.0, 0.0), size.height / _thumbRatio, paintThumb);

    canvas.restore();

    //enlarged thumb
    canvas.drawOval(
        Rect.fromCircle(
            center: Offset(dxEnlarged, size.height / 2),
            radius: size.height / _thumbRatio),
        paintThumb);

    if (withIcon) {
      canvas.translate(dxThumb, size.height / 2);
      double rotateVal = _currentValue;

      if (rotateVal == ((size.width - size.height * (1 / 2)) / size.width)) {
        rotateVal = 1.0;
      }
      if (rotateVal == (size.height / (2 * size.width))) {
        rotateVal = 0.0;
      }
      canvas.rotate(pi * rotateVal * 2 * (size.width ~/ size.height));

      ///paint icon
      //female
      double dxFemale = dxThumb + dxThumb * (1 / 2.3) * (1 / 16) - dxThumb;
      double dyFemale = size.height / 2 -
          size.height * (1 / 2.3) * (1 / 16) -
          size.height / 2;
      double radius = size.height / (_thumbRatio * 2);
      double dxFemaleLine = dxFemale - radius * (1 / sqrt(2));
      double dyFemaleLine = dyFemale + radius * (1 / sqrt(2));
      double dxFemaleLine2 = dxFemale - radius * (1 / sqrt(2)) * (7 / 4);
      double dyFemaleLine2 = dyFemale + radius * (1 / sqrt(2)) * (7 / 4);

      final pathFemale = Path()
        ..addOval(
            Rect.fromCircle(center: Offset(dxFemale, dyFemale), radius: radius))
        ..moveTo(dxFemaleLine, dyFemaleLine)
        ..lineTo(dxFemaleLine2, dyFemaleLine2)
        ..moveTo(dxFemaleLine2, dyFemaleLine)
        ..lineTo(dxFemaleLine, dyFemaleLine2);

      //male
      double dxMale = dxThumb - size.height * (1 / 2.3) * (1 / 16) - dxThumb;
      double dyMale = size.height / 2 +
          size.height * (1 / 2.3) * (1 / 16) -
          size.height / 2;
      double dxMaleLine = dxMale + radius * (1 / sqrt(2));
      double dyMaleLine = dyMale - radius * (1 / sqrt(2));
      double dxMaleLine2 = dxMale + radius * (1 / sqrt(2)) * (7 / 4);
      double dyMaleLine2 = dyMale - radius * (1 / sqrt(2)) * (7 / 4);
      double strokeWidthCorrection =
          _strokeWidth * (size.height / 60.0) * (1 / 3);

      final pathMale = Path()
        ..addOval(
            Rect.fromCircle(center: Offset(dxMale, dyMale), radius: radius))
        ..moveTo(dxMaleLine, dyMaleLine)
        ..lineTo(dxMaleLine2, dyMaleLine2)
        ..moveTo(dxMaleLine2 + strokeWidthCorrection, dyMaleLine2)
        ..lineTo(dxMaleLine, dyMaleLine2)
        ..moveTo(dxMaleLine2 + strokeWidthCorrection, dyMaleLine2)
        ..lineTo(dxMaleLine2, dyMaleLine);

      canvas.drawPath(_currentValue > 0.5 ? pathMale : pathFemale, paintIcon);
    }
    // //shadow
    // canvas.drawCircle(Offset(dxShadow, size.height / 2 + 3.0),
    //     size.height / _thumbRatio, paintShadow);
    // //thumb
    // canvas.drawCircle(Offset(dxThumb, size.height / 2),
    //     size.height / _thumbRatio, paintThumb);
    // //enlarged thumb
    // canvas.drawOval(
    //     Rect.fromCircle(
    //         center: Offset(dxEnlarged, size.height / 2),
    //         radius: size.height / _thumbRatio),
    //     paintThumb);
    //
    // if (withIcon) {
    //   ///paint icon
    //   //female
    //   double dxFemale = dxThumb + dxThumb * (1 / 2.3) * (1 / 16);
    //   double dyFemale = size.height / 2 - size.height * (1 / 2.3) * (1 / 16);
    //   double radius = size.height / (_thumbRatio * 2);
    //   double dxFemaleLine = dxFemale - radius * (1 / sqrt(2));
    //   double dyFemaleLine = dyFemale + radius * (1 / sqrt(2));
    //   double dxFemaleLine2 = dxFemale - radius * (1 / sqrt(2)) * (7 / 4);
    //   double dyFemaleLine2 = dyFemale + radius * (1 / sqrt(2)) * (7 / 4);
    //
    //   final pathFemale = Path()
    //     ..addOval(
    //         Rect.fromCircle(center: Offset(dxFemale, dyFemale), radius: radius))
    //     ..moveTo(dxFemaleLine, dyFemaleLine)
    //     ..lineTo(dxFemaleLine2, dyFemaleLine2)
    //     ..moveTo(dxFemaleLine2, dyFemaleLine)
    //     ..lineTo(dxFemaleLine, dyFemaleLine2);
    //   // canvas.drawPath(pathFemale, paintIcon);
    //
    //   //male
    //   double dxMale = dxThumb - size.height * (1 / 2.3) * (1 / 16);
    //   double dyMale = size.height / 2 + size.height * (1 / 2.3) * (1 / 16);
    //   double dxMaleLine = dxMale + radius * (1 / sqrt(2));
    //   double dyMaleLine = dyMale - radius * (1 / sqrt(2));
    //   double dxMaleLine2 = dxMale + radius * (1 / sqrt(2)) * (7 / 4);
    //   double dyMaleLine2 = dyMale - radius * (1 / sqrt(2)) * (7 / 4);
    //   double strokeWidthCorrection =
    //       _strokeWidth * (size.height / 60) * (1 / 3);
    //
    //   final pathMale = Path()
    //     ..addOval(
    //         Rect.fromCircle(center: Offset(dxMale, dyMale), radius: radius))
    //     ..moveTo(dxMaleLine, dyMaleLine)
    //     ..lineTo(dxMaleLine2, dyMaleLine2)
    //     ..moveTo(dxMaleLine2 + strokeWidthCorrection, dyMaleLine2)
    //     ..lineTo(dxMaleLine, dyMaleLine2)
    //     ..moveTo(dxMaleLine2 + strokeWidthCorrection, dyMaleLine2)
    //     ..lineTo(dxMaleLine2, dyMaleLine);
    //
    //   canvas.drawPath(_currentValue > 0.5 ? pathMale : pathFemale, paintIcon);
    //}
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _dragGestureRecognizer.addPointer(event);
      _tapGestureRecognizer.addPointer(event);
    }
  }

  double _getHorizontalPosition(double dx) {
    //make sure thumb is always inside the track
    return dx.clamp(size.height / 2, size.width - size.height / 2);
  }

  double _getShadowHorizontal(double dx) {
    double shift = 3.5 * (_currentValue < 0.5 ? 1 : -1);
    return dx.clamp(
        size.height / 2 + shift, size.width - size.height / 2 + shift);
  }

  double _getEnlargedThumb(double dx) {
    double shift = _enlargedValue * (_currentValue < 0.5 ? 1 : -1);
    return dx.clamp(
        size.height / 2 + shift, size.width - size.height / 2 + shift);
  }

  void _handleTap() {
    onChange(!state._val);
  }

  Future<void> _updateValue(Offset location) async {
    if (_originalVal == null) {
      _originalVal = _currentValue;
    }
    _originalState = null;
    double dx = _getHorizontalPosition(location.dx);
    _currentValue = dx / size.width;
    _currentColor = Color.lerp(inactiveColor, activeColor, _currentValue);
    _enlargedValue = 3.5;
    if (_originalVal != null) {
      _setGradient(
        _originalVal < 0.5
            ? Color.lerp(_inactiveGradient2, _activeGradient1, _currentValue)
            : Color.lerp(_inactiveGradient2, _activeGradient1, _currentValue),
        _originalVal < 0.5
            ? Color.lerp(_activeGradient2, _inactiveGradient1, _currentValue)
            : Color.lerp(_inactiveGradient1, _activeGradient2, _currentValue),
      );
    }

    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  void _tapUpdate() {
    _originalVal = null;
    _originalState = state._val;
    _handleTap();
  }

  Future<void> _setFinalValue() async {
    if ((_originalVal != null && _originalVal < 0.5 && _currentValue >= 0.5) ||
        (_originalVal != null && _originalVal >= 0.5 && _currentValue < 0.5)) {
      _handleTap();
    }

    bool val = state._val;
    await Future.delayed(Duration(milliseconds: 50));
    if (val && _originalVal >= 0.5) {
      if (_currentValue < 0.5 && state._val) {
        _slideToRight();
        _enlargedValue = 0.0;
        _originalVal = null;
        markNeedsPaint();
        markNeedsSemanticsUpdate();
        return;
      }
    } else {
      if (_currentValue >= 0.5 && state._val == false) {
        _slideToLeft();
        _enlargedValue = 0.0;
        _originalVal = null;
        markNeedsPaint();
        markNeedsSemanticsUpdate();
        return;
      }
    }

    if (_currentValue < 0.5) {
      _slideToLeft();
    } else {
      _slideToRight();
    }
    _enlargedValue = 0.0;
    _originalVal = null;

    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  void _currentValueAnimation(bool isAdd) {
    while (isAdd ? _currentValue < 1.0 : _currentValue > 0.0) {
      if (isAdd ? _currentValue + 0.1 > 1.0 : _currentValue - 0.1 < 0.0) {
        _currentValue = isAdd ? 1.0 : 0.0;
      } else {
        _currentValue = _currentValue + 0.1 * (isAdd ? 1 : -1);
      }
    }
  }

  void _setGradient(Color color1, Color color2) {
    _currentGradient = paintGradient
        ? ui.Gradient.linear(
            Offset.zero, Offset(size.width, size.height), [color1, color2])
        : null;
  }

  void _slideToRight() {
    _currentValueAnimation(true);
    _currentColor = activeColor;
    _setGradient(_activeGradient1, _activeGradient2);
  }

  void _slideToLeft() {
    _currentValueAnimation(false);
    _currentColor = inactiveColor;
    _setGradient(_inactiveGradient1, _inactiveGradient2);
  }

  @override
  void detach() {
    _dragGestureRecognizer.dispose();
    _tapGestureRecognizer.dispose();
    super.detach();
  }
}

// class CustomSwitchRender extends LeafRenderObjectWidget {
//   final double thumbSize;
//   final Color thumbColor;
//   final Color activeColor;
//   final Color inactiveColor;
//   final bool value;
//   final bool paintGradient;
//   final bool withIcon;
//   final void Function(bool val) onChange;
//   final _CustomSwitchState state;
//
//   CustomSwitchRender(
//       {Key key,
//       this.thumbSize = _minimumRadius,
//       this.thumbColor = _defaultThumbColor,
//       this.activeColor = _defaultActiveColor,
//       this.inactiveColor = _defaultInactiveColor,
//       @required this.value,
//       this.paintGradient = false,
//       this.withIcon = true,
//       this.onChange,
//       this.state})
//       : assert(value != null),
//         super(key: key);
//
//   @override
//   RenderObject createRenderObject(BuildContext context) {
//     return RenderCustomSwitch(
//         thumbSize: thumbSize,
//         thumbColor: thumbColor,
//         activeColor: activeColor,
//         inactiveColor: inactiveColor,
//         value: value,
//         paintGradient: paintGradient,
//         withIcon: withIcon,
//         onChange: onChange,
//         state: state);
//   }
//
//   @override
//   void updateRenderObject(
//       BuildContext context, covariant RenderCustomSwitch renderObject) {
//
//     if (renderObject._originalBool == null &&
//             renderObject._currentValue >= 0.5 &&
//             renderObject.state._val ||
//         renderObject._originalBool == null &&
//             renderObject._currentValue < 0.5 &&
//             renderObject.state._val == false) {
//       return;
//     }
//
//     if (renderObject._originalBool != null &&
//         renderObject._originalBool == renderObject.state._val) {
//       return;
//     }
//     //tap behavior
//     if (renderObject._currentValue < 0.5) {
//       renderObject._currentValueAnimation(true);
//       renderObject._currentColor = activeColor;
//       renderObject._setGradient(_activeGradient1, _activeGradient2);
//     } else {
//       renderObject._currentValueAnimation(false);
//       renderObject._currentColor = inactiveColor;
//       renderObject._setGradient(_inactiveGradient1, _inactiveGradient2);
//     }
//
//     // if ((renderObject._currentValue > 0.5 && renderObject.state._val) ||
//     //     (renderObject._currentValue < 0.5 &&
//     //         renderObject.state._val == false)) {
//     //   return;
//     // }
//     //
//     // if (renderObject._originalVal != null &&
//     //     renderObject._originalVal < 0.5 && renderObject._currentValue > 0.5) {
//     //   renderObject._currentValueAnimation(false);
//     //   renderObject._currentColor = inactiveColor;
//     //   renderObject._setGradient(_inactiveGradient1, _inactiveGradient2);
//     //   return;
//     // }
//     // if (renderObject._originalVal != null &&
//     //     renderObject._originalVal > 0.5 && renderObject._currentValue < 0.5) {
//     //   renderObject._currentValueAnimation(true);
//     //   renderObject._currentColor = activeColor;
//     //   renderObject._setGradient(_activeGradient1, _activeGradient2);
//     //
//     //   return;
//     // }
//     //
//     // if (renderObject._originalVal != null &&
//     //     renderObject._originalVal < 0.5 &&
//     //     renderObject._currentValue < 0.5) {
//     //   return;
//     // }
//
//     renderObject
//       ..thumbSize = thumbSize
//       ..thumbColor = thumbColor
//       ..activeColor = activeColor
//       ..inactiveColor = inactiveColor
//       ..paintGradient = paintGradient
//       ..withIcon = withIcon
//       ..onChange = onChange
//       ..state = state;
//   }
// }
//
// class RenderCustomSwitch extends RenderBox {
//   RenderCustomSwitch(
//       {@required double thumbSize,
//       @required Color thumbColor,
//       @required Color activeColor,
//       @required Color inactiveColor,
//       @required bool value,
//       @required bool paintGradient,
//       @required bool withIcon,
//       @required void Function(bool val) onChange,
//       @required _CustomSwitchState state})
//       : _thumbSize = thumbSize,
//         _thumbColor = thumbColor,
//         _activeColor = activeColor,
//         _inactiveColor = inactiveColor,
//         _paintGradient = paintGradient,
//         _withIcon = withIcon,
//         _onChange = onChange,
//         _state = state {
//     _dragGestureRecognizer = HorizontalDragGestureRecognizer()
//       ..onStart = (DragStartDetails details) {
//         if (onChange == null) {
//           return;
//         }
//         _updateValue(details.localPosition);
//       }
//       ..onUpdate = (DragUpdateDetails details) {
//         if (onChange == null) {
//           return;
//         }
//         _updateValue(details.localPosition);
//       }
//       ..onEnd = (_) {
//         if (onChange == null) {
//           return;
//         }
//         _setFinalValue();
//       };
//
//     _currentValue = value ? 1.0 : 0.0;
//     _currentColor = value ? activeColor : inactiveColor;
//     _tap = TapGestureRecognizer()
//       ..onTap = () {
//         if (onChange == null) {
//           return;
//         }
//         _tapUpdate();
//       };
//   }
//
//   double _thumbSize;
//   Color _thumbColor;
//   Color _activeColor;
//   Color _inactiveColor;
//
//   bool _paintGradient;
//   bool _withIcon;
//   _CustomSwitchState _state;
//   void Function(bool val) _onChange;
//
//   double get thumbSize => _thumbSize;
//
//   Color get thumbColor => _thumbColor;
//
//   Color get activeColor => _activeColor;
//
//   Color get inactiveColor => _inactiveColor;
//
//   bool get paintGradient => _paintGradient;
//
//   bool get withIcon => _withIcon;
//
//   _CustomSwitchState get state => _state;
//
//   void Function(bool val) get onChange => _onChange;
//
//   set thumbSize(double value) {
//     assert(value >= _minimumRadius);
//     if (_thumbSize == value) {
//       return;
//     }
//     _thumbSize = value;
//     markNeedsLayout();
//   }
//
//   set thumbColor(Color color) {
//     if (_thumbColor == color) {
//       return;
//     }
//     _thumbColor = color;
//     markNeedsPaint();
//   }
//
//   set activeColor(Color color) {
//     if (_activeColor == color) {
//       return;
//     }
//     _activeColor = color;
//     markNeedsPaint();
//   }
//
//   set inactiveColor(Color color) {
//     if (_inactiveColor == color) {
//       return;
//     }
//     _inactiveColor = color;
//     markNeedsPaint();
//   }
//
//   set paintGradient(bool val) {
//     if (_paintGradient == val) {
//       return;
//     }
//     _paintGradient = val;
//     markNeedsLayout();
//   }
//
//   set withIcon(bool val) {
//     if (_withIcon == val) {
//       return;
//     }
//     _withIcon = val;
//     markNeedsLayout();
//   }
//
//   set onChange(void Function(bool val) onChange) {
//     if (_onChange == onChange) {
//       return;
//     }
//     _onChange = onChange;
//     markNeedsLayout();
//   }
//
//   set state(_CustomSwitchState state) {
//     if (_state == state) {
//       return;
//     }
//     _state = state;
//     markNeedsLayout();
//   }
//
//   HorizontalDragGestureRecognizer _dragGestureRecognizer;
//   TapGestureRecognizer _tap;
//   double _currentValue;
//   Color _currentColor;
//   ui.Gradient _currentGradient;
//   double _enlargedValue = 0.0;
//   double _originalVal;
//   bool _originalBool;
//
//   @override
//   void performLayout() {
//     double childHeight = constraints.maxHeight;
//     double childWidth = constraints.maxWidth;
//
//     if (childWidth == ui.Size.infinite.width &&
//         childHeight == ui.Size.infinite.height) {
//       childHeight = thumbSize;
//       childWidth = childHeight * _defaultRatio;
//     } else {
//       if (childWidth == ui.Size.infinite.width) {
//         assert(childHeight >= thumbSize);
//         childWidth = childHeight * _defaultRatio;
//       } else {
//         if (childHeight == ui.Size.infinite.height) {
//           assert(childWidth >= thumbSize * _defaultRatio);
//           childHeight = thumbSize;
//         } else {
//           assert(childHeight >= thumbSize);
//           assert(childWidth >= childHeight * _defaultRatio);
//         }
//       }
//     }
//
//     size = Size(childWidth, childHeight);
//     _setGradient(state._val ? _activeGradient1 : _inactiveGradient1,
//         state._val ? _activeGradient2 : _inactiveGradient2);
//   }
//
//   @override
//   void paint(PaintingContext context, Offset offset) {
//     final canvas = context.canvas;
//     canvas.translate(offset.dx, offset.dy);
//     final paint = Paint()
//       ..color = _currentColor
//       ..style = PaintingStyle.fill
//       ..shader = _currentGradient;
//
//     final paintIcon = Paint()
//       ..color = _currentColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = _strokeWidth * size.height / 60
//       ..strokeCap = StrokeCap.round
//       ..shader = _currentGradient;
//
//     final paintThumb = Paint()
//       ..color = thumbColor
//       ..style = PaintingStyle.fill;
//     final paintShadow = Paint()
//       ..color = Colors.black12
//       ..style = PaintingStyle.fill
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
//
//     ///paint background
//     final rect = Rect.fromLTRB(size.height / 2 - 1.0, 0,
//         size.width - size.height / 2 + 1.0, size.height);
//
//     final rectR =
//         Rect.fromLTRB(size.width - size.height, 0, size.width, size.height);
//     final rectL = Rect.fromLTRB(0, 0, size.height, size.height);
//     final startAngle = -pi / 2;
//     final sweepAngle = pi;
//     //right arc
//     canvas.drawArc(rectR, startAngle, sweepAngle, false, paint);
//     //left arc
//     canvas.drawArc(rectL, -startAngle, sweepAngle, false, paint);
//     //middle part
//     canvas.drawRect(rect, paint);
//
//     ///paint foreground
//     double dxThumb = _getHorizontalPosition(size.width * _currentValue);
//     double dxShadow = _getShadowHorizontal(size.width * _currentValue);
//     double dxEnlarged = _getEnlargedThumb(size.width * _currentValue);
//
//     //shadow
//     canvas.drawCircle(Offset(dxShadow, size.height / 2 + 3.0),
//         size.height / _thumbRatio, paintShadow);
//     //thumb
//     canvas.drawCircle(Offset(dxThumb, size.height / 2),
//         size.height / _thumbRatio, paintThumb);
//     //enlarged thumb
//     canvas.drawOval(
//         Rect.fromCircle(
//             center: Offset(dxEnlarged, size.height / 2),
//             radius: size.height / _thumbRatio),
//         paintThumb);
//
//     if (withIcon) {
//       ///paint icon
//       //female
//       double dxFemale = dxThumb + dxThumb * (1 / 2.3) * (1 / 16);
//       double dyFemale = size.height / 2 - size.height * (1 / 2.3) * (1 / 16);
//       double radius = size.height / (_thumbRatio * 2);
//       double dxFemaleLine = dxFemale - radius * (1 / sqrt(2));
//       double dyFemaleLine = dyFemale + radius * (1 / sqrt(2));
//       double dxFemaleLine2 = dxFemale - radius * (1 / sqrt(2)) * (7 / 4);
//       double dyFemaleLine2 = dyFemale + radius * (1 / sqrt(2)) * (7 / 4);
//
//       final pathFemale = Path()
//         ..addOval(
//             Rect.fromCircle(center: Offset(dxFemale, dyFemale), radius: radius))
//         ..moveTo(dxFemaleLine, dyFemaleLine)
//         ..lineTo(dxFemaleLine2, dyFemaleLine2)
//         ..moveTo(dxFemaleLine2, dyFemaleLine)
//         ..lineTo(dxFemaleLine, dyFemaleLine2);
//       // canvas.drawPath(pathFemale, paintIcon);
//
//       //male
//       double dxMale = dxThumb - size.height * (1 / 2.3) * (1 / 16);
//       double dyMale = size.height / 2 + size.height * (1 / 2.3) * (1 / 16);
//       double dxMaleLine = dxMale + radius * (1 / sqrt(2));
//       double dyMaleLine = dyMale - radius * (1 / sqrt(2));
//       double dxMaleLine2 = dxMale + radius * (1 / sqrt(2)) * (7 / 4);
//       double dyMaleLine2 = dyMale - radius * (1 / sqrt(2)) * (7 / 4);
//       double strokeWidthCorrection =
//           _strokeWidth * (size.height / 60) * (1 / 3);
//
//       final pathMale = Path()
//         ..addOval(
//             Rect.fromCircle(center: Offset(dxMale, dyMale), radius: radius))
//         ..moveTo(dxMaleLine, dyMaleLine)
//         ..lineTo(dxMaleLine2, dyMaleLine2)
//         ..moveTo(dxMaleLine2 + strokeWidthCorrection, dyMaleLine2)
//         ..lineTo(dxMaleLine, dyMaleLine2)
//         ..moveTo(dxMaleLine2 + strokeWidthCorrection, dyMaleLine2)
//         ..lineTo(dxMaleLine2, dyMaleLine);
//
//       canvas.drawPath(_currentValue > 0.5 ? pathMale : pathFemale, paintIcon);
//     }
//   }
//
//   @override
//   bool hitTestSelf(Offset position) => true;
//
//   @override
//   void handleEvent(PointerEvent event, HitTestEntry entry) {
//     assert(debugHandleEvent(event, entry));
//     if (event is PointerDownEvent) {
//       _dragGestureRecognizer.addPointer(event);
//       _tap.addPointer(event);
//     }
//   }
//
//   double _getHorizontalPosition(double dx) {
//     //make sure thumb is always inside the track
//     return dx.clamp(size.height / 2, size.width - size.height / 2);
//   }
//
//   double _getShadowHorizontal(double dx) {
//     double shift = 3.5 * (_currentValue < 0.5 ? 1 : -1);
//     return dx.clamp(
//         size.height / 2 + shift, size.width - size.height / 2 + shift);
//   }
//
//   double _getEnlargedThumb(double dx) {
//     double shift = _enlargedValue * (_currentValue < 0.5 ? 1 : -1);
//     return dx.clamp(
//         size.height / 2 + shift, size.width - size.height / 2 + shift);
//   }
//
//   void _handleTap() {
//     onChange(!state._val);
//   }
//
//   Future<void> _updateValue(Offset location) async {
//     ///can drag but will be set to the initial if there is no change
//     if (_originalVal == null) {
//       _originalVal = _currentValue;
//     }
//     _originalBool = null;
//     double dx = _getHorizontalPosition(location.dx);
//     _currentValue = dx / size.width;
//     _currentColor = Color.lerp(inactiveColor, activeColor, _currentValue);
//     _enlargedValue = 3.5;
//     _setGradient(
//       Color.lerp(_activeGradient2, _activeGradient1, _currentValue),
//       Color.lerp(_inactiveGradient2, _inactiveGradient1, _currentValue),
//     );
//
//     markNeedsPaint();
//     markNeedsSemanticsUpdate();
//   }
//
//   void _tapUpdate() {
//     _originalVal = null;
//     _originalBool = state._val;
//     _handleTap();
//   }
//
//   void _setFinalValue() {
//
//     if ((_originalVal != null && _originalVal < 0.5 && _currentValue >= 0.5) ||
//         (_originalVal != null && _originalVal >= 0.5 && _currentValue < 0.5)) {
//       _handleTap();
//     }
//
//     if (_currentValue < 0.5) {
//       _currentValueAnimation(false);
//       _currentColor = inactiveColor;
//       _setGradient(_inactiveGradient1, _inactiveGradient2);
//     } else {
//       _currentValueAnimation(true);
//       _currentColor = activeColor;
//       _setGradient(_activeGradient1, _activeGradient2);
//     }
//     _enlargedValue = 0.0;
//     _originalVal = null;
//     markNeedsPaint();
//     markNeedsSemanticsUpdate();
//   }
//
//   void _currentValueAnimation(bool isAdd) {
//     while (isAdd ? _currentValue < 1.0 : _currentValue > 0.0) {
//       if (isAdd ? _currentValue + 0.1 > 1.0 : _currentValue - 0.1 < 0.0) {
//         _currentValue = isAdd ? 1.0 : 0.0;
//       } else {
//         _currentValue = _currentValue + 0.1 * (isAdd ? 1 : -1);
//       }
//     }
//     markNeedsSemanticsUpdate();
//   }
//
//   void _setGradient(Color color1, Color color2) {
//     _currentGradient = paintGradient
//         ? ui.Gradient.linear(
//             Offset.zero, Offset(size.width, size.height), [color1, color2])
//         : null;
//     markNeedsPaint();
//   }
//
//   @override
//   void detach() {
//     _dragGestureRecognizer.dispose();
//     _tap.dispose();
//     super.detach();
//   }
// }

// class CustomSwitch extends LeafRenderObjectWidget {
//   final double thumbSize;
//   final Color thumbColor;
//   final Color activeColor;
//   final Color inactiveColor;
//   final bool value;
//   final bool paintGradient;
//   final bool withIcon;
//   final void Function(bool val) onChange;
//
//   CustomSwitch(
//       {Key key,
//       this.thumbSize = _minimumRadius,
//       this.thumbColor = _defaultThumbColor,
//       this.activeColor = _defaultActiveColor,
//       this.inactiveColor = _defaultInactiveColor,
//       @required this.value,
//       this.paintGradient = false,
//       this.withIcon = true,
//       this.onChange})
//       : assert(value != null),
//         super(key: key);
//
//   @override
//   RenderObject createRenderObject(BuildContext context) {
//     return RenderCustomSwitch(
//         thumbSize: thumbSize,
//         thumbColor: thumbColor,
//         activeColor: activeColor,
//         inactiveColor: inactiveColor,
//         value: value,
//         paintGradient: paintGradient,
//         withIcon: withIcon,
//         onChange: onChange);
//   }
//
//   @override
//   void updateRenderObject(
//       BuildContext context, covariant RenderCustomSwitch renderObject) {
//     print(value);
//     renderObject
//       ..thumbSize = thumbSize
//       ..thumbColor = thumbColor
//       ..activeColor = activeColor
//       ..inactiveColor = inactiveColor
//       ..value = value
//       ..paintGradient = paintGradient
//       ..withIcon = withIcon
//       ..onChange = onChange;
//   }
// }
//
// class RenderCustomSwitch extends RenderBox {
//   RenderCustomSwitch(
//       {@required double thumbSize,
//       @required Color thumbColor,
//       @required Color activeColor,
//       @required Color inactiveColor,
//       @required bool value,
//       @required bool paintGradient,
//       @required bool withIcon,
//       @required void Function(bool val) onChange})
//       : _thumbSize = thumbSize,
//         _thumbColor = thumbColor,
//         _activeColor = activeColor,
//         _inactiveColor = inactiveColor,
//         _value = value,
//         _paintGradient = paintGradient,
//         _withIcon = withIcon,
//         _onChange = onChange {
//     _dragGestureRecognizer = HorizontalDragGestureRecognizer()
//       ..onStart = (DragStartDetails details) {
//         if (onChange == null) {
//           return;
//         }
//         _updateValue(details.localPosition);
//       }
//       ..onUpdate = (DragUpdateDetails details) {
//         if (onChange == null) {
//           return;
//         }
//         _updateValue(details.localPosition);
//       }
//       ..onEnd = (_) {
//         if (onChange == null) {
//           return;
//         }
//         _setFinalValue();
//       };
//
//     _currentValue = value ? 1.0 : 0.0;
//     _currentColor = value ? activeColor : inactiveColor;
//     _tap = TapGestureRecognizer()
//       ..onTap = () {
//         if (onChange == null) {
//           return;
//         }
//         _tapUpdate();
//       };
//   }
//
//   double _thumbSize;
//   Color _thumbColor;
//   Color _activeColor;
//   Color _inactiveColor;
//   bool _value;
//   bool _paintGradient;
//   bool _withIcon;
//   void Function(bool val) _onChange;
//
//   double get thumbSize => _thumbSize;
//
//   Color get thumbColor => _thumbColor;
//
//   Color get activeColor => _activeColor;
//
//   Color get inactiveColor => _inactiveColor;
//
//   bool get value => _value;
//
//   bool get paintGradient => _paintGradient;
//
//   bool get withIcon => _withIcon;
//
//   void Function(bool val) get onChange => _onChange;
//
//   set thumbSize(double value) {
//     assert(value >= _minimumRadius);
//     if (_thumbSize == value) {
//       return;
//     }
//     _thumbSize = value;
//     markNeedsLayout();
//   }
//
//   set thumbColor(Color color) {
//     if (_thumbColor == color) {
//       return;
//     }
//     _thumbColor = color;
//     markNeedsPaint();
//   }
//
//   set activeColor(Color color) {
//     if (_activeColor == color) {
//       return;
//     }
//     _activeColor = color;
//     markNeedsPaint();
//   }
//
//   set inactiveColor(Color color) {
//     if (_inactiveColor == color) {
//       return;
//     }
//     _inactiveColor = color;
//     markNeedsPaint();
//   }
//
//   set value(bool val) {
//     if (_value == val) {
//       return;
//     }
//     _value = val;
//
//     markNeedsLayout();
//   }
//
//   set paintGradient(bool val) {
//     if (_paintGradient == val) {
//       return;
//     }
//     _paintGradient = val;
//     markNeedsLayout();
//   }
//
//   set withIcon(bool val) {
//     if (_withIcon == val) {
//       return;
//     }
//     _withIcon = val;
//     markNeedsLayout();
//   }
//
//   set onChange(void Function(bool val) onChange) {
//     if (_onChange == onChange) {
//       return;
//     }
//     _onChange = onChange;
//     markNeedsLayout();
//   }
//
//   HorizontalDragGestureRecognizer _dragGestureRecognizer;
//   TapGestureRecognizer _tap;
//   double _currentValue;
//   Color _currentColor;
//   ui.Gradient _currentGradient;
//   double _enlargedValue = 0.0;
//
//   @override
//   void performLayout() {
//     double childHeight = constraints.maxHeight;
//     double childWidth = constraints.maxWidth;
//
//     if (childWidth == ui.Size.infinite.width &&
//         childHeight == ui.Size.infinite.height) {
//       childHeight = thumbSize;
//       childWidth = childHeight * _defaultRatio;
//     } else {
//       if (childWidth == ui.Size.infinite.width) {
//         assert(childHeight >= thumbSize);
//         childWidth = childHeight * _defaultRatio;
//       } else {
//         if (childHeight == ui.Size.infinite.height) {
//           assert(childWidth >= thumbSize * _defaultRatio);
//           childHeight = thumbSize;
//         } else {
//           assert(childHeight >= thumbSize);
//           assert(childWidth >= childHeight * _defaultRatio);
//         }
//       }
//     }
//
//     size = Size(childWidth, childHeight);
//     _setGradient(value ? _activeGradient1 : _inactiveGradient1,
//         value ? _activeGradient2 : _inactiveGradient2);
//   }
//
//   @override
//   void paint(PaintingContext context, Offset offset) {
//     final canvas = context.canvas;
//     canvas.translate(offset.dx, offset.dy);
//
//     final paint = Paint()
//       ..color = _currentColor
//       ..style = PaintingStyle.fill
//       ..shader = _currentGradient;
//
//     final paintIcon = Paint()
//       ..color = _currentColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = _strokeWidth * size.height / 60
//       ..strokeCap = StrokeCap.round
//       ..shader = _currentGradient;
//
//     final paintThumb = Paint()
//       ..color = thumbColor
//       ..style = PaintingStyle.fill;
//     final paintShadow = Paint()
//       ..color = Colors.black12
//       ..style = PaintingStyle.fill
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
//
//     ///paint background
//     final rect = Rect.fromLTRB(size.height / 2 - 1.0, 0,
//         size.width - size.height / 2 + 1.0, size.height);
//
//     final rectR =
//         Rect.fromLTRB(size.width - size.height, 0, size.width, size.height);
//     final rectL = Rect.fromLTRB(0, 0, size.height, size.height);
//     final startAngle = -pi / 2;
//     final sweepAngle = pi;
//     //right arc
//     canvas.drawArc(rectR, startAngle, sweepAngle, false, paint);
//     //left arc
//     canvas.drawArc(rectL, -startAngle, sweepAngle, false, paint);
//     //middle part
//     canvas.drawRect(rect, paint);
//
//     ///paint foreground
//     double dxThumb = _getHorizontalPosition(size.width * _currentValue);
//     double dxShadow = _getShadowHorizontal(size.width * _currentValue);
//     double dxEnlarged = _getEnlargedThumb(size.width * _currentValue);
//
//     //shadow
//     canvas.drawCircle(Offset(dxShadow, size.height / 2 + 3.0),
//         size.height / _thumbRatio, paintShadow);
//     //thumb
//     canvas.drawCircle(Offset(dxThumb, size.height / 2),
//         size.height / _thumbRatio, paintThumb);
//     //enlarged thumb
//     canvas.drawOval(
//         Rect.fromCircle(
//             center: Offset(dxEnlarged, size.height / 2),
//             radius: size.height / _thumbRatio),
//         paintThumb);
//
//     if (withIcon) {
//       ///paint icon
//       //female
//       double dxFemale = dxThumb + dxThumb * (1 / 2.3) * (1 / 16);
//       double dyFemale = size.height / 2 - size.height * (1 / 2.3) * (1 / 16);
//       double radius = size.height / (_thumbRatio * 2);
//       double dxFemaleLine = dxFemale - radius * (1 / sqrt(2));
//       double dyFemaleLine = dyFemale + radius * (1 / sqrt(2));
//       double dxFemaleLine2 = dxFemale - radius * (1 / sqrt(2)) * (7 / 4);
//       double dyFemaleLine2 = dyFemale + radius * (1 / sqrt(2)) * (7 / 4);
//
//       final pathFemale = Path()
//         ..addOval(
//             Rect.fromCircle(center: Offset(dxFemale, dyFemale), radius: radius))
//         ..moveTo(dxFemaleLine, dyFemaleLine)
//         ..lineTo(dxFemaleLine2, dyFemaleLine2)
//         ..moveTo(dxFemaleLine2, dyFemaleLine)
//         ..lineTo(dxFemaleLine, dyFemaleLine2);
//       // canvas.drawPath(pathFemale, paintIcon);
//
//       //male
//       double dxMale = dxThumb - size.height * (1 / 2.3) * (1 / 16);
//       double dyMale = size.height / 2 + size.height * (1 / 2.3) * (1 / 16);
//       double dxMaleLine = dxMale + radius * (1 / sqrt(2));
//       double dyMaleLine = dyMale - radius * (1 / sqrt(2));
//       double dxMaleLine2 = dxMale + radius * (1 / sqrt(2)) * (7 / 4);
//       double dyMaleLine2 = dyMale - radius * (1 / sqrt(2)) * (7 / 4);
//       double strokeWidthCorrection =
//           _strokeWidth * (size.height / 60) * (1 / 3);
//
//       final pathMale = Path()
//         ..addOval(
//             Rect.fromCircle(center: Offset(dxMale, dyMale), radius: radius))
//         ..moveTo(dxMaleLine, dyMaleLine)
//         ..lineTo(dxMaleLine2, dyMaleLine2)
//         ..moveTo(dxMaleLine2 + strokeWidthCorrection, dyMaleLine2)
//         ..lineTo(dxMaleLine, dyMaleLine2)
//         ..moveTo(dxMaleLine2 + strokeWidthCorrection, dyMaleLine2)
//         ..lineTo(dxMaleLine2, dyMaleLine);
//
//       canvas.drawPath(value ? pathMale : pathFemale, paintIcon);
//     }
//   }
//
//   @override
//   bool hitTestSelf(Offset position) => true;
//
//   @override
//   void handleEvent(PointerEvent event, HitTestEntry entry) {
//     assert(debugHandleEvent(event, entry));
//     if (event is PointerDownEvent) {
//       _dragGestureRecognizer.addPointer(event);
//
//       _tap.addPointer(event);
//     }
//   }
//
//   double _getHorizontalPosition(double dx) {
//     //make sure thumb is always inside the track
//     return dx.clamp(size.height / 2, size.width - size.height / 2);
//   }
//
//   double _getShadowHorizontal(double dx) {
//     double shift = 3.5 * (_currentValue < 0.5 ? 1 : -1);
//     return dx.clamp(
//         size.height / 2 + shift, size.width - size.height / 2 + shift);
//   }
//
//   double _getEnlargedThumb(double dx) {
//     double shift = _enlargedValue * (_currentValue < 0.5 ? 1 : -1);
//     return dx.clamp(
//         size.height / 2 + shift, size.width - size.height / 2 + shift);
//   }
//
//   void _handleTap() {
//     onChange(!value);
//   }
//
//   void _updateValue(Offset location) {
//
//     double dx = _getHorizontalPosition(location.dx);
//     _currentValue = dx / size.width;
//     _currentColor = Color.lerp(inactiveColor, activeColor, _currentValue);
//     _enlargedValue = 3.5;
//     _setGradient(
//       Color.lerp(_activeGradient2, _activeGradient1, _currentValue),
//       Color.lerp(_inactiveGradient2, _inactiveGradient1, _currentValue),
//     );
//     if (_currentValue < 0.5) {
//       _value = false;
//     } else {
//       _value = true;
//     }
//     markNeedsPaint();
//     markNeedsSemanticsUpdate();
//   }
//
//   void _tapUpdate() {
//     _handleTap();
//
//     if (_currentValue < 0.5) {
//       _currentValueAnimation(true);
//       _currentColor = activeColor;
//       _setGradient(_activeGradient1, _activeGradient2);
//       _value = true;
//     } else {
//       _currentValueAnimation(false);
//       _currentColor = inactiveColor;
//       _setGradient(_inactiveGradient1, _inactiveGradient2);
//       _value = false;
//     }
//     markNeedsPaint();
//     markNeedsSemanticsUpdate();
//   }
//
//   void _setFinalValue() {
//     _handleTap();
//     if (_currentValue < 0.5) {
//       _currentValueAnimation(false);
//       _currentColor = inactiveColor;
//       _setGradient(_inactiveGradient1, _inactiveGradient2);
//       _value = false;
//     } else {
//       _currentValueAnimation(true);
//       _currentColor = activeColor;
//       _setGradient(_activeGradient1, _activeGradient2);
//       _value = true;
//     }
//     _enlargedValue = 0.0;
//     markNeedsPaint();
//     markNeedsSemanticsUpdate();
//   }
//
//   void _currentValueAnimation(bool isAdd) {
//     while (isAdd ? _currentValue < 1.0 : _currentValue > 0.0) {
//       if (isAdd ? _currentValue + 0.1 > 1.0 : _currentValue - 0.1 < 0.0) {
//         _currentValue = isAdd ? 1.0 : 0.0;
//       } else {
//         _currentValue = _currentValue + 0.1 * (isAdd ? 1 : -1);
//       }
//     }
//     markNeedsPaint();
//     markNeedsSemanticsUpdate();
//   }
//
//   void _setGradient(Color color1, Color color2) {
//     _currentGradient = paintGradient
//         ? ui.Gradient.linear(
//             Offset.zero, Offset(size.width, size.height), [color1, color2])
//         : null;
//     markNeedsPaint();
//     markNeedsSemanticsUpdate();
//   }
//
//   @override
//   void detach() {
//     _dragGestureRecognizer.dispose();
//     _tap.dispose();
//     super.detach();
//   }
// }
