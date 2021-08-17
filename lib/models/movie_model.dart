import 'package:movie_list/utilities/set_default_values.dart';

import '../data/constants.dart';

class MovieListModel {
  final int currentPage;
  final List<MovieModel> resultList;
  final int totalPages;

  MovieListModel({this.currentPage, this.resultList, this.totalPages});

  factory MovieListModel.fromJson(Map<String, dynamic> json) {
    return MovieListModel(
        currentPage: json["page"],
        resultList:
            json["results"].map<MovieModel>((each) => MovieModel.fromJson(each)).toList(),
        totalPages: json["total_pages"]);
  }
}

class MovieModel {
  final int id;
  final String img;
  final String title;
  final String releaseDate;
  final String description;
  final String language;
  final double popularity;
  final num voteAve;
  final int voteCount;

  MovieModel(
      {this.id,
      this.img,
      this.title,
      this.releaseDate,
      this.description,
      this.language,
      this.popularity,
      this.voteAve,
      this.voteCount});

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
        id: json["id"],
        img: json["poster_path"],
        title: SetDefaultValue.setStringValue(json["title"]),
        releaseDate: SetDefaultValue.setStringValue(json["release_date"]),
        description: SetDefaultValue.setStringValue(json["overview"],
            type: DescriptionType.overview),
        language: SetDefaultValue.setStringValue(json["original_language"]),
        popularity: json["popularity"] ?? 0.0,
        voteAve: json["vote_average"] ?? 0.0,
        voteCount: json["vote_count"] ?? 0);
  }
}
