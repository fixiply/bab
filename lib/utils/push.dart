import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/models/event_model.dart';
import 'package:bab/utils/constants.dart';

// External package
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart';

class Push {
  static Future<void> send(EventModel model, {bool thisDevice = false}) async {
    if(thisDevice == false) {
      return;
    }
    try {
      String? token;
      if (thisDevice == true) {
        if (!Foundation.kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
          token = await FirebaseMessaging.instance.getAPNSToken();
        } else {
          FirebaseApp app = Firebase.apps.first;
          token = await FirebaseMessaging.instance.getToken(
              vapidKey: app.options.apiKey
          );
        }
        if (token == null) {
          throw new Exception('Unable to send FCM message, no token exists.');
        }
      }
      String jsonContent = await rootBundle.loadString('assets/data/service_account.json');
      final jsonFile = json.decode(jsonContent);
      final accountCredentials = ServiceAccountCredentials.fromJson(jsonFile);

      List<String> scopes = ["https://www.googleapis.com/auth/cloud-platform"];
      clientViaServiceAccount(accountCredentials, scopes).then((AuthClient client) async {
        var body = _notification(model, token: token);
        print('[$APP_NAME] Post request: $body');
        var response = await client.post(
          Uri.parse('https://fcm.googleapis.com/v1/projects/$PROJECT_ID/messages:send'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${client.credentials.accessToken}'
          },
          body: body,
        );
        if (response.statusCode != 200) {
          print('[$APP_NAME] Post ERROR: ${response.body}');
          throw new Exception(response.body);
        }
      });
    } catch (e) {
      throw new Exception(e.toString());
    }
  }

  static String _notification(EventModel model, {String? token}) {
    return jsonEncode({
      'message': {
        'token': token != null ? token : '/topics/${Foundation.kDebugMode ? NOTIFICATION_TOPIC_DEBUG : NOTIFICATION_TOPIC}',
        'notification': {
          'title': model.title,
          'body': model.subtitle,
        },
        'android':{
          'priority': 'normal',
          'notification': {
            'channel_id': channelId,
          },
        },
        'apns':{
          'headers': {
            'apns-priority': '5'
          }
        },
        'data': {
          'id': model.uuid
        },
      }
    });
  }
}
