import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Замените на ваш реальный адрес подписки
  final String _subscriptionUrl = 'https://111.88.159.225:5000/sub?token=ваш_токен';

  Future<String> fetchConfig() async {
    final response = await http
        .get(Uri.parse(_subscriptionUrl))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final lines = response.body.split('\n');
      return lines.firstWhere(
        (line) => line.startsWith('vless://'),
        orElse: () => throw Exception('VLESS-конфигурация не найдена в ответе сервера'),
      );
    } else {
      throw Exception('Не удалось загрузить конфиг (код ${response.statusCode})');
    }
  }
}
