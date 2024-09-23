import 'package:flutter/material.dart';
import 'package:grocery_list/models/category.dart';

const categories = {
  Categories.enjoyment: Category(
    'Enjoyment',
    Color.fromARGB(255, 45, 1, 61),
  ),
  Categories.exercise: Category(
    'Exercise',
    Color.fromARGB(255, 61, 81, 4),
  ),
  Categories.travel: Category(
    'Travel',
    Color.fromARGB(255, 150, 207, 179),
  ),
  Categories.cruise: Category(
    'Cruise',
    Colors.red,
  ),
  Categories.pet: Category(
    'Pet',
    Color.fromARGB(255, 1, 40, 3),
  ),
  Categories.vegetables: Category(
    'Vegetables',
    Color.fromARGB(255, 0, 255, 128),
  ),
  Categories.fruit: Category(
    'Fruit',
    Color.fromARGB(255, 145, 255, 0),
  ),
  Categories.meat: Category(
    'Meat',
    Color.fromARGB(255, 255, 102, 0),
  ),
  Categories.dairy: Category(
    'Dairy',
    Color.fromARGB(255, 155, 219, 233),
  ),
  Categories.carbs: Category(
    'Carbs',
    Color.fromARGB(255, 0, 60, 255),
  ),
  Categories.sweets: Category(
    'Sweets',
    Color.fromARGB(255, 255, 149, 0),
  ),
  Categories.spices: Category(
    'Spices',
    Color.fromARGB(255, 255, 187, 0),
  ),
  Categories.convenience: Category(
    'Convenience',
    Color.fromARGB(255, 191, 0, 255),
  ),
  Categories.hygiene: Category(
    'Hygiene',
    Color.fromARGB(255, 149, 0, 255),
  ),
  Categories.other: Category(
    'Other',
    Color.fromARGB(255, 2, 87, 98),
  ),
};
