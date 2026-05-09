import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Замените на реальный URL вашего сервера подписки
  final String _subscriptionUrl = 'http://111.88.159.225:5000/sub';

  Future<String> fetchConfig() async {
    final response = await http
        .get(Uri.parse(_subscriptionUrl))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final lines = response.body.split('\n');
      return lines.firstWhere(
        (line) => line.startsWith('vless://'),
        orElse: () => throw Exception('Конфиг не найден'),
      );
    } else {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }
  }
}
