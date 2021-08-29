import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_list/data/web_services.dart';
import 'package:movie_list/pages/try_render_object_page.dart';
import 'package:movie_list/pages/detail_page.dart';
import 'package:movie_list/pages/list_page.dart';
import 'package:movie_list/utilities/navigation_style.dart';
import 'package:movie_list/view_models/animation_vm.dart';
import 'package:movie_list/view_models/movie_Info_vm.dart';
import 'package:provider/provider.dart';

final getIt = GetIt.instance;

void main() {
  getIt.registerLazySingleton<ScreenUtil>(() => ScreenUtil());
  getIt.registerLazySingleton<WebServices>(() => WebServices());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieInfoVm()),
        ChangeNotifierProvider(create: (_) => AnimationVm()),
      ],
      child: ScreenUtilInit(
        designSize: Size(414.0, 736.0),
        builder: () => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: ThemeData(
              primarySwatch: Colors.brown,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              scaffoldBackgroundColor: Colors.white,
              textTheme: ThemeData.light().textTheme.copyWith(
                    bodyText2: TextStyle(color: Colors.grey),
                  ),
              appBarTheme: AppBarTheme(
                color: Colors.white,
                elevation: 0,
                brightness: Brightness.light,
                centerTitle: false,
              )),
          initialRoute: ListPage.id,
          onGenerateRoute: _pageList,
        ),
      ),
    );
  }
}

PageRoute _pageList(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case ListPage.id:
      return MaterialPageRoute(builder: (_) => ListPage());
      break;
    case DetailPage.id:
      return CupertinoPageRoute(
          builder: (_) => DetailPage(
                movie: routeSettings.arguments,
              ),
          fullscreenDialog: true);
      break;
    case TryRenderObjectPage.id:
      return SlideBouncingNavigation(page: TryRenderObjectPage());
      break;
    default:
      return CupertinoPageRoute(builder: (_) => ListPage());
  }
}
