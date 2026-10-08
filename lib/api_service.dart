import 'package:dio/dio.dart';

import 'api_user.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    ),
  );

  Future<List<ApiUser>> fetchUsers() async {
    final response = await _dio.get<List<dynamic>>('/users');
    final data = response.data;

    if (data == null) {
      throw const FormatException('Сервер вернул пустой ответ');
    }

    return data
        .map((item) => ApiUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  void dispose() {
    _dio.close(force: true);
  }
}
