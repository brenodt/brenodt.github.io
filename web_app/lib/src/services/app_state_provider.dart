import 'package:flutter/foundation.dart';

enum AppState {
  home,
  about,
  contact,
  blog,
}

class AppStateProvider with ChangeNotifier {
  AppState _appState = AppState.home;

  AppState get currentState => _appState;

  set currentState(AppState newState) {
    _appState = newState;
    notifyListeners();
  }
}
