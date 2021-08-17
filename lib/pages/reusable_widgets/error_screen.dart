import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:movie_list/data/constants.dart';

import '../../main.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback reLoad;

  ErrorScreen(
      {this.errorMessage =
          "A problem occurred while trying to get information. Please check your internet connection and try again.",
      @required this.reLoad});

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = getIt<ScreenUtil>();
    final ThemeData theme = Theme.of(context);
    return Container(
      color: lightGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: screenUtil.setWidth(20.0)),
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: screenUtil.setWidth(18.0),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: screenUtil.setHeight(20.0),
          ),
          FlatButton(
            color: theme.primaryColor,
            child: Text(
              "Try again",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenUtil.setWidth(20.0),
              ),
            ),
            onPressed: reLoad,
          ),
        ],
      ),
    );
  }
}
