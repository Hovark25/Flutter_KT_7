import 'package:flutter/material.dart';

import 'api_service.dart';
import 'api_user.dart';

void main() {
  runApp(const UsersApp());
}

class UsersApp extends StatelessWidget {
  const UsersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пользователи',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const UsersScreen(),
    );
  }
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ApiUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _apiService.fetchUsers();
  }

  void _reloadUsers() {
    setState(() {
      _usersFuture = _apiService.fetchUsers();
    });
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiUser>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState != ConnectionState.done;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Пользователи'),
            actions: [
              IconButton(
                onPressed: isLoading ? null : _reloadUsers,
                tooltip: 'Обновить',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: _buildBody(snapshot, isLoading),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<ApiUser>> snapshot, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Не удалось загрузить пользователей\n',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _reloadUsers,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final users = snapshot.data ?? const <ApiUser>[];

    if (users.isEmpty) {
      return const Center(child: Text('Пользователей пока нет'));
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Почта: ${user.email}'),
                  const SizedBox(height: 4),
                  Text('Номер: ${user.id}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
