import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants.dart';
import 'components/fruit.dart';
import 'components/lane.dart';
import 'components/hud.dart';
import 'managers/score_manager.dart';
import 'managers/life_manager.dart';
import 'managers/fruit_spawner.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/game_over_overlay.dart';

// Flame >=1.36: TapCallbacks self-registers MultiTapDispatcher on mount.
class BlazingGame extends FlameGame {
  // ── Configuration ─────────────────────────────────────────────────────────
  final int laneCount;

  // ── Managers ──────────────────────────────────────────────────────────────
  late final ScoreManager scoreManager;
  late final LifeManager lifeManager;
  late FruitSpawner _spawner;
  late HudComponent _hud;

  // ── Audio ─────────────────────────────────────────────────────────────────
  // Players are nullable. _audioReady gates all play() calls.
  // Individual _has* flags prevent playing files that are empty placeholders.
  AudioPlayer? _musicPlayer;
  AudioPlayer? _sfxLaser;
  AudioPlayer? _sfxBurn;
  AudioPlayer? _sfxLife;
  bool _audioReady = false;
  bool _hasMusic = false;
  bool _hasLaser = false;
  bool _hasBurn = false;
  bool _hasLife = false;

  // ── State ─────────────────────────────────────────────────────────────────
  bool isRunning = false;
  bool isNewHighScore = false;

  late StreamSubscription<void> _gameOverSub;

  BlazingGame({required this.laneCount});

  // ── Overlay builder map ────────────────────────────────────────────────────
  static Map<String, Widget Function(BuildContext, BlazingGame)>
      overlayBuilders(BlazingGame game) => {
            overlayPause: (ctx, g) => PauseOverlay(game: g),
            overlayGameOver: (ctx, g) => GameOverOverlay(game: g),
          };

  @override
  Color backgroundColor() => bgColor;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    scoreManager = ScoreManager();
    lifeManager = LifeManager();
    _gameOverSub =
        lifeManager.gameOverStream.listen((_) => _handleGameOver());

    await _initAudio();
    _buildLanes();
    _spawner = FruitSpawner(game: this, laneCount: laneCount);

    _hud = HudComponent(
      scoreManager: scoreManager,
      lifeManager: lifeManager,
    )..priority = 10;
    await add(_hud);

    _playMusic();
    isRunning = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isRunning) return;
    _spawner.update(dt);
  }

  // ── Lanes ─────────────────────────────────────────────────────────────────
  void _buildLanes() {
    final laneWidth = size.x / laneCount;
    for (int i = 0; i < laneCount; i++) {
      add(LaneComponent(
        laneIndex: i,
        laneCount: laneCount,
        laneSize: Vector2(laneWidth, size.y),
        lanePosition: Vector2(i * laneWidth, 0),
      ));
    }
  }

  // ── Audio ─────────────────────────────────────────────────────────────────
  /// Checks whether an asset file has non-zero content before playing it.
  /// Empty placeholder files (0 bytes) will crash audioplayers asynchronously.
  Future<bool> _assetHasContent(String assetPath) async {
    try {
      final data = await rootBundle.load('assets/$assetPath');
      return data.lengthInBytes > 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> _initAudio() async {
    try {
      _hasMusic = await _assetHasContent('audio/music_loop.mp3');
      _hasLaser = await _assetHasContent('audio/laser.wav');
      _hasBurn  = await _assetHasContent('audio/burn.wav');
      _hasLife  = await _assetHasContent('audio/life_lost.wav');

      _musicPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
      _sfxLaser   = AudioPlayer();
      _sfxBurn    = AudioPlayer();
      _sfxLife    = AudioPlayer();
      _audioReady = true;
    } catch (_) {
      _audioReady = false;
    }
  }

  void _playMusic() {
    if (!_audioReady || !_hasMusic) return;
    try {
      _musicPlayer?.play(AssetSource('audio/music_loop.mp3'), volume: 0.35);
    } catch (_) {}
  }

  void playSfxLaser() {
    if (!_audioReady || !_hasLaser) return;
    try { _sfxLaser?.play(AssetSource('audio/laser.wav'), volume: 0.7); }
    catch (_) {}
  }

  void playSfxBurn() {
    if (!_audioReady || !_hasBurn) return;
    try { _sfxBurn?.play(AssetSource('audio/burn.wav'), volume: 0.9); }
    catch (_) {}
  }

  void playSfxLifeLost() {
    if (!_audioReady || !_hasLife) return;
    try { _sfxLife?.play(AssetSource('audio/life_lost.wav'), volume: 1.0); }
    catch (_) {}
  }

  /// Called by flamethrower when a wrong-color fruit is burned.
  void onFruitBurned() {
    scoreManager.addPoints();
    _spawner.accelerate();
  }

  // ── Pause ─────────────────────────────────────────────────────────────────
  void pauseGame() {
    if (!isRunning) return;
    isRunning = false;
    _musicPlayer?.pause();
    pauseEngine();
    overlays.add(overlayPause);
  }

  // ── Game Over ─────────────────────────────────────────────────────────────
  Future<void> _handleGameOver() async {
    if (!isRunning) return;
    isRunning = false;
    _musicPlayer?.stop();
    pauseEngine();
    isNewHighScore = await scoreManager.saveScore();
    overlays.add(overlayGameOver);
  }

  // ── Restart ───────────────────────────────────────────────────────────────
  void restartGame() {
    final toRemove = children
        .where((c) => c is FruitComponent || c is ParticleSystemComponent)
        .toList();
    for (final c in toRemove) {
      c.removeFromParent();
    }
    scoreManager.reset();
    lifeManager.reset();
    _spawner.reset();
    isNewHighScore = false;
    isRunning = true;
    resumeEngine();
    _playMusic();
  }

  // ── Home ──────────────────────────────────────────────────────────────────
  void goHome(BuildContext context) {
    isRunning = false;
    _musicPlayer?.stop();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void onRemove() {
    _gameOverSub.cancel();
    scoreManager.dispose();
    lifeManager.dispose();
    _musicPlayer?.dispose();
    _sfxLaser?.dispose();
    _sfxBurn?.dispose();
    _sfxLife?.dispose();
    super.onRemove();
  }
}
