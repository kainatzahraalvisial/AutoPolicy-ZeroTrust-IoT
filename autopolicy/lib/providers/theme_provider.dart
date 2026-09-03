import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage the theme mode: true = Dark Mode (Black), false = Light Mode (White)
final themeModeProvider = StateProvider<bool>((ref) => true);
