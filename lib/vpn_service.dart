import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'api.dart';

class VpnService extends ChangeNotifier {
  final FlutterV2ray _v2ray = FlutterV2ray();
  bool _isConnected = false;
  String _config = '';
  String _currentServerName = 'Москва (основной)';
  Timer? _timer;
  int _seconds = 0;
  bool _killSwitch = true;
  bool _splitTunnel = false;

  bool get isConnected => _isConnected;
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
    super.dispose();
  }

  Future<void> connect() async {
    if (_config.isEmpty) {
      _config = await ApiService().fetchConfig();
    }
    try {
      await _v2ray.start(
        config: _config,
        onStatusChanged: (status) {
          if (status == V2RayStatus.connected) {
            _isConnected = true;
            _seconds = 0;
            _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
              _seconds++;
              notifyListeners();
            });
            notifyListeners();
          } else {
            _isConnected = false;
            _timer?.cancel();
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    await _v2ray.stop();
    _isConnected = false;
    _timer?.cancel();
    _seconds = 0;
    notifyListeners();
  }

  void setServer(String name, String config) {
    if (!config.startsWith('vless://')) {
      throw ArgumentError('Невалидный VLESS-конфиг');
    }
    _currentServerName = name;
    _config = config;
    if (_isConnected) {
      disconnect().then((_) => connect());
    }
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
