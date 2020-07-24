import 'package:flutter/foundation.dart';

enum AppState {
  home,
  about,
  contact,
  blog,
}

class AppStateProvider with ChangeNotifier {
  AppStateProvider() {
    _currentState = AppState.home;
  }
  AppState _currentState;

  AppState get currentState => _currentState;

  set currentState(AppState newState) {
    _currentState = newState;
    notifyListeners();
  }
}
