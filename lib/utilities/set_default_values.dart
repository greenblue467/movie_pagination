import 'package:movie_list/data/constants.dart';

class SetDefaultValue {
  static String setStringValue(String text,
      {DescriptionType type = DescriptionType.nonspecific}) {
    if (text == null || text.isEmpty) {
      switch (type) {
        case DescriptionType.alert:
          return "Alert";
          break;
        case DescriptionType.message:
          return "Something went wrong!";
          break;
        case DescriptionType.overview:
          return "There is no description for this movie!";
          break;
        default:
          return "Unknown";
      }
    }
    return text;
  }
}
