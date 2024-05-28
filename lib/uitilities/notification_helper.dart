import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    tz.initializeTimeZones();

    if (await Permission.scheduleExactAlarm.request().isGranted) {
      print('Permission granted for exact alarm');
    } else {
      print('Permission denied for exact alarm');
    }
  }

  static Future<void> scheduleNotification(
      int tid, String tododetails, DateTime scheduledTime) async {
    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'yourChannelId',
      'YourChannelName',
      channelDescription: 'YourChannelDescription',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      tid,
      'Reminder',
      'It\'s time for your event: $tododetails',
      tzScheduledTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(int tid) async {
    await flutterLocalNotificationsPlugin.cancel(tid);
  }

  static Future<void> scheduleDailyNotification(List<String> todoList) async {
    // Cancel the previous daily notification if any
    await cancelNotification(0);

    // Get the current date
    final now = DateTime.now();

    // Schedule a notification for 8 AM every day
    final scheduledTime = DateTime(now.year, now.month, now.day, 02, 30);
    await scheduleNotification(
        0, 'Today\'s To-Do List: $todoList', scheduledTime);
  }
}
