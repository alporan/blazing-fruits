import 'package:flutter/material.dart';
import '../blazing_game.dart';
import '../../constants.dart';

class GameOverOverlay extends StatelessWidget {
  final BlazingGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE84040), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Color(0xFFE84040),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                game.scoreManager.score.toString().padLeft(6, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'SCORE',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 3,
                ),
              ),
              if (game.isNewHighScore) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDD00).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFDD00), width: 1),
                  ),
                  child: const Text(
                    '🏆 NEW HIGH SCORE',
                    style: TextStyle(
                      color: Color(0xFFFFDD00),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _OverlayButton(
                label: 'PLAY AGAIN',
                color: const Color(0xFF40C840),
                onTap: () {
                  game.overlays.remove(overlayGameOver);
                  game.restartGame();
                },
              ),
              const SizedBox(height: 12),
              _OverlayButton(
                label: 'HOME',
                color: const Color(0xFF4084E8),
                onTap: () {
                  game.overlays.remove(overlayGameOver);
                  game.goHome(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OverlayButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          side: BorderSide(color: color, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
