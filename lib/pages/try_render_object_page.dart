import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:movie_list/data/constants.dart';
import 'package:movie_list/pages/reusable_widgets/custom_column.dart';
import 'package:movie_list/pages/reusable_widgets/custom_proxy.dart';
import 'package:movie_list/pages/reusable_widgets/custom_spacer.dart';
import '../main.dart';

class TryRenderObjectPage extends StatefulWidget {
  static const id = "TryRenderObjectPage";

  @override
  _TryRenderObjectPageState createState() => _TryRenderObjectPageState();
}

class _TryRenderObjectPageState extends State<TryRenderObjectPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..addListener(() {
            setState(() {});
          });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final ScreenUtil screenUtil = getIt<ScreenUtil>();
    return MediaQuery(
      data: mediaQuery.copyWith(
          textScaleFactor: initialTextFactor, boldText: initialBoldFactor),
      child: Scaffold(
        body: Container(
          color: Colors.amber.withOpacity(0.3),
          child: Stack(
            children: [
              CustomColumn(
                align: CustomColumnAlign.center,
                rotation: pi * _animationController.value,
                children: [
                  CustomSpacer(
                    flex: 3,
                    child: SizedBox(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, TryRenderObjectPage.id);
                    },
                    child: Text(
                      "Testing Title",
                      style: TextStyle(
                        fontSize: screenUtil.setWidth(30.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenUtil.setHeight(10.0),
                  ),
                  Text(
                    "Testing Body",
                    style: TextStyle(
                      fontSize: screenUtil.setWidth(20.0),
                    ),
                  ),
                  CustomSpacer(
                    flex: 4,
                    child: SizedBox(),
                  ),
                ],
              ),
              CustomProxy(
                child: Container(
                  color: Colors.red,
                  height: mediaQuery.size.height,
                  width: mediaQuery.size.width,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}