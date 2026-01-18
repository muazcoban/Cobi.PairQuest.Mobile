import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings state
class SettingsState {
  final Locale locale;
  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final String cardTheme;
  final String playerName;

  const SettingsState({
    this.locale = const Locale('tr'),
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.cardTheme = 'animals',
    this.playerName = 'Player',
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    String? cardTheme,
    String? playerName,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      cardTheme: cardTheme ?? this.cardTheme,
      playerName: playerName ?? this.playerName,
    );
  }
}

/// Settings notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _localeKey = 'locale';
  static const _themeModeKey = 'themeMode';
  static const _soundKey = 'sound';
  static const _musicKey = 'music';
  static const _vibrationKey = 'vibration';
  static const _cardThemeKey = 'cardTheme';
  static const _playerNameKey = 'playerName';

  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final localeCode = prefs.getString(_localeKey) ?? 'tr';
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    final soundEnabled = prefs.getBool(_soundKey) ?? true;
    final musicEnabled = prefs.getBool(_musicKey) ?? true;
    final vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;
    final cardTheme = prefs.getString(_cardThemeKey) ?? 'animals';
    final playerName = prefs.getString(_playerNameKey) ?? 'Player';

    state = SettingsState(
      locale: Locale(localeCode),
      themeMode: ThemeMode.values[themeModeIndex],
      soundEnabled: soundEnabled,
      musicEnabled: musicEnabled,
      vibrationEnabled: vibrationEnabled,
      cardTheme: cardTheme,
      playerName: playerName,
    );
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
    state = state.copyWith(soundEnabled: enabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicKey, enabled);
    state = state.copyWith(musicEnabled: enabled);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, enabled);
    state = state.copyWith(vibrationEnabled: enabled);
  }

  Future<void> setCardTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardThemeKey, theme);
    state = state.copyWith(cardTheme: theme);
  }

  void toggleLanguage() {
    final newLocale = state.locale.languageCode == 'tr'
        ? const Locale('en')
        : const Locale('tr');
    setLocale(newLocale);
  }

  void toggleSound() {
    setSoundEnabled(!state.soundEnabled);
  }

  void toggleMusic() {
    setMusicEnabled(!state.musicEnabled);
  }

  void toggleVibration() {
    setVibrationEnabled(!state.vibrationEnabled);
  }

  Future<void> setPlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmedName = name.trim();
    final finalName = trimmedName.isEmpty ? 'Player' : trimmedName;
    await prefs.setString(_playerNameKey, finalName);
    state = state.copyWith(playerName: finalName);
  }
}

/// Settings provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

/// Locale provider
final localeProvider = Provider<Locale>((ref) {
  return ref.watch(settingsProvider).locale;
});

/// Theme mode provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});
