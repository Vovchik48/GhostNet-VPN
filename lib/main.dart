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

// --------------- Animated World Map ---------------
class AnimatedWorldMap extends StatelessWidget {
  final AnimationController controller;
  const AnimatedWorldMap({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: WorldMapPainter(offset: controller.value),
        );
      },
    );
  }
}

class WorldMapPainter extends CustomPainter {
  final double offset;
  WorldMapPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const lineSpacing = 12.0;
    const dotSpacing = 6.0;
    final offsetY = offset * lineSpacing;

    for (var y = 0.0; y < size.height; y += lineSpacing) {
      final adjustedY = (y + offsetY) % size.height;
      var x = 0.0;
      while (x < size.width) {
        final segmentLength = _getSegmentLength(x, adjustedY, size);
        if (segmentLength > 0) {
          canvas.drawLine(
            Offset(x, adjustedY),
            Offset(x + segmentLength, adjustedY),
            paint,
          );
        }
        x += segmentLength + dotSpacing;
      }
    }

    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height * 0.4;

    for (var r = 80.0; r < math.max(size.width, size.height); r += 80.0) {
      canvas.drawCircle(Offset(centerX, centerY), r, ringPaint);
    }
  }

  double _getSegmentLength(double x, double y, Size size) {
    final noise = _pseudoRandom(x * 0.01, y * 0.01);
    final continentShape = _continentShape(x, y, size);
    if (continentShape > 0.3) {
      return 4.0 + noise * 8.0;
    }
    return 0.0;
  }

  double _pseudoRandom(double x, double y) {
    final n = math.sin(x * 12.9898 + y * 78.233) * 43758.5453;
    return n - n.floor();
  }

  double _continentShape(double x, double y, Size size) {
    final nx = x / size.width;
    final ny = y / size.height;
    var v = 0.0;
    v += _ellipse(nx, ny, 0.55, 0.35, 0.25, 0.15);
    v += _ellipse(nx, ny, 0.52, 0.55, 0.08, 0.15);
    v += _ellipse(nx, ny, 0.22, 0.3, 0.12, 0.12);
    v += _ellipse(nx, ny, 0.28, 0.6, 0.06, 0.12);
    v += _ellipse(nx, ny, 0.8, 0.65, 0.06, 0.04);
    return v.clamp(0.0, 1.0);
  }

  double _ellipse(double nx, double ny, double cx, double cy, double rx, double ry) {
    final dx = (nx - cx) / rx;
    final dy = (ny - cy) / ry;
    final dist = dx * dx + dy * dy;
    return dist < 1.0 ? 1.0 - dist : 0.0;
  }

  @override
  bool shouldRepaint(covariant WorldMapPainter oldDelegate) => true;
}

// --------------- Ring Painters ---------------
class ConnectedRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  ConnectedRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final bgPaint = Paint()
      ..color = color.withOpacity(0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    final pulsePaint = Paint()
      ..color = color.withOpacity(0.15 * (1 - progress))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius * (0.8 + progress * 0.2), pulsePaint);

    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = progress * math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    final dotX = center.dx + radius * math.cos(sweepAngle - math.pi / 2);
    final dotY = center.dy + radius * math.sin(sweepAngle - math.pi / 2);
    canvas.drawCircle(Offset(dotX, dotY), 4, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant ConnectedRingPainter oldDelegate) => true;
}

class IdleRingPainter extends CustomPainter {
  final double progress;
  IdleRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    final arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = math.pi * 0.3;
    final startAngle = progress * math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant IdleRingPainter oldDelegate) => true;
}
