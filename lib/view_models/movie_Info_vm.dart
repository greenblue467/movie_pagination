import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie_list/data/web_services.dart';
import 'package:movie_list/main.dart';
import 'package:movie_list/models/movie_model.dart';

class MovieInfoVm with ChangeNotifier {
  final WebServices _webServices = getIt<WebServices>();
  MovieListVm _movieListVm = MovieListVm();
  int _requestPage = 0;
  List<MovieVm> _movies = List<MovieVm>();
  int _total = 0;
  bool _showLoading = true;
  bool _isLoading = false;

  MovieListVm get movieListVm => _movieListVm;

  int get requestPage => _requestPage;

  List<MovieVm> get movies => _movies;

  int get total => _total;

  bool get showLoading => _showLoading;

  bool get isLoading => _isLoading;

  Future<void> setMovieList(BuildContext context, isInitialRequest) async {
    _isLoading = true;
    notifyListeners();
    var movieData = await _webServices.fetchMovies(context, _requestPage);
    if (movieData != null) {
      _movieListVm = MovieListVm(movieListModel: movieData);
      List<MovieVm> tempList = _movieListVm.resultList;

      if (isInitialRequest) {
        _movies = [...tempList];
      } else {
        for (MovieVm movie in tempList) {
          _movies.add(movie);
        }
      }
      _requestPage += 1;
      _total = _movieListVm.totalPages;
    } else {
      _movieListVm = null;
    }

    _showLoading = true;
    _isLoading = false;
    notifyListeners();
  }

  void resetAndRefresh() {
    _movieListVm = MovieListVm();
    _requestPage = 0;
    _movies = List<MovieVm>();
    _total = 0;
    _showLoading = true;
    _isLoading = false;
    notifyListeners();
  }

  void setShowLoading() {
    _showLoading = false;
    notifyListeners();
  }

  void setIsLoading() {
    _isLoading = false;
    notifyListeners();
  }
}

class MovieListVm {
  final MovieListModel movieListModel;

  MovieListVm({this.movieListModel});

  int get currentPage => this.movieListModel.currentPage;

  List<MovieVm> get resultList => this
      .movieListModel
      .resultList
      .map<MovieVm>((each) => MovieVm(movieModel: each))
      .toList();

  int get totalPages => this.movieListModel.totalPages;
}

class MovieVm {
  final MovieModel movieModel;

  MovieVm({this.movieModel});

  int get id => movieModel.id;

  String get img => movieModel.img;

  String get title => movieModel.title;

  String get releaseDate => movieModel.releaseDate;

  String get description => movieModel.description;

  String get language => movieModel.language;

  double get popularity => movieModel.popularity;

  num get voteAve => movieModel.voteAve;

  int get voteCount => movieModel.voteCount;
}
