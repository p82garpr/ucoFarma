import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Recordatorios de medicamentos',
          channelDescription: 'Canal para recordatorios de medicamentos',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      print('Intentando programar notificación para: ${scheduledDate.toString()}');
      
      bool success = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'scheduled_channel',
          title: title,
          body: body,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar(
          year: scheduledDate.year,
          month: scheduledDate.month,
          day: scheduledDate.day,
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          second: 0,
          millisecond: 0,
          repeats: false,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      print('Resultado de programación: $success');
      
      // Verificar las notificaciones programadas
      //TODO: Verificar si esto es necesario y borrarlo si no es necesario
      final List<NotificationModel> scheduledNotifications = 
          await AwesomeNotifications().listScheduledNotifications();
      print('Notificaciones programadas: ${scheduledNotifications.length}');
      for (var notification in scheduledNotifications) {
        print('ID: ${notification.content?.id}');
        print('Título: ${notification.content?.title}');
        if (notification.schedule is NotificationCalendar) {
          final calendar = notification.schedule as NotificationCalendar;
          print('Programada para: ${calendar.year}-${calendar.month}-${calendar.day} ${calendar.hour}:${calendar.minute}');
        }
      }

    } catch (e) {
      print('Error al programar notificación: $e');
      rethrow;
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'scheduled_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
} 