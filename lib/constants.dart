import 'package:flutter/material.dart';

// ── Lane configuration ────────────────────────────────────────────────────────
const int minLanes = 1;
const int maxLanes = 3;

// ── Fruit ─────────────────────────────────────────────────────────────────────
const double fruitSize = 60.0; // logical pixels, square bounding box
const double fruitSpeedInitial = 180.0; // px/sec at game start
const double fruitSpeedMax = 420.0; // px/sec cap
const double fruitSpeedIncrement = 12.0; // added every wave

// ── Spawning ──────────────────────────────────────────────────────────────────
const double spawnIntervalInitial = 1.6; // seconds between spawns
const double spawnIntervalMin = 0.45; // floor
const double spawnIntervalDecrement = 0.08; // per wave

// ── Wave ──────────────────────────────────────────────────────────────────────
const int fruitsPerWave = 10; // fruits before speed/interval step up

// ── Laser ─────────────────────────────────────────────────────────────────────
const double laserDuration = 0.25; // seconds laser is visible after tap
const double laserWidth = 12.0;
const double laserZoneFraction = 0.15; // bottom 15% of screen = laser zone

// ── Scoring ───────────────────────────────────────────────────────────────────
const int pointsPerBurn = 10;
const int pointsComboMultiplierStep = 5; // every N consecutive burns → +1x
const int maxComboMultiplier = 5;

// ── Lives ─────────────────────────────────────────────────────────────────────
const int startingLives = 3;

// ── Leaderboard ───────────────────────────────────────────────────────────────
const int leaderboardMaxEntries = 10;
const String prefKeyScores = 'high_scores';

// ── Colors ────────────────────────────────────────────────────────────────────
// Index alignment is a contract: laneColors[i] == fruitColor for lane i
const List<Color> laneColors = [
  Color(0xFFE84040), // red   → lane 0
  Color(0xFF4084E8), // blue  → lane 1
  Color(0xFF40C840), // green → lane 2
];

const Color bgColor = Color(0xFF0D0D0D);
const Color hudTextColor = Color(0xFFFFFFFF);
const Color dividerColor = Color(0x44FFFFFF);

// Lane background opacity (applied to laneColors[i])
const double laneBgOpacity = 0.35;

// ── Fruit emoji labels (rendered as text inside circle) ───────────────────────
const List<String> fruitEmojis = ['🍎', '🫐', '🍋'];

// ── Particle burst ────────────────────────────────────────────────────────────
const int burnParticleCount = 14;
const double burnParticleLifetime = 0.4; // seconds
const double burnParticleSpeed = 120.0; // px/sec

// ── Overlay keys ──────────────────────────────────────────────────────────────
const String overlayPause = 'pause';
const String overlayGameOver = 'game_over';
