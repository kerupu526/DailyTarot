import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'NotoSansKR';

  static const TextStyle bodyDefault = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: 'NotoSansKR'
  );

  static const TextStyle subtitleText = TextStyle(
    color: Colors.white,
    fontSize: 18,
    height: 1.5,
  );

  static const TextStyle subtitleBold = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.5,
  );

  static const TextStyle largeBold = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle largeText = TextStyle(
      color: Colors.white,
      fontSize: 18,
  );

  static const TextStyle extraLargeText = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: .w600,
  );
  
  static const TextStyle extraLargeBold = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: .bold,
  );

  static const TextStyle titleBold = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle titleText = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: .w500,
    fontFamily: 'NotoSansKR',
  );

  static const TextStyle boldText = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle storytelling = TextStyle(
    color: Colors.white,
    fontSize: 14,
    height: 1.8, // 줄간격 상수화
    fontFamily: _fontFamily,
  );

  static final TextStyle descText = TextStyle(
    color: Colors.white70,
    fontSize: 15,
    fontWeight: .w600,
  );

  static final TextStyle hintText = TextStyle(
    color: Colors.white.withValues(alpha: 0.5),
    fontSize: 15,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle etcText = TextStyle(
      color: Colors.white,
      fontSize: 14,
  );

  static const TextStyle etcBold = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: .bold,
  );
  
  static const TextStyle miniBold = TextStyle(
    color: Colors.white70,
    fontSize: 12,
    fontWeight: .bold,
    letterSpacing: -0.4,
  );

  static const TextStyle miniText = TextStyle(
    color: Colors.white70,
    fontSize: 12,
  );
}