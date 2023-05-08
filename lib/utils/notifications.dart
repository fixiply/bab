import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' as Foundation;

// Internal package
import 'package:bb/main.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/helpers/date_helper.dart';

// External package
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class Notifications {
  static final Notifications _singleton = Notifications._internal();

  factory Notifications() {
    return _singleton;
  }

  Notifications._internal();

  void initialize() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = !Foundation.kIsWeb &&
        Platform.isLinux
        ? null
        : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails!.notificationResponse!.payload;
    }
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true
    );
    // final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings(
    //     requestAlertPermission: false,
    //     requestBadgePermission: false,
    //     requestSoundPermission: false);
    final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      selectedNotificationPayload = notificationResponse.payload;
      selectNotificationStream.add(selectedNotificationPayload);
    });
  }

  Future<void> _configureLocalTimeZone() async {
    if (Foundation.kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  void permissions() async {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showNotification(int id, String title, {String? body, String? payload, String? scheduled}) async {
    await _configureLocalTimeZone();
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channelId, 'Notifications',
        playSound: true,
        enableLights: true,
        color: PrimaryColor,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    var DarwinPlatformChannelSpecifics = new DarwinNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinPlatformChannelSpecifics);
    if (scheduled != null && scheduled.length > 0) {
      var date = DateHelper.parse(scheduled);
      if (date != null && date.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            tz.TZDateTime.from(date, tz.local),
            platformChannelSpecifics,
            payload: payload,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
        );
      }
    } else {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload
      );
    }
  }

  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}

