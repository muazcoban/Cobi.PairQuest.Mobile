import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/notification_service.dart';

/// Provider for notification settings
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  return NotificationSettingsNotifier();
});

/// Notification settings model
class NotificationSettings extends Equatable {
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool achievementNotifications;
  final bool questNotifications;
  final bool streakWarningEnabled;

  const NotificationSettings({
    this.dailyReminderEnabled = true,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.achievementNotifications = true,
    this.questNotifications = true,
    this.streakWarningEnabled = true,
  });

  NotificationSettings copyWith({
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? achievementNotifications,
    bool? questNotifications,
    bool? streakWarningEnabled,
  }) {
    return NotificationSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      achievementNotifications:
          achievementNotifications ?? this.achievementNotifications,
      questNotifications: questNotifications ?? this.questNotifications,
      streakWarningEnabled: streakWarningEnabled ?? this.streakWarningEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyReminderEnabled': dailyReminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'achievementNotifications': achievementNotifications,
      'questNotifications': questNotifications,
      'streakWarningEnabled': streakWarningEnabled,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      dailyReminderEnabled: json['dailyReminderEnabled'] ?? true,
      reminderHour: json['reminderHour'] ?? 20,
      reminderMinute: json['reminderMinute'] ?? 0,
      achievementNotifications: json['achievementNotifications'] ?? true,
      questNotifications: json['questNotifications'] ?? true,
      streakWarningEnabled: json['streakWarningEnabled'] ?? true,
    );
  }

  /// Get reminder time as formatted string (HH:MM)
  String get formattedReminderTime {
    final hour = reminderHour.toString().padLeft(2, '0');
    final minute = reminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  List<Object?> get props => [
        dailyReminderEnabled,
        reminderHour,
        reminderMinute,
        achievementNotifications,
        questNotifications,
        streakWarningEnabled,
      ];
}

/// Notifier for managing notification settings
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  static const String _storageKey = 'notification_settings';
  final NotificationService _notificationService = NotificationService();

  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  /// Load settings from local storage
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_storageKey);
      if (settingsJson != null) {
        final data = jsonDecode(settingsJson) as Map<String, dynamic>;
        state = NotificationSettings.fromJson(data);
      }

      // Apply loaded settings after a delay to ensure notification service is ready
      Future.delayed(const Duration(seconds: 3), () {
        _applySettings();
      });
    } catch (e) {
      // Keep default settings on error
    }
  }

  /// Save settings to local storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Apply current settings to notification service
  Future<void> _applySettings() async {
    try {
      if (state.dailyReminderEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: state.reminderHour,
          minute: state.reminderMinute,
          title: 'Time to Play!',
          body: 'Your daily reward is waiting. Come back and play PairQuest!',
        );
      } else {
        await _notificationService.cancelDailyReminder();
      }
    } catch (e) {
      // Ignore errors - notification service may not be ready yet
    }
  }

  /// Toggle daily reminder
  Future<void> setDailyReminder(bool enabled) async {
    state = state.copyWith(dailyReminderEnabled: enabled);
    await _saveSettings();
    await _applySettings();
  }

  /// Set reminder time
  Future<void> setReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    await _saveSettings();
    await _applySettings();
  }

  /// Toggle achievement notifications
  Future<void> setAchievementNotifications(bool enabled) async {
    state = state.copyWith(achievementNotifications: enabled);
    await _saveSettings();
  }

  /// Toggle quest notifications
  Future<void> setQuestNotifications(bool enabled) async {
    state = state.copyWith(questNotifications: enabled);
    await _saveSettings();
  }

  /// Toggle streak warning
  Future<void> setStreakWarning(bool enabled) async {
    state = state.copyWith(streakWarningEnabled: enabled);
    await _saveSettings();
  }

  /// Show achievement notification if enabled
  Future<void> showAchievementUnlocked({
    required String title,
    required String description,
  }) async {
    if (state.achievementNotifications) {
      await _notificationService.showAchievementNotification(
        achievementTitle: title,
        achievementDescription: description,
      );
    }
  }

  /// Show quest complete notification if enabled
  Future<void> showQuestCompleted({
    required String questName,
    required int reward,
  }) async {
    if (state.questNotifications) {
      await _notificationService.showLocalNotification(
        title: 'Quest Completed!',
        body: '$questName - Earned $reward points!',
        payload: 'quests',
      );
    }
  }
}
