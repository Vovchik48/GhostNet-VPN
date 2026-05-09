import 'dart:async';
import 'package:flutter/material.dart';

class VpnService extends ChangeNotifier {
  bool _isConnected = false;
  bool _isLoading = false;
  String _currentServerName = 'Москва (основной)';
  Timer? _timer;
  int _seconds = 0;
  bool _killSwitch = true;
  bool _splitTunnel = false;

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
    super.dispose();
  }

  Future<void> connect() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    // Имитация подключения (в будущем замените на реальный VPN-клиент)
    await Future.delayed(const Duration(seconds: 2));

    _timer?.cancel();
    _isConnected = true;
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      notifyListeners();
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _timer?.cancel();
    _seconds = 0;
    _isLoading = false;
    notifyListeners();
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
