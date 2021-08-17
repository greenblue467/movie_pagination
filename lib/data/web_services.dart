import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:movie_list/models/movie_model.dart';
import 'package:http/http.dart' as http;
import 'package:movie_list/utilities/alert_windows.dart';
import 'constants.dart';

class WebServices {
  Future<MovieListModel> fetchMovies(BuildContext context, int page) async {
    try {
      var response = await http.get(movieApi + (page + 1).toString());
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return MovieListModel.fromJson(result);
      } else {
        print(response.statusCode);
        AlertWindows.alertWithOneBtn(
            context, response.statusCode.toString(), response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
