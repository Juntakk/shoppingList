import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  fruit,
  meat,
  sweets,
  spices,
  dairy,
  convenience,
  hygiene,
  other,
}

class Category {
  const Category(this.title, this.color);

  final String title;
  final Color color;
}
