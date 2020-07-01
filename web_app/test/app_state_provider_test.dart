import 'package:flutter_test/flutter_test.dart';
import 'package:web_app/src/services/app_state_provider.dart';

void main() {
  group('Tests app state control behavior', () {
    final AppStateProvider stateProvider = AppStateProvider();

    test('Tests getting current state of Provider', () {
      final AppState currentState = stateProvider.currentState;
      expect(currentState, AppState.home);
    });

    test('Tests updating current state of Provider', () {
      const AppState about = AppState.about;

      stateProvider.currentState = about;
      final AppState currentState = stateProvider.currentState;
      expect(currentState, about);
    });
  });
}
