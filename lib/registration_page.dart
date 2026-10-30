import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'notification_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  /// сохраняем пользователя и показываем уведомление
  Future<void> _register() async {
    // Проверяем, что поля заполнены правильно
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Берём "папку" users в Realtime Database
      final usersRef = FirebaseDatabase.instance.ref('users');

      //  push() создаёт новую запись с уникальным ключом, set() сохраняет данные
      await usersRef.push().set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      //  Данные сохранились — показываем уведомление об успехе
      await NotificationService.show(
        title: 'Регистрация успешна!',
        body: 'Добро пожаловать, ${_nameController.text.trim()}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные сохранены в Firebase')),
      );

      //  Очищаем форму
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
    } catch (e) {
      // Если что-то пошло не так (нет интернета, неверные правила базы)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    (value == null || !value.contains('@')) ? 'Неверный email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    (value == null || value.trim().length < 10) ? 'Неверный телефон' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Зарегистрироваться'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
