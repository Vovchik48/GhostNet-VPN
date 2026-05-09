import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vpn_service.dart';
import 'server_list.dart';
import 'subscription.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => VpnService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhostNet VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B68EE),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
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
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnService>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GhostNet',
                    style: GoogleFonts.raleway(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.shield, color: Color(0xFF7B68EE), size: 24),
                ],
              ),
              const SizedBox(height: 40),
              ListenableBuilder(
                listenable: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: vpn.isConnected ? 1.0 + _pulseController.value * 0.05 : 1.0,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: vpn.isConnected
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.shield,
                        size: 64,
                        color: vpn.isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                vpn.isConnected ? 'Защищён' : 'Не защищён',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: vpn.isConnected ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vpn.isConnected ? vpn.connectedTime : '00:00:00',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () async {
                  try {
                    if (vpn.isConnected) {
                      await vpn.disconnect();
                    } else {
                      await vpn.connect();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка подключения: $e')),
                      );
                    }
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: vpn.isConnected
                          ? [Colors.redAccent, Colors.red]
                          : [const Color(0xFF7B68EE), const Color(0xFF9B8EFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: vpn.isConnected
                            ? Colors.red.withOpacity(0.3)
                            : const Color(0xFF7B68EE).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.power_settings_new, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ServerListScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('Выбери сервер', style: TextStyle(color: Colors.white70)),
                      const Spacer(),
                      Text(vpn.currentServerName, style: const TextStyle(color: Colors.white)),
                      const Icon(Icons.chevron_right, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureChip('Kill Switch', vpn.killSwitch, (val) {
                    vpn.toggleKillSwitch(val);
                  }),
                  _buildFeatureChip('Split Tunnel', vpn.splitTunnel, (val) {
                    vpn.toggleSplitTunnel(val);
                  }),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B68EE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('💳 Приобрести подписку', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, bool enabled, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!enabled),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF7B68EE).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? const Color(0xFF7B68EE) : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? const Color(0xFF7B68EE) : Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
