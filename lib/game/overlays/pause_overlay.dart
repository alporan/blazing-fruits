import 'package:flutter/material.dart';
import '../blazing_game.dart';
import '../../constants.dart';

class PauseOverlay extends StatelessWidget {
  final BlazingGame game;
  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),
              _OverlayButton(
                label: 'RESUME',
                color: const Color(0xFF40C840),
                onTap: () {
                  game.resumeGame();
                },
              ),
              const SizedBox(height: 12),
              _OverlayButton(
                label: 'RESTART',
                color: const Color(0xFF4084E8),
                onTap: () {
                  game.overlays.remove(overlayPause);
                  game.restartGame();
                },
              ),
              const SizedBox(height: 12),
              _OverlayButton(
                label: 'HOME',
                color: const Color(0xFFE84040),
                onTap: () {
                  game.overlays.remove(overlayPause);
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
