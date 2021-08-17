import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:movie_list/data/constants.dart';
import 'package:movie_list/pages/reusable_widgets/my_painter.dart';
import '../../main.dart';

class StarShape extends StatelessWidget {
  final StarState state;

  StarShape({@required this.state});

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = getIt<ScreenUtil>();
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return SizedBox(
        width: mediaQuery.size.width / 10,
        height: mediaQuery.size.width / 10,
        child: CustomPaint(
          painter: MyPainter(state),
        ));
  }
}
