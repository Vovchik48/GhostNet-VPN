import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vpn_service.dart';
import 'server_list.dart';
import 'subscription.dart';
import 'dart:math' as math;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => VpnService(),
      child: const GhostNetApp(),
    ),
  );
}

class GhostNetApp extends StatelessWidget {
  const GhostNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhostNet VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _pulseController;
  late AnimationController _mapController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _mapController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnService>();

    return Scaffold(
      body: Stack(
        children: [
          // Анимированная карта мира
          AnimatedWorldMap(controller: _mapController),

          // Градиентный оверлей
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.85),
                  Colors.black,
                ],
                stops: const [0.0, 0.2, 0.7, 1.0],
              ),
            ),
          ),

          // Основной контент
          SafeArea(
            child: Column(
              children: [
                // Верхняя панель
                _buildTopBar(),
                const Spacer(),
                // Таймер и статус
                _buildTimerSection(vpn),
                const SizedBox(height: 30),
                // Кнопка подключения
                _buildConnectButton(vpn),
                const SizedBox(height: 40),
                // Карточка сервера
                _buildServerCard(vpn),
                const Spacer(),
                // Переключатели
                _buildToggles(vpn),
                const SizedBox(height: 16),
                // Нижняя навигация
                _buildBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'GHOSTNET',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                ' VPN',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.share_outlined, color: Colors.white54, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(VpnService vpn) {
    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _ringController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(220, 220),
                    painter: vpn.isConnected
                        ? ConnectedRingPainter(
                            progress: _ringController.value,
                            color: const Color(0xFF00FF88),
                          )
                        : IdleRingPainter(
                            progress: _ringController.value,
                          ),
                  );
                },
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(
                    color: vpn.isConnected
                        ? const Color(0xFF00FF88).withOpacity(0.3)
                        : Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vpn.isConnected ? vpn.connectedTime : '00:00:00',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: vpn.isConnected ? const Color(0xFF00FF88) : Colors.white30,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        vpn.isConnected ? 'ЗАЩИЩЁН' : 'НЕ ЗАЩИЩЁН',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: vpn.isConnected ? const Color(0xFF00FF88) : Colors.white38,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectButton(VpnService vpn) {
    return GestureDetector(
      onTap: vpn.isLoading ? null : () async {
        try {
          if (vpn.isConnected) {
            await vpn.disconnect();
          } else {
            await vpn.connect();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка: $e'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: vpn.isConnected
                ? Colors.redAccent.withOpacity(0.6)
                : Colors.white.withOpacity(0.25),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30),
          color: vpn.isConnected ? Colors.redAccent.withOpacity(0.1) : Colors.transparent,
          boxShadow: vpn.isConnected
              ? [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: vpn.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                vpn.isConnected ? 'ОТКЛЮЧИТЬ' : 'ПОДКЛЮЧИТЬ',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: vpn.isConnected ? Colors.redAccent : Colors.white,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildServerCard(VpnService vpn) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ServerListScreen()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.public_outlined, color: Colors.white70, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выбери сервер',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vpn.currentServerName,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildToggles(VpnService vpn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildToggle(
            label: 'Kill Switch',
            enabled: vpn.killSwitch,
            onToggle: () => vpn.toggleKillSwitch(!vpn.killSwitch),
          ),
          _buildToggle(
            label: 'Адаптивное',
            enabled: vpn.splitTunnel,
            onToggle: () => vpn.toggleSplitTunnel(!vpn.splitTunnel),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String label,
    required bool enabled,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled ? const Color(0xFF00FF88) : Colors.white.withOpacity(0.15),
              boxShadow: enabled
                  ? [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                  : [],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.public_outlined, 'Серверы', false),
            _buildNavItem(Icons.home_rounded, 'Главная', true),
            _buildNavItem(Icons.settings_outlined, 'Настройки', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 44,
          decoration: active
              ? BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                )
              : null,
          child: Icon(icon, color: active ? Colors.white : Colors.white38, size: 22),
        ),
        if (active) const SizedBox(height: 4),
        if (active) Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54)),
      ],
    );
  }
}

// ... (остальные классы CustomPainter из вашего сообщения: AnimatedWorldMap, WorldMapPainter, ConnectedRingPainter, IdleRingPainter) ...
