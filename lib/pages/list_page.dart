import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_list/data/constants.dart';
import 'package:movie_list/main.dart';
import 'package:movie_list/pages/detail_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_list/pages/reusable_widgets/error_screen.dart';
import 'package:movie_list/pages/reusable_widgets/poster_display.dart';
import 'package:movie_list/pages/reusable_widgets/shimmer_item.dart';
import 'package:movie_list/view_models/animation_vm.dart';
import 'package:movie_list/view_models/movie_Info_vm.dart';
import 'package:provider/provider.dart';

class ListPage extends StatefulWidget {
  static const id = "ListPage";

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final movieInfoVmF = Provider.of<MovieInfoVm>(context, listen: false);
      final animationVmF = Provider.of<AnimationVm>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          movieInfoVmF.showLoading) {
        movieInfoVmF.setShowLoading();
        _getMovies(false);
      }

      if (_scrollController.position.pixels > 100.0) {
        animationVmF.setShowUp(true);
      } else {
        animationVmF.setShowUp(false);
      }
    });

    Future.delayed(Duration.zero, () async {
      await _getMovies(true);
    });
  }

  Future<void> _getMovies(bool isInit) async {
    final movieInfoVmF = Provider.of<MovieInfoVm>(context, listen: false);
    if (movieInfoVmF.requestPage == 0 ||
        movieInfoVmF.requestPage < movieInfoVmF.total) {
      await movieInfoVmF.setMovieList(context, isInit);
    } else {
      movieInfoVmF.setIsLoading();
    }
  }

  Future<void> _refreshOrReload({bool isRefresh = false}) async {
    final movieInfoVmF = Provider.of<MovieInfoVm>(context, listen: false);
    if (movieInfoVmF.isLoading != true) {
      await Future.delayed(Duration(seconds: isRefresh ? 2 : 0));
      movieInfoVmF.resetAndRefresh();
      await Future.delayed(Duration(seconds: isRefresh ? 0 : 1));
      await _getMovies(true);
    }
  }

  Widget _pullDownToRefresh(ScreenUtil screenUtil,
      {bool isFromEmptyList = false}) {
    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: screenUtil.setHeight(100.0),
      refreshIndicatorExtent: screenUtil.setHeight(100.0),
      builder: (
        _,
        RefreshIndicatorMode state,
        double extent,
        double distance,
        __,
      ) {
        return _customRefresher(
            screenUtil, state, extent, distance, isFromEmptyList);
      },
      onRefresh: () {
        return _refreshOrReload(isRefresh: true);
      },
    );
  }

  Widget _customRefresher(
      ScreenUtil screenUtil,
      RefreshIndicatorMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      bool isFromEmptyList) {
    final double completionPercent = pulledExtent / refreshTriggerPullDistance;
    return SingleChildScrollView(
      child: Container(
        color: isFromEmptyList ? lightGrey : Colors.white,
        height: screenUtil.setHeight(100.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIndicatorForRefreshState(
                refreshState, screenUtil.setWidth(18.0), completionPercent),
            SizedBox(
              height: screenUtil.setHeight(10.0),
            ),
            Opacity(
              opacity: 0.8 * completionPercent.clamp(0.0, 1.0),
              child: Text(
                "Refreshing...",
                style: TextStyle(
                  fontSize: screenUtil.setWidth(20.0),
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorForRefreshState(RefreshIndicatorMode refreshState,
      double radius, double percentageComplete) {
    switch (refreshState) {
      case RefreshIndicatorMode.drag:
        const Curve opacityCurve = Interval(0.0, 0.35, curve: Curves.easeInOut);
        return Opacity(
          opacity: opacityCurve.transform(percentageComplete),
          child: CupertinoActivityIndicator.partiallyRevealed(
              radius: radius, progress: percentageComplete),
        );
      case RefreshIndicatorMode.armed:
      case RefreshIndicatorMode.refresh:
        return CupertinoActivityIndicator(radius: radius);
      case RefreshIndicatorMode.done:
        return CupertinoActivityIndicator(radius: radius);
      default:
        return Container();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final ThemeData theme = Theme.of(context);
    final ScreenUtil screenUtil = getIt<ScreenUtil>();
    return MediaQuery(
      data: mediaQuery.copyWith(
          textScaleFactor: initialTextFactor, boldText: initialBoldFactor),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "MOVIES",
            style: TextStyle(
                color: theme.primaryColor,
                fontSize: screenUtil.setWidth(25.0),
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Consumer<MovieInfoVm>(
          builder: (_, movieInfoVm, __) {
            if (movieInfoVm.movieListVm == null &&
                movieInfoVm.requestPage == 0) {
              return ErrorScreen(
                reLoad: _refreshOrReload,
              );
            } else if (movieInfoVm.requestPage == 0) {
              return Padding(
                padding: EdgeInsets.only(
                  top: screenUtil.setWidth(10.0),
                  left: screenUtil.setWidth(10.0),
                  right: screenUtil.setWidth(10.0),
                ),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: screenUtil.setWidth(10.0),
                    mainAxisSpacing: screenUtil.setWidth(10.0),
                    childAspectRatio: blockRatio,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => ShimmerItem(),
                ),
              );
            } else if (movieInfoVm.requestPage != 0 &&
                movieInfoVm.movies.isEmpty) {
              return CustomScrollView(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  _pullDownToRefresh(screenUtil, isFromEmptyList: true),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: mediaQuery.size.height / 2 -
                          AppBar().preferredSize.height,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenUtil.setWidth(20.0)),
                      child: Text(
                        "There are no movies yet!",
                        style: TextStyle(
                          fontSize: screenUtil.setWidth(18.0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Stack(
                children: [
                  CustomScrollView(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    controller: _scrollController,
                    slivers: [
                      _pullDownToRefresh(screenUtil),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: screenUtil.setWidth(10.0),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenUtil.setWidth(10.0),
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: screenUtil.setWidth(10.0),
                                  mainAxisSpacing: screenUtil.setWidth(10.0),
                                  childAspectRatio: blockRatio),
                          delegate: SliverChildBuilderDelegate((_, index) {
                            MovieVm movie = movieInfoVm.movies[index];

                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, DetailPage.id,
                                  arguments: movie),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PosterDisplay(
                                    url: movie.img,
                                    movieId: movie.id,
                                  ),
                                  SizedBox(
                                    height: screenUtil.setWidth(5.0),
                                  ),
                                  Text(
                                    movie.title,
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: screenUtil.setWidth(20.0),
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  SizedBox(
                                    height: screenUtil.setWidth(2.0),
                                  ),
                                  Text(
                                    movie.releaseDate,
                                    style: TextStyle(
                                        fontSize: screenUtil.setWidth(16.0)),
                                  ),
                                  SizedBox(
                                    height: screenUtil.setWidth(5.0),
                                  ),
                                  Expanded(
                                    child: Text(
                                      movie.description,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: screenUtil.setWidth(14.0)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }, childCount: movieInfoVm.movies.length),
                        ),
                      ),
                      if (movieInfoVm.isLoading)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenUtil.setHeight(15.0)),
                            child: Column(
                              children: [
                                CupertinoActivityIndicator(
                                  radius: screenUtil.setWidth(18.0),
                                ),
                                SizedBox(
                                  height: screenUtil.setHeight(15.0),
                                ),
                                Text(
                                  "Loading...",
                                  style: TextStyle(
                                    fontSize: screenUtil.setWidth(20.0),
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ),
                      if (movieInfoVm.isLoading == false &&
                          movieInfoVm.movieListVm == null &&
                          movieInfoVm.requestPage != 0)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: screenUtil.setHeight(20.0),
                            ),
                            child: Text(
                              "Unable to get data!",
                              style: TextStyle(
                                fontSize: screenUtil.setWidth(20.0),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Consumer<AnimationVm>(
                    builder: (_, animationAm, __) => AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      bottom: screenUtil.setHeight(30.0),
                      right: screenUtil
                          .setHeight(animationAm.showUp ? 0.0 : -30.0),
                      child: GestureDetector(
                        onTap: _scrollToTop,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.8),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                screenUtil.setWidth(10.0),
                              ),
                              bottomLeft: Radius.circular(
                                screenUtil.setWidth(30.0),
                              ),
                              topRight: Radius.circular(
                                screenUtil.setWidth(10.0),
                              ),
                            ),
                          ),
                          width: screenUtil.setWidth(60.0),
                          height: screenUtil.setWidth(60.0),
                          child: Center(
                            child: Text(
                              "UP",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenUtil.setWidth(20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

