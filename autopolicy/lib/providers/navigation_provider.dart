import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int activeTab;
  final List<int> history;

  const NavigationState({required this.activeTab, required this.history});
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState(activeTab: 0, history: [0]));

  void selectTab(int tabIndex) {
    if (state.activeTab == tabIndex) return;
    final newHistory = List<int>.from(state.history)..add(tabIndex);
    state = NavigationState(activeTab: tabIndex, history: newHistory);
  }

  bool canGoBack() {
    return state.history.length > 1;
  }

  bool pop() {
    if (state.history.length > 1) {
      final newHistory = List<int>.from(state.history)..removeLast();
      final previousTab = newHistory.last;
      state = NavigationState(activeTab: previousTab, history: newHistory);
      return true;
    }
    return false;
  }
}

final navigationNotifierProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

// Controls active main layout tab index
final navigationTabProvider = StateProvider<int>((ref) {
  return ref.watch(navigationNotifierProvider).activeTab;
});
