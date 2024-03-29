import 'dart:async';

enum NavBarItem { HOME, SEMANAL, MENSAL, TEMPO_REAL }

class NavBarBloc {
  final StreamController<NavBarItem> _navBarController =
      StreamController<NavBarItem>.broadcast();

  NavBarItem defaultItem = NavBarItem.HOME;

  Stream<NavBarItem> get itemStream => _navBarController.stream;

  void pickItem(int i) {
    switch (i) {
      case 0:
        _navBarController.sink.add(NavBarItem.HOME);
        break;
      case 1:
        _navBarController.sink.add(NavBarItem.SEMANAL);
        break;
      case 2:
        _navBarController.sink.add(NavBarItem.MENSAL);
        break;
      case 3:
        _navBarController.sink.add(NavBarItem.TEMPO_REAL);
        break;
    }
  }

  close() {
    _navBarController?.close();
  }
}
