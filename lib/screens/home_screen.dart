import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../constants.dart';
import '../game/blazing_game.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedLanes = 2;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    final game = BlazingGame(laneCount: _selectedLanes);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              GameWidget<BlazingGame>(
                game: game,
                overlayBuilderMap: BlazingGame.overlayBuilders(game),
              ),
              // Pause button
              Positioned(
                top: 8,
                right: 8,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white54, size: 28),
                    onPressed: () => game.pauseGame(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Logo / Title ──────────────────────────────────────────────
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Column(
                  children: [
                    Text(
                      '🔥',
                      style: TextStyle(fontSize: 64 * _glowAnim.value),
                    ),
                    const SizedBox(height: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFFDD00)],
                      ).createShader(bounds),
                      child: const Text(
                        'BLAZING\nFRUITS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // ── Lane selector ─────────────────────────────────────────────
              const Text(
                'SELECT LANES',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(maxLanes, (i) {
                  final lanes = i + 1;
                  final selected = lanes == _selectedLanes;
                  final color = laneColors[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLanes = lanes),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withOpacity(0.25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? color : Colors.white24,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$lanes',
                              style: TextStyle(
                                color: selected ? color : Colors.white38,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              lanes == 1 ? 'LANE' : 'LANES',
                              style: TextStyle(
                                color: selected ? color : Colors.white24,
                                fontSize: 9,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              // ── Play button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _startGame,
                  child: const Text(
                    'PLAY',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Leaderboard button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white12),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  ),
                  child: const Text(
                    'LEADERBOARD',
                    style: TextStyle(fontSize: 13, letterSpacing: 3),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ── How to play hint ──────────────────────────────────────────
              const Text(
                'Tap a lane to fire its laser.\nBurn fruits that DON\'T match the lane color.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
