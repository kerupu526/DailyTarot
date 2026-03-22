import 'package:flutter/material.dart';

import 'custom_page_route.dart';

void pushPage(BuildContext context, Widget page) {
  Navigator.of(context).push(CustomPageRoute(child: page));
}

void pushReplacementPage(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(CustomPageRoute(child: page));
}

void pushAndRemoveAllPage(BuildContext context, Widget page) {
  Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(child: page),
          (Route<dynamic> route) => false);
}