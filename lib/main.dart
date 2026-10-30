import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'notification_service.dart';
import 'registration_page.dart';

Future<void> main() async {
  // 1. Готовим Flutter к работе с плагинами до запуска приложения
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Подключаемся к Firebase (настройки берутся из google-services.json)
  await Firebase.initializeApp();

  // 3. Включаем уведомления (разрешение, токен, слушатель push)
  await NotificationService.init();

  // 4. Запускаем приложение
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegistrationPage(),
    );
  }
}