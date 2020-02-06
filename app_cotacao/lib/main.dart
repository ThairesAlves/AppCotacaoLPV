import 'package:flutter/material.dart';
import 'package:app_cotacao/navbar.dart';

void main() {
  runApp(Cotacao());
}

class Cotacao extends StatelessWidget {
  static const String _title = 'App Cotação';


  @override
  Widget build(BuildContext context) {
  return MaterialApp(
  title: _title,
  home: NavBar(),
  );
  }
  }
