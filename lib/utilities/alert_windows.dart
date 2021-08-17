import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_list/main.dart';
import 'package:movie_list/utilities/set_default_values.dart';
import '../data/constants.dart';

class AlertWindows {
  static Future<void> alertWithOneBtn(
      BuildContext context, String titleMessage, String bodyMessage) async {
    return showDialog(
        context: context,
        builder: (_) {
          final MediaQueryData mediaQuery = MediaQuery.of(context);
          final ThemeData theme = Theme.of(context);
          final ScreenUtil screenUtil = getIt<ScreenUtil>();
          return MediaQuery(
              data: mediaQuery.copyWith(
                  textScaleFactor: initialTextFactor,
                  boldText: initialBoldFactor),
              child: AlertDialog(
                contentPadding: EdgeInsets.all(0.0),
                elevation: 0.0,
                title: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: screenUtil.setHeight(20.0),
                    ),
                    child: Container(
                      width: screenUtil.setWidth(40.0),
                      height: screenUtil.setWidth(40.0),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Center(
                        child: Text(
                          "!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenUtil.setWidth(22.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                content: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: ListBody(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenUtil.setWidth(30.0),
                        ),
                        child: SizedBox(
                          width: mediaQuery.size.width,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              SetDefaultValue.setStringValue(titleMessage,
                                  type: DescriptionType.alert),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: screenUtil.setWidth(22.0),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenUtil.setHeight(10.0),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenUtil.setWidth(30.0),
                        ),
                        child: Text(
                          SetDefaultValue.setStringValue(bodyMessage,
                              type: DescriptionType.alert),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: screenUtil.setWidth(18.0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: screenUtil.setHeight(10.0),
                      ),
                      Container(
                        color: lightGrey,
                        width: mediaQuery.size.width,
                        height: 1.0,
                      ),
                      FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: screenUtil.setHeight(20.0),
                            ),
                            child: Text(
                              "Okay",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: screenUtil.setWidth(20.0),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ));
        });
  }
}
