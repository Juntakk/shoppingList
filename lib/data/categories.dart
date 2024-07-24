import 'package:flutter/material.dart';

import "package:shopping/models/category.dart";

const categories = {
  Categories.vegetables: Category(
    'Vegetables',
    Color.fromARGB(255, 3, 88, 46),
  ),
  Categories.fruit: Category(
    'Fruit',
    Color.fromARGB(255, 202, 122, 1),
  ),
  Categories.meat: Category(
    'Meat',
    Color.fromARGB(255, 175, 11, 11),
  ),
  Categories.dairy: Category(
    'Dairy',
    Color.fromARGB(255, 255, 255, 255),
  ),
  Categories.sweets: Category(
    'Sweets',
    Color.fromARGB(255, 194, 22, 157),
  ),
  Categories.spices: Category(
    'Spices',
    Color.fromARGB(255, 255, 187, 0),
  ),
  Categories.convenience: Category(
    'Convenience',
    Color.fromARGB(255, 74, 1, 98),
  ),
  Categories.hygiene: Category(
    'Hygiene',
    Color.fromARGB(255, 3, 131, 166),
  ),
  Categories.other: Category(
    'Other',
    Color.fromARGB(255, 122, 122, 122),
  ),
};
