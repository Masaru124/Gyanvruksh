import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class SetTheme extends ThemeEvent {
  final bool isDark;
  SetTheme(this.isDark);
}

class ThemeState {
  final bool isDark;
  final ThemeMode themeMode;

  const ThemeState({
    required this.isDark,
    this.themeMode = ThemeMode.system,
  });

  ThemeState copyWith({
    bool? isDark,
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      isDark: isDark ?? this.isDark,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(isDark: false)) {
    on<ToggleTheme>((event, emit) async {
      final newIsDark = !state.isDark;
      emit(state.copyWith(isDark: newIsDark));
      // Add smooth transition delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));
    });

    on<SetTheme>((event, emit) {
      emit(state.copyWith(isDark: event.isDark));
    });
  }

  // Helper method to get current theme data
  ThemeData getCurrentTheme(BuildContext context) {
    return state.isDark
        ? ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3C6EFA),
              secondary: Color(0xFFA58DF5),
              tertiary: Color(0xFF26A69A),
              surface: Color(0xFF121212),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.white,
            ),
            textTheme: const TextTheme().apply(
              fontFamily: 'Poppins',
            ),
          )
        : ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3C6EFA),
              secondary: Color(0xFFA58DF5),
              tertiary: Color(0xFF26A69A),
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black,
            ),
            textTheme: const TextTheme().apply(
              fontFamily: 'Poppins',
            ),
          );
  }
}
