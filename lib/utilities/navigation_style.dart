import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SlideNavigation extends PageRouteBuilder {
  final Widget page;
  final double beginX;
  final double beginY;
  final double endX;
  final double endY;

  SlideNavigation({@required this.page,
    this.beginX = 1.0,
    this.beginY = 0.0,
    this.endX = 0.0,
    this.endY = 0.0})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (context, animation, __, child) {
      bool isPopping = false;
      double endPosition = 0.0;
      return SlideTransition(
        transformHitTests: false,
        position: Tween<Offset>(
            begin: Offset(beginX, beginY), end: Offset(endX, endY))
            .animate(CurvedAnimation(
            parent: animation,
            curve: Curves.bounceOut,
            reverseCurve: Curves.easeInOutCirc)),
        child: GestureDetector(
            onHorizontalDragStart: (details) {
              if (details.globalPosition.dx < 40.0) {
                isPopping = true;
              }
            },
            onHorizontalDragUpdate: (details) {
              if (isPopping) {
                endPosition = details.globalPosition.dx;
              }
            },
            onHorizontalDragEnd: (_) {
              if (endPosition > MediaQuery
                  .of(context)
                  .size
                  .width / 2) {
                Navigator.pop(context);
              } else {
                isPopping = false;
              }
            },
            child: child),
      );
    },
    transitionDuration: Duration(milliseconds: 800),
    opaque: false,
    barrierColor: Colors.black54,
    //not working when there is a scaffold or container with color
    //barrierDismissible: true
  );
}

class SlideBouncingNavigation<T> extends PageRoute<T> {
  final Widget page;
  final double beginX;
  final double beginY;
  final double endX;
  final double endY;

  SlideBouncingNavigation({@required this.page,
    this.beginX = 1.0,
    this.beginY = 0.0,
    this.endX = 0.0,
    this.endY = 0.0});

  @override
  Color get barrierColor => Colors.black54;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget pageBuilder(_, __, ___) => page;
    return pageBuilder(context, animation, secondaryAnimation);
  }

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 800);

  @override
  Duration get reverseTransitionDuration => Duration(milliseconds: 300);

  bool _isPopGestureEnabled<T>(PageRoute<T> route) {
    if (route.isFirst) return false;
    if (route.willHandlePopInternally) return false;
    if (route.hasScopedWillPopCallback) return false;
    if (route.fullscreenDialog) return false;
    if (route.animation.status != AnimationStatus.completed) return false;
    if (route.secondaryAnimation.status != AnimationStatus.dismissed)
      return false;
    if (_isPopGestureInProgress(route)) return false;

    return true;
  }

  bool _isPopGestureInProgress(PageRoute<dynamic> route) {
    return route.navigator.userGestureInProgress;
  }

  _SlideWithBackGestureController<T> _startPopGesture<T>(PageRoute<T> route) {
    return _SlideWithBackGestureController<T>(
      navigator: route.navigator,
      controller: route.controller,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return
      SlideTransition(
        transformHitTests: false,
        position:
        Tween<Offset>(begin: Offset.zero, end: Offset(-1.0 / 5.0, 0.0))
            .animate(CurvedAnimation(
          parent: secondaryAnimation,//activates when there is another page on top of this
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.easeInToLinear,
        )),
        child: SlideTransition(
          position: Tween<Offset>(
              begin: Offset(beginX, beginY), end: Offset(endX, endY))
              .animate(CurvedAnimation(
              parent: animation,
              curve: Curves.bounceOut,
              reverseCurve: Curves.linear)),
          child: _SlideWithBackGesture<T>(
            enabledCallback: () =>
            beginX == 1.0 && beginY == 0.0 && endX == 0.0 && endY == 0.0
                ? _isPopGestureEnabled<T>(this)
                : false,
            onStartPopGesture: () => _startPopGesture<T>(this),
            child: child,
          ),
        ),
      );
  }


}

class _SlideWithBackGesture<T> extends StatefulWidget {
  final Widget child;
  final ValueGetter<bool> enabledCallback;
  final ValueGetter<_SlideWithBackGestureController<T>> onStartPopGesture;

  _SlideWithBackGesture({Key key,
    @required this.child,
    @required this.enabledCallback,
    @required this.onStartPopGesture})
      : super(key: key);

  @override
  _SlideWithBackGestureState<T> createState() =>
      _SlideWithBackGestureState<T>();
}

class _SlideWithBackGestureState<T> extends State<_SlideWithBackGesture<T>> {
  _SlideWithBackGestureController<T> _slideController;
  HorizontalDragGestureRecognizer _recognizer;

  void _handleDragStart(DragStartDetails details) {
    _slideController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _slideController.dragUpdate(
        _convertToLogical(details.primaryDelta / context.size.width));
  }

  void _handleDragEnd(DragEndDetails details) {
    _slideController.dragEnd(_convertToLogical(
        details.velocity.pixelsPerSecond.dx / context.size.width));
    _slideController = null;
  }

  void _handleDragCancel() {
    _slideController?.dragEnd(0.0);
    _slideController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) _recognizer.addPointer(event);
  }

  double _convertToLogical(double value) {
    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        return -value;
      case TextDirection.ltr:
        return value;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dragAreaWidth = Directionality.of(context) == TextDirection.ltr
        ? MediaQuery
        .of(context)
        .padding
        .left
        : MediaQuery
        .of(context)
        .padding
        .right;
    dragAreaWidth = max(dragAreaWidth, 20.0);
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        PositionedDirectional(
          start: 0.0,
          width: dragAreaWidth,
          top: 0.0,
          bottom: 0.0,
          child: Listener(
            onPointerDown: _handlePointerDown,
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}

class _SlideWithBackGestureController<T> {
  final AnimationController controller;
  final NavigatorState navigator;

  _SlideWithBackGestureController({
    @required this.navigator,
    @required this.controller,
  }) {
    navigator.didStartUserGesture();
  }

  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  void dragEnd(double velocity) {
    const Curve animationCurve = Curves.linear;
    bool animateForward;

    if (velocity.abs() >= 1.0)
      animateForward = velocity <= 0;
    else
      animateForward = controller.value > 0.5;

    if (animateForward) {
      final int droppedPageForwardAnimationTime = min(
        lerpDouble(1000, 0, controller.value).floor(),
        800,
      );
      controller.animateTo(1.0,
          duration: Duration(milliseconds: droppedPageForwardAnimationTime),
          curve: animationCurve);
    } else {
      navigator.pop();

      if (controller.isAnimating) {
        final int droppedPageBackAnimationTime =
        lerpDouble(300, 300, controller.value).floor();
        controller.animateBack(0.0,
            duration: Duration(milliseconds: droppedPageBackAnimationTime),
            curve: animationCurve);
      }
    }

    if (controller.isAnimating) {
      AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}
