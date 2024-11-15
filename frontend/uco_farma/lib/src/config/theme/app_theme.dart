import 'package:flutter/material.dart';


//const Color _customColor = Color(0xFF6200EE);

const List<Color> _colorThemes = [
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.blue,
  Colors.lightBlue,
  Colors.indigo,
];
//There is  6 colors in the list _colorThemes

class AppTheme{
  ThemeData theme(){
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorThemes[1],
    );
  }
}

