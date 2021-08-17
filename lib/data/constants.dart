import 'package:flutter/material.dart';

const double initialTextFactor = 1.0;
const bool initialBoldFactor = false;

const double blockRatio = 0.43;
const double imgRatio = 185 / 278;

const Color lightGrey = Color.fromRGBO(236, 236, 236, 1.0);

String movieApi =
    "https://api.themoviedb.org/3/search/movie?api_key=6753d9119b9627493ae129f3c3c99151&query=superman&page=";
String posterUrlM = "https://image.tmdb.org/t/p/w185";
String posterUrlL = "https://image.tmdb.org/t/p/w500";

enum StarState { full, half, empty }
enum DescriptionType { alert,message, overview, nonspecific }
