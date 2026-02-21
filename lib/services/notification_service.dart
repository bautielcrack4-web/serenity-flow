import 'dart:io';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 🔔 Notification Service — Personalized push notifications
/// Inspired by top wellness apps (Calm, Headspace, Noom, MyFitnessPal)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Preference keys
  static const _prefEnabled = 'notif_enabled';
  static const _prefPracticeHour = 'notif_practice_hour';
  static const _prefPracticeMinute = 'notif_practice_minute';
  static const _prefStreakEnabled = 'notif_streak_enabled';
  static const _prefWaterEnabled = 'notif_water_enabled';
  static const _prefWeeklyEnabled = 'notif_weekly_enabled';

  // Notification IDs
  static const _idDailyPractice = 100;
  static const _idStreakRisk = 200;
  static const _idWater1 = 301;
  static const _idWater2 = 302;
  static const _idWater3 = 303;
  static const _idWeeklySummary = 400;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Request notification permission (call from onboarding)
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  /// Schedule all enabled notifications based on user preferences
  Future<void> scheduleAll() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefEnabled) ?? true;
    if (!enabled) {
      await cancelAll();
      return;
    }

    // 🧘 Daily Practice Reminder
    final practiceHour = prefs.getInt(_prefPracticeHour) ?? 8;
    final practiceMinute = prefs.getInt(_prefPracticeMinute) ?? 0;
    await _scheduleDailyPractice(practiceHour, practiceMinute);

    // 🔥 Streak at Risk (8 PM)
    final streakEnabled = prefs.getBool(_prefStreakEnabled) ?? true;
    if (streakEnabled) {
      await _scheduleStreakReminder();
    }

    // 💧 Water Reminders (12 PM, 3 PM, 6 PM)
    final waterEnabled = prefs.getBool(_prefWaterEnabled) ?? true;
    if (waterEnabled) {
      await _scheduleWaterReminders();
    }

    // 📊 Weekly Summary (Sunday 10 AM)
    final weeklyEnabled = prefs.getBool(_prefWeeklyEnabled) ?? true;
    if (weeklyEnabled) {
      await _scheduleWeeklySummary();
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Getters/Setters for Preferences ─────────────────────

  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefEnabled) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, value);
    await scheduleAll();
  }

  Future<TimeOfDay> get practiceTime async {
    final prefs = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: prefs.getInt(_prefPracticeHour) ?? 8,
      minute: prefs.getInt(_prefPracticeMinute) ?? 0,
    );
  }

  Future<void> setPracticeTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefPracticeHour, time.hour);
    await prefs.setInt(_prefPracticeMinute, time.minute);
    await scheduleAll();
  }

  Future<bool> get isStreakEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefStreakEnabled) ?? true;
  }

  Future<void> setStreakEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefStreakEnabled, value);
    await scheduleAll();
  }

  Future<bool> get isWaterEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefWaterEnabled) ?? true;
  }

  Future<void> setWaterEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefWaterEnabled, value);
    await scheduleAll();
  }

  Future<bool> get isWeeklyEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefWeeklyEnabled) ?? true;
  }

  Future<void> setWeeklyEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefWeeklyEnabled, value);
    await scheduleAll();
  }

  // ─── Private Scheduling Methods ─────────────────────────

  NotificationDetails get _notificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'yuna_wellness',
        'Yuna Wellness',
        channelDescription: 'Daily wellness reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  bool get _isEs => PlatformDispatcher.instance.locale.languageCode == 'es';

  Future<void> _scheduleDailyPractice(int hour, int minute) async {
    await _plugin.cancel(_idDailyPractice);
    
    final messages = [
      _isEs 
          ? 'Tu cuerpo te pide 10 min de yoga hoy 🧘'
          : 'Your body is asking for 10 min of yoga today 🧘',
      _isEs
          ? 'Empieza el día con energía ✨'
          : 'Start your day with energy ✨',
      _isEs
          ? 'Solo 10 minutos pueden cambiar tu día 💫'
          : 'Just 10 minutes can change your day 💫',
    ];
    final msg = messages[DateTime.now().day % messages.length];

    await _plugin.zonedSchedule(
      _idDailyPractice,
      'Yuna',
      msg,
      _nextInstanceOfTime(hour, minute),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleStreakReminder() async {
    await _plugin.cancel(_idStreakRisk);
    
    final body = _isEs
        ? '¡No pierdas tu racha! Aún hay tiempo para tu sesión 🔥'
        : "Don't lose your streak! There's still time for your session 🔥";

    await _plugin.zonedSchedule(
      _idStreakRisk,
      'Yuna',
      body,
      _nextInstanceOfTime(20, 0), // 8 PM
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWaterReminders() async {
    final times = [(12, 0, _idWater1), (15, 0, _idWater2), (18, 0, _idWater3)];
    final body = _isEs
        ? '¿Ya tomaste tu agua? 💧'
        : 'Have you had your water? 💧';

    for (final t in times) {
      await _plugin.cancel(t.$3);
      await _plugin.zonedSchedule(
        t.$3,
        'Yuna',
        body,
        _nextInstanceOfTime(t.$1, t.$2),
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> _scheduleWeeklySummary() async {
    await _plugin.cancel(_idWeeklySummary);

    final body = _isEs
        ? '¡Revisa tu progreso de la semana! 📊'
        : 'Check your weekly progress! 📊';

    await _plugin.zonedSchedule(
      _idWeeklySummary,
      'Yuna',
      body,
      _nextInstanceOfDayAndTime(DateTime.sunday, 10, 0),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // ─── Time Helpers ────────────────────────────────────────

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int weekday, int hour, int minute) {
    var date = _nextInstanceOfTime(hour, minute);
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}
