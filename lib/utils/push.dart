import 'dart:convert';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/models/event_model.dart';
import 'package:bab/utils/constants.dart';

// External package
import 'package:googleapis_auth/auth_io.dart';

class Push {
  static Future<void> send(EventModel model, {String topic = 'default'}) async {
    try {
      String jsonContent = await rootBundle.loadString('assets/data/service_account.json');
      final jsonFile = json.decode(jsonContent);
      final accountCredentials = ServiceAccountCredentials.fromJson(jsonFile);

      List<String> scopes = ["https://www.googleapis.com/auth/cloud-platform"];
      clientViaServiceAccount(accountCredentials, scopes).then((AuthClient client) async {
        var body = _notification(model, topic);
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

  static String _notification(EventModel model, String topic) {
    return jsonEncode({
      'message': {
        'token': '/topics/$topic',
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
          'id': model.uuid,
          'name': 'event'
        },
      }
    });
  }
}
