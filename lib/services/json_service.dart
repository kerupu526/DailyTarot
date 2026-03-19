import 'dart:convert';

import 'package:flutter/services.dart';

Future<List<dynamic>> loadJsonData(String path) async {
  final String response = await rootBundle.loadString(path);
  return json.decode(response); // JSON 문자열 -> Dart 리스트 변환
}