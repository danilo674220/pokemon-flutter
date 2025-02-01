import 'package:app1/screens/minipokedex.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> get appRoutes {
  return {
    "pokedex": (_) => const MiniPokedexPage(),
  };
}
