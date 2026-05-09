import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VpnService extends ChangeNotifier {
  bool _isConnected = false;
  bool _isLoading = false;
  String _currentServerName = 'Москва (основной)';
  Timer? _timer;
  int _seconds = 0;
  bool _killSwitch = true;
  bool _splitTunnel = false;
  Process? _xrayProcess;

  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get currentServerName => _currentServerName;
  String get connectedTime {
    int h = _seconds ~/ 3600;
    int m = (_seconds % 3600) ~/ 60;
    int s = _seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  bool get killSwitch => _killSwitch;
  bool get splitTunnel => _splitTunnel;

  @override
  void dispose() {
    _timer?.cancel();
    _xrayProcess?.kill();
    super.dispose();
  }

  Future<String> _fetchConfig() async {
    final response = await http
        .get(Uri.parse('http://111.88.159.225:5000/sub'))
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

  Future<void> connect() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final config = await _fetchConfig();
      
      // Копируем xray из assets/flutter_assets/assets/xray в доступную папку
      final appDir = Directory.systemTemp;
      final xrayPath = '${appDir.path}/xray';
      if (!File(xrayPath).existsSync()) {
        // Пытаемся найти бинарник в assets (путь зависит от Flutter)
        final possiblePaths = [
          'assets/xray',
          'flutter_assets/assets/xray',
        ];
        File? sourceFile;
        for (final path in possiblePaths) {
          final f = File(path);
          if (f.existsSync()) {
            sourceFile = f;
            break;
          }
        }
        if (sourceFile != null) {
          await sourceFile.copy(xrayPath);
          await File(xrayPath).setExecutable(true);
        } else {
          throw Exception('Xray binary not found in assets');
        }
      }

      final configFile = File('${appDir.path}/config.json');
      final jsonConfig = _vlessToJson(config);
      await configFile.writeAsString(jsonEncode(jsonConfig));

      _xrayProcess = await Process.start(
        xrayPath,
        ['run', '-c', configFile.path],
      );

      _isConnected = true;
      _seconds = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _seconds++;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('VPN error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _xrayProcess?.kill();
    _xrayProcess = null;
    _isConnected = false;
    _timer?.cancel();
    _seconds = 0;
    notifyListeners();
  }

  Map<String, dynamic> _vlessToJson(String link) {
    final uri = Uri.parse(link);
    final params = uri.queryParameters;
    
    return {
      "inbounds": [
        {
          "port": 10808,
          "listen": "127.0.0.1",
          "protocol": "socks",
          "settings": {"udp": true}
        }
      ],
      "outbounds": [
        {
          "protocol": "vless",
          "settings": {
            "vnext": [
              {
                "address": uri.host,
                "port": uri.port,
                "users": [
                  {
                    "id": uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '',
                    "flow": params['flow'] ?? ''
                  }
                ]
              }
            ]
          },
          "streamSettings": {
            "network": params['type'] ?? 'tcp',
            "security": params['security'] ?? 'none',
            "realitySettings": {
              "serverName": params['sni'] ?? '',
              "publicKey": params['pbk'] ?? '',
              "shortId": params['sid'] ?? '',
              "fingerprint": params['fp'] ?? 'chrome'
            }
          }
        }
      ]
    };
  }

  void setServer(String name, String config) {
    _currentServerName = name;
    notifyListeners();
  }

  void toggleKillSwitch(bool val) {
    _killSwitch = val;
    notifyListeners();
  }

  void toggleSplitTunnel(bool val) {
    _splitTunnel = val;
    notifyListeners();
  }
}
