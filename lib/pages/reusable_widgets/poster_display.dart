import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';

import '../../data/constants.dart';
import '../../main.dart';

class PosterDisplay extends StatelessWidget {
  final String url;
  final int movieId;
  final bool isLarge;

  PosterDisplay(
      {@required this.url, @required this.movieId, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ScreenUtil screenUtil = getIt<ScreenUtil>();
    return Hero(
      tag: movieId,
      child: AspectRatio(
          aspectRatio: imgRatio,
          child: url == null || url.isEmpty
              ? Container(
            color: theme.primaryColor,
                child: Center(
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        "Unavailable",
                        style: TextStyle(
                          color: Colors.black26,
                          fontSize: screenUtil.setWidth(isLarge ? 30.0 : 20.0),
                        ),
                      ),
                    ),
                  ),
              )
              : CachedNetworkImage(
                  imageUrl: (isLarge ? posterUrlL : posterUrlM) + url,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(
                    color: theme.primaryColor,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: theme.primaryColor,
                  ),
                )),
    );
  }
}
