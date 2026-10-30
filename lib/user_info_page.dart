import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Страница профиля: читает данные пользователя из Firebase Realtime Database
class UserInfoPage extends StatelessWidget {
  // Ключ пользователя в базе (например "-Nx8k3...")
  final String userId;

  const UserInfoPage({super.key, required this.userId});

  // Превращаем дату из базы в вид: 16.10.2026 11:25
  String _formatDate(String? iso) {
    final date = DateTime.tryParse(iso ?? '');
    if (date == null) return '-';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ссылка на конкретного пользователя: users/<userId>
    final userRef = FirebaseDatabase.instance.ref('users/$userId');

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
      ),

      // 2. StreamBuilder слушает базу: если данные изменятся в Firebase,
      //    экран обновится сам (поэтому база и называется Realtime)
      body: StreamBuilder<DatabaseEvent>(
        stream: userRef.onValue,
        builder: (context, snapshot) {
          // Ошибка (нет интернета, закрыты правила базы)
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          // Данные ещё загружаются
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Достаём данные из ответа базы
          final value = snapshot.data!.snapshot.value;
          if (value == null) {
            return const Center(child: Text('Пользователь не найден'));
          }
          final data = Map<String, dynamic>.from(value as Map);

          final name = (data['name'] ?? '').toString();
          final phone = (data['phone'] ?? '').toString();
          final email = (data['email'] ?? '').toString();
          final createdAt = _formatDate(data['createdAt']?.toString());

          // 4. Рисуем профиль
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Аватар с первой буквой имени
              Center(
                child: CircleAvatar(
                  radius: 48,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),

              // Карточка с данными
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text(name),
                      subtitle: const Text('Full Name'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.blue),
                      title: Text(phone),
                      subtitle: const Text('Phone Number'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(email),
                      subtitle: const Text('Email Address'),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.calendar_today, color: Colors.blue),
                      title: Text(createdAt),
                      subtitle: const Text('Registered at'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.key, color: Colors.blue),
                      title: Text(userId),
                      subtitle: const Text('Firebase ID'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Кнопка "Выйти" — возвращает на форму регистрации
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          );
        },
      ),
    );
  }
}