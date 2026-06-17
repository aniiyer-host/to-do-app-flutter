import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {

  static final FlutterLocalNotificationsPlugin
      notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(settings: settings);

    tz.initializeTimeZones();

    // ignore: unused_local_variable
    final currentTimeZone =
        await FlutterTimezone.getLocalTimezone();
    
    String timezoneName = currentTimeZone.identifier;

    if (timezoneName == "Asia/Calcutta") {
      timezoneName = "Asia/Kolkata";
    }
    tz.setLocalLocation(
      tz.getLocation(timezoneName),
    );

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await notifications
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestExactAlarmsPermission();
    
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {

    await notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: 
      tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      ),
      notificationDetails:  NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Task Reminders',
          channelDescription:
              'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
         AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await notifications.cancel(id: id);
  }

  static Future<void> cancelAllNotifications() async {
    await notifications.cancelAll();
  }
}