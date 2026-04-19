import 'package:flutter/material.dart';

// ── Lane configuration ────────────────────────────────────────────────────────
const int minLanes = 1;
const int maxLanes = 3;

// ── Fruit ─────────────────────────────────────────────────────────────────────
const double fruitSize = 60.0; // logical pixels, square bounding box
const double fruitSpeedInitial = 185.0; // px/sec at game start
const double fruitSpeedMax = 420.0; // px/sec cap
const double fruitSpeedPerBurn = 3; // px/sec added per successful burn

// ── Spawning ──────────────────────────────────────────────────────────────────
const double spawnIntervalInitial = 1.6; // seconds between spawns
const double spawnIntervalMin = 0.45; // floor

// ── Flamethrower ─────────────────────────────────────────────────────────────
const double flamethrowerDuration = 0.30;        // seconds flame animation lasts
const double flamethrowerYFraction = 0.85;       // Y position from top (world fraction)
const double flamethrowerImpactHalfHeight = 55.0; // half-height of impact zone (px)
const double flamethrowerCoreHeight = 14.0;       // height of bright core flame beam

// ── Scoring ───────────────────────────────────────────────────────────────────
const int pointsPerBurn = 10;

// ── Lives ─────────────────────────────────────────────────────────────────────
const int startingLives = 3;

// ── Leaderboard ───────────────────────────────────────────────────────────────
const int leaderboardMaxEntries = 10;
const String prefKeyScores = 'high_scores';

// ── Colors ────────────────────────────────────────────────────────────────────
// Index alignment is a contract: laneColors[i] == fruitColor for lane i
// Index 3 (blue) has no matching lane — blue fruits must always be burned.
const List<Color> laneColors = [
  Color(0xFF00E84B), // bright green  → lane 0
  Color(0xFFFFE000), // bright yellow → lane 1
  Color(0xFFFF2222), // bright red    → lane 2
  Color(0xFF3399FF), // bright blue   → no lane (always burn)
];

const Color bgColor = Color(0xFF0D0D0D);
const Color hudTextColor = Color(0xFFFFFFFF);
const Color dividerColor = Color(0x44FFFFFF);

// Lane background opacity (applied to laneColors[i])
const double laneBgOpacity = 0.55;

// ── Fruit emoji labels per lane (3 variants each, [laneIndex][variant]) ────────
const List<List<String>> laneFruitEmojis = [
  ['🍏', '🍐', '🥝'], // green lane
  ['🍋', '🍌', '🌽'], // yellow lane
  ['🍎', '🍓', '🍒'], // red lane
  ['🫐', '🫐', '🫐'], // blue — blueberry, always burn
];

// ── Particle burst ────────────────────────────────────────────────────────────
const int burnParticleCount = 14;
const double burnParticleLifetime = 0.4; // seconds
const double burnParticleSpeed = 120.0; // px/sec

// ── Overlay keys ──────────────────────────────────────────────────────────────
const String overlayPause = 'pause';
const String overlayGameOver = 'game_over';
