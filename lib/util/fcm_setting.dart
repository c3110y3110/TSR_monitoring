import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tsr_monitoring_app/util/constants.dart';

import '../firebase_options.dart';
//TODO 포그라운드 알림 구현 필요!!!
Future<String?> fcmSetting() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true
  );
  await messaging.requestPermission(
      alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true
  );
  await FirebaseMessaging.instance.subscribeToTopic(ANOMALY_EVENT);
  String? firebaseToken = await messaging.getToken();
  print('firebase token : $firebaseToken');
  return firebaseToken;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}