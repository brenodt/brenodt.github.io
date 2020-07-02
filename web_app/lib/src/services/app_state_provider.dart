import 'package:flutter/foundation.dart';

enum AppState {
  home,
  about,
  contact,
  blog,
}

class AppStateProvider with ChangeNotifier {
  AppStateProvider() {
    currentState = _currentState;
  }
  AppState _currentState = AppState.home;
  List<bool> _state = <bool>[];

  AppState get currentState => _currentState;
  List<bool> get appState => _state;

  set currentState(AppState newState) {
    _currentState = newState;
    _state = List<bool>.filled(AppState.values.length, false);
    switch (_currentState) {
      case AppState.home:
        _state[0] = true;
        break;
      case AppState.about:
        _state[1] = true;
        break;
      case AppState.contact:
        _state[2] = true;
        break;
      case AppState.blog:
        _state[3] = true;
        break;
      default:
    }
    notifyListeners();
  }
}
