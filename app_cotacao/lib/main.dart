import 'package:app_cotacao/navbar.dart';
import 'package:flutter/material.dart';

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
