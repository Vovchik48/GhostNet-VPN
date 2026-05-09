import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vpn_service.dart';

class ServerListScreen extends StatelessWidget {
  const ServerListScreen({super.key});

  final List<Map<String, String>> servers = const [
    {'name': '🇷🇺 Москва (основной)', 'config': 'vless://ВАШ_UUID@111.88.159.225:443?...'},
    {'name': '🇷🇺 Москва (DNS)', 'config': 'vless://...замените на свой конфиг...'},
    {'name': '🇷🇺 Санкт-Петербург', 'config': 'vless://...замените на свой конфиг...'},
    {'name': '🇫🇮 Финляндия (WiFi)', 'config': 'vless://...замените на свой конфиг...'},
  ];

  @override
  Widget build(BuildContext context) {
    final vpn = context.read<VpnService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор сервера')),
      body: ListView.builder(
        itemCount: servers.length,
        itemBuilder: (context, index) {
          final server = servers[index];
          final configValid = server['config']?.startsWith('vless://') ?? false;
          return ListTile(
            title: Text(server['name']!),
            subtitle: configValid ? null : const Text('Конфиг не задан', style: TextStyle(color: Colors.redAccent)),
            trailing: vpn.currentServerName == server['name'] ? const Icon(Icons.check, color: Colors.green) : null,
            enabled: configValid,
            onTap: configValid
                ? () {
                    vpn.setServer(server['name']!, server['config']!);
                    Navigator.pop(context);
                  }
                : null,
          );
        },
      ),
    );
  }
}
