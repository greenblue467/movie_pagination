import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_list/main.dart';
import 'package:movie_list/pages/try_render_object_page.dart';
import 'package:movie_list/pages/reusable_widgets/poster_display.dart';
import 'package:movie_list/pages/reusable_widgets/star_shape.dart';
import 'package:movie_list/view_models/movie_Info_vm.dart';

import '../data/constants.dart';

class DetailPage extends StatelessWidget {
  static const id = "DetailPage";

  final MovieVm movie;

  DetailPage({@required this.movie});

  Widget _displayStars(ScreenUtil screenUtil, MediaQueryData mediaQuery) {
    //assume top score is 10
    //assume max display number of stars is 5
    final double ave = (movie.voteAve > 10 ? 10 : movie.voteAve / 2).toDouble();
    final int integerPart = ave.toInt();
    final double decimalPart = ave - integerPart;
    final int halfStarNum = decimalPart < 0.5 ? 0 : 1;
    final int leftStar = 5 - integerPart - halfStarNum;
    final List<StarShape> fullStar =
        List.filled(integerPart, StarShape(state: StarState.full));
    final List<StarShape> halfStar =
        List.filled(halfStarNum, StarShape(state: StarState.half));
    final List<StarShape> remainingStar =
        List.filled(leftStar, StarShape(state: StarState.empty));

    return Row(
      children: [
        SizedBox(
          width: screenUtil.setWidth(10.0),
        ),
        ...fullStar,
        ...halfStar,
        ...remainingStar,
        SizedBox(
          width: screenUtil.setWidth(5.0),
        ),
        Expanded(
          child: SizedBox(
            height: mediaQuery.size.width / 10,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "(${movie.voteCount.toString()})",
                style: TextStyle(
                  fontSize: screenUtil.setWidth(20.0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        SizedBox(
          width: screenUtil.setWidth(10.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final ThemeData theme = Theme.of(context);
    final ScreenUtil screenUtil = getIt<ScreenUtil>();
    return MediaQuery(
      data: mediaQuery.copyWith(
          textScaleFactor: initialTextFactor, boldText: initialBoldFactor),
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PosterDisplay(
                    url: movie.img,
                    movieId: movie.id,
                    isLarge: true,
                  ),
                  SizedBox(
                    height: screenUtil.setHeight(5.0),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenUtil.setWidth(10.0),
                    ),
                    child: Text(
                      movie.title,
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: screenUtil.setWidth(35.0),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: screenUtil.setHeight(5.0),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenUtil.setWidth(10.0),
                    ),
                    child: Text(
                      movie.releaseDate,
                      style: TextStyle(
                        fontSize: screenUtil.setWidth(25.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenUtil.setHeight(5.0),
                  ),
                  _displayStars(screenUtil, mediaQuery),
                  SizedBox(
                    height: screenUtil.setHeight(10.0),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenUtil.setWidth(10.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Popularity: " +
                                movie.popularity.toStringAsFixed(3),
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: screenUtil.setWidth(20.0),
                            ),
                          ),
                        ),
                        Container(
                          color: theme.primaryColor,
                          padding: EdgeInsets.all(
                            screenUtil.setWidth(5.0),
                          ),
                          child: Text(
                            movie.language.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenUtil.setWidth(20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenUtil.setHeight(20.0),
                  ),
                  Container(
                    color: lightGrey,
                    margin: EdgeInsets.symmetric(
                        horizontal: screenUtil.setWidth(10.0)),
                    width: mediaQuery.size.width,
                    height: 1.0,
                  ),
                  SizedBox(
                    height: screenUtil.setHeight(20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenUtil.setWidth(10.0),
                    ),
                    child: Text(
                      movie.description,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenUtil.setWidth(20.0),
                        height: screenUtil.setHeight(1.5),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenUtil.setHeight(20.0),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                height: screenUtil.setHeight(75.0),
                color: Colors.black12,
              ),
            ),
            Positioned(
              right: screenUtil.setWidth(10.0),
              top: screenUtil.setHeight(35.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  width: screenUtil.setWidth(30.0),
                  height: screenUtil.setWidth(30.0),
                  child: Center(
                    child: Text(
                      "X",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screenUtil.setWidth(20.0),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 3.0,
          backgroundColor: Colors.teal,
          child: Text(
            "GO",
            style: TextStyle(
                fontSize: screenUtil.setWidth(20.0), color: Colors.white),
          ),
         onPressed: (){
            Navigator.pushNamed(context, TryRenderObjectPage.id);
         },

        ),
      ),
    );
  }
}
