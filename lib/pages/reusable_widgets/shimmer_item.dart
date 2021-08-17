import 'package:flutter/material.dart';
import 'package:movie_list/data/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/screen_util.dart';
import '../../main.dart';

class ShimmerItem extends StatelessWidget {
  Widget _shimmerText(
      {@required MediaQueryData mediaQuery,
        @required ScreenUtil screenUtil,
        double widthRatio = 3.0,
        double textHeight = 16.0}) {
    return Shimmer.fromColors(
      baseColor: lightGrey,
      highlightColor: lightGrey.withOpacity(0.3),
      child: Container(
        color: lightGrey,
        width: mediaQuery.size.width / widthRatio,
        height: screenUtil.setWidth(textHeight),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = getIt<ScreenUtil>();
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: imgRatio,
          child: Shimmer.fromColors(
            baseColor: lightGrey,
            highlightColor: lightGrey.withOpacity(0.3),
            child: Container(
              color: lightGrey,
            ),
          ),
        ),
        SizedBox(
          height: screenUtil.setWidth(10.0),
        ),
        _shimmerText(
            mediaQuery: mediaQuery,
            screenUtil: screenUtil,
            textHeight: 20.0),
        SizedBox(
          height: screenUtil.setWidth(8.0),
        ),
        _shimmerText(
            mediaQuery: mediaQuery,
            screenUtil: screenUtil,
            widthRatio: 5.0),
        SizedBox(
          height: screenUtil.setWidth(8.0),
        ),
        _shimmerText(
            mediaQuery: mediaQuery,
            screenUtil: screenUtil,
            widthRatio: 3.5),
      ],
    );
  }
}
