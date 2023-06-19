import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/models/event_model.dart';

// External package
import 'package:cloud_functions/cloud_functions.dart';

class Push {
  static Future<void> notification(BuildContext context, EventModel model, {String topic = 'default'}) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'notification',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 5),
      ),
    );

    try {
      await callable.call(<String, dynamic>{
        'topic': foundation.kDebugMode ? 'debug' : 'default',
        'title': model.title,
        'subtitle': model.subtitle,
        'uuid': model.uuid,
        'model': 'event'
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERROR: $e'),
        ),
      );
    }
  }
}
