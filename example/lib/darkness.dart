
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> darknessNotifier = ValueNotifier(ThemeMode.light);
void toggleDarkness() {
  darknessNotifier.value = darknessNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}

