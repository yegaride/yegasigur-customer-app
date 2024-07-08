// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:http/http.dart' as http;

class SendNotification {
  static var SERVER_KEY =
      "AAAA49ziIwY:APA91bHsBmmwutFQp_xt0bDHVKl78VgOk4rJwu4vU58XadwIDbogGebcH9FJ8DHkRuDjhee0Sth_TDbVsoAbAL66wz49meP9trIi6OcoEGvm0eWddxdGMp9DEmT1ejEAWb6BcTYlItLs";

  static sendMessageNotification(String token, String title, String body, Map<String, dynamic>? payload) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$SERVER_KEY',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': payload ?? <String, dynamic>{},
          'to': token
        },
      ),
    );
  }
}
