import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Service de gestion des notifications locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Gère le clic sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Gérer la navigation en fonction du payload
  }

  /// Demande les permissions (iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return result ?? true;
  }

  /// Affiche une notification simple
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'budget_buddy_channel',
      'BudgetBuddy',
      channelDescription: 'Notifications de BudgetBuddy',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  /// Notification de dépassement de budget
  Future<void> notifyBudgetExceeded({
    required String categoryName,
    required double limit,
    required double spent,
    required double excess,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '⚠️ Budget dépassé !',
      body:
          'Votre budget "$categoryName" est dépassé de ${excess.toStringAsFixed(2)} €. '
          'Limite: ${limit.toStringAsFixed(2)} € | Dépensé: ${spent.toStringAsFixed(2)} €',
      payload: 'budget_exceeded:$categoryName',
    );
  }

  /// Notification d'alerte de budget (seuil)
  Future<void> notifyBudgetWarning({
    required String categoryName,
    required double limit,
    required double spent,
    required double percentage,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '⚡ Attention au budget !',
      body:
          'Vous avez utilisé ${percentage.toStringAsFixed(0)}% de votre budget "$categoryName". '
          'Reste: ${(limit - spent).toStringAsFixed(2)} €',
      payload: 'budget_warning:$categoryName',
    );
  }

  /// Notification d'objectif d'épargne atteint
  Future<void> notifySavingsGoalReached({
    required String goalName,
    required double targetAmount,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '🎉 Objectif atteint !',
      body:
          'Félicitations ! Vous avez atteint votre objectif "$goalName" de ${targetAmount.toStringAsFixed(2)} €',
      payload: 'goal_reached:$goalName',
    );
  }

  /// Notification d'objectif d'épargne proche
  Future<void> notifySavingsGoalNearTarget({
    required String goalName,
    required double targetAmount,
    required double currentAmount,
    required double percentage,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '🎯 Presque là !',
      body:
          'Plus que ${(targetAmount - currentAmount).toStringAsFixed(2)} € pour atteindre "$goalName" (${percentage.toStringAsFixed(0)}%)',
      payload: 'goal_near:$goalName',
    );
  }

  /// Notification d'échéance d'objectif proche
  Future<void> notifySavingsGoalDeadlineApproaching({
    required String goalName,
    required int daysRemaining,
    required double remainingAmount,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '📅 Échéance proche',
      body:
          'Plus que $daysRemaining jours pour "$goalName". '
          'Il reste ${remainingAmount.toStringAsFixed(2)} € à épargner.',
      payload: 'goal_deadline:$goalName',
    );
  }

  /// Notification de rappel de sauvegarde
  Future<void> notifyBackupReminder() async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '💾 Sauvegarde recommandée',
      body: 'Il est temps de sauvegarder vos données financières.',
      payload: 'backup_reminder',
    );
  }

  /// Notification de rappel de transaction récurrente
  Future<void> notifyRecurringTransaction({
    required String title,
    required double amount,
    required String type,
  }) async {
    final emoji = type == 'income' ? '💰' : '💸';
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '$emoji Transaction récurrente',
      body:
          'N\'oubliez pas votre transaction "$title" de ${amount.toStringAsFixed(2)} €',
      payload: 'recurring_transaction:$title',
    );
  }

  /// Notification de rapport mensuel disponible
  Future<void> notifyMonthlyReportAvailable({
    required String month,
    required double income,
    required double expense,
    required double balance,
  }) async {
    final emoji = balance >= 0 ? '📈' : '📉';
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '$emoji Rapport mensuel disponible',
      body:
          'Rapport de $month: Revenus ${income.toStringAsFixed(2)} € | '
          'Dépenses ${expense.toStringAsFixed(2)} € | '
          'Solde ${balance.toStringAsFixed(2)} €',
      payload: 'monthly_report:$month',
    );
  }

  /// Notification de recommandation d'économie
  Future<void> notifySavingsRecommendation({
    required String recommendation,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '💡 Conseil d\'épargne',
      body: recommendation,
      payload: 'savings_recommendation',
    );
  }

  /// Planifie une notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'budget_buddy_channel',
      'BudgetBuddy',
      channelDescription: 'Notifications de BudgetBuddy',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Convertit DateTime en TZDateTime
  // ignore: deprecated_member_use
  _convertToTZDateTime(DateTime dateTime) {
    // Simple conversion - dans un vrai projet, utiliser timezone package
    return dateTime;
  }

  /// Annule une notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Récupère les notifications en attente
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Récupère les notifications actives
  Future<List<ActiveNotification>> getActiveNotifications() async {
    return await _notificationsPlugin.getActiveNotifications();
  }
}
