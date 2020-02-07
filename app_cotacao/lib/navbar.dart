import 'package:app_cotacao/bottom_navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_cotacao/calculo_diario.dart';
import 'package:app_cotacao/calculo_semanal.dart';
import 'package:app_cotacao/calculo_mensal.dart';

class NavBar extends StatefulWidget {
  createState() => _NavBarAppState();
}

class _NavBarAppState extends State<NavBar> {
  NavBarBloc _bottomNavBarBloc;

  @override
  void initState() {
    super.initState();
    _bottomNavBarBloc = NavBarBloc();
  }

  @override
  void dispose() {
    _bottomNavBarBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: StreamBuilder<NavBarItem>(
        stream: _bottomNavBarBloc.itemStream,
        initialData: _bottomNavBarBloc.defaultItem,
        builder: (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
          switch (snapshot.data) {
            case NavBarItem.HOME:
              return Diario();
            case NavBarItem.SEMANAL:
              return Semanal();
            case NavBarItem.MENSAL:
              return Mensal();
          }
        },
      ),
      bottomNavigationBar: StreamBuilder(
        stream: _bottomNavBarBloc.itemStream,
        initialData: _bottomNavBarBloc.defaultItem,
        builder: (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
          return BottomNavigationBar(
            currentIndex: snapshot.data.index,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            onTap: _bottomNavBarBloc.pickItem,
            items: [
              BottomNavigationBarItem(
                title: Text('Diário'),
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                title: Text('Semanal'),
                icon: Icon(Icons.insert_invitation),
              ),
              BottomNavigationBarItem(
                title: Text('Mensal'),
                icon: Icon(Icons.list),
              ),
            ],
          );
        },
      ),
    );
  }
}
