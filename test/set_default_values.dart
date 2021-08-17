import 'package:flutter_test/flutter_test.dart';
import 'package:movie_list/data/constants.dart';
import 'package:movie_list/utilities/set_default_values.dart';

void main() {
  test("null or empty strings should be set to default values", () {
    //ARRANGE
    final String inputText1 = null;
    final String inputText2 = "";
    final String inputText3 = "Test";

    //ACT
    final String result1 = SetDefaultValue.setStringValue(inputText1);
    final String result2 = SetDefaultValue.setStringValue(inputText2);
    final String result3 =
        SetDefaultValue.setStringValue(inputText1, type: DescriptionType.alert);
    final String result4 =
        SetDefaultValue.setStringValue(inputText2, type: DescriptionType.alert);
    final String result5 = SetDefaultValue.setStringValue(inputText1,
        type: DescriptionType.message);
    final String result6 = SetDefaultValue.setStringValue(inputText2,
        type: DescriptionType.message);
    final String result7 = SetDefaultValue.setStringValue(inputText1,
        type: DescriptionType.overview);
    final String result8 = SetDefaultValue.setStringValue(inputText2,
        type: DescriptionType.overview);
    final String result9 = SetDefaultValue.setStringValue(inputText3);
    final String result10 =
        SetDefaultValue.setStringValue(inputText3, type: DescriptionType.alert);
    final String result11 = SetDefaultValue.setStringValue(inputText3,
        type: DescriptionType.message);
    final String result12 = SetDefaultValue.setStringValue(inputText3,
        type: DescriptionType.overview);

    //ASSERT
    expect(result1, "Unknown");
    expect(result2, "Unknown");
    expect(result3, "Alert");
    expect(result4, "Alert");
    expect(result5, "Something went wrong!");
    expect(result6, "Something went wrong!");
    expect(result7, "There is no description for this movie!");
    expect(result8, "There is no description for this movie!");
    expect(result9, inputText3);
    expect(result10, inputText3);
    expect(result11, inputText3);
    expect(result12, inputText3);
  });
}
