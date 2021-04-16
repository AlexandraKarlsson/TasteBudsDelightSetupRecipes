import 'dart:io';

import 'recipe.dart';

class User {
  File user;
  List<Recipe> recipes = [];
  User(this.user, this.recipes);
}
