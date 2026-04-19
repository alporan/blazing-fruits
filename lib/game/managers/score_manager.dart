import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class ScoreEntry {
  final int score;
  final DateTime date;

  ScoreEntry({required this.score, required this.date});

  Map<String, dynamic> toJson() => {
        'score': score,
        'date': date.toIso8601String(),
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        score: json['score'] as int,
        date: DateTime.parse(json['date'] as String),
      );
}

class ScoreManager {
  // ── State ──────────────────────────────────────────────────────────────────
  int _score = 0;
  int _combo = 0;
  int _comboMultiplier = 1;

  // ── Streams ────────────────────────────────────────────────────────────────
  final _scoreController = StreamController<int>.broadcast();
  final _comboController = StreamController<int>.broadcast();

  Stream<int> get scoreStream => _scoreController.stream;
  Stream<int> get comboStream => _comboController.stream;

  // ── Getters ────────────────────────────────────────────────────────────────
  int get score => _score;
  int get combo => _combo;
  int get comboMultiplier => _comboMultiplier;

  // ── Scoring ────────────────────────────────────────────────────────────────
  void addPoints() {
    _combo++;
    _comboMultiplier =
        (1 + _combo ~/ pointsComboMultiplierStep).clamp(1, maxComboMultiplier);
    _score += pointsPerBurn * _comboMultiplier;
    _scoreController.add(_score);
    _comboController.add(_comboMultiplier);
  }

  void resetCombo() {
    _combo = 0;
    _comboMultiplier = 1;
    _comboController.add(_comboMultiplier);
  }

  void reset() {
    _score = 0;
    _combo = 0;
    _comboMultiplier = 1;
    _scoreController.add(_score);
    _comboController.add(_comboMultiplier);
  }

  // ── Persistence ────────────────────────────────────────────────────────────
  Future<List<ScoreEntry>> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(prefKeyScores) ?? [];
    final entries = <ScoreEntry>[];
    for (final s in raw) {
      try {
        entries.add(ScoreEntry.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // Skip corrupted entries
      }
    }
    return entries;
  }

  /// Saves current score to the leaderboard.
  /// Returns true if this score is the new #1 (or ties #1).
  Future<bool> saveScore() async {
    if (_score == 0) return false; // Don't pollute leaderboard with zero scores

    final entries = await loadScores();
    final newEntry = ScoreEntry(score: _score, date: DateTime.now());
    entries.add(newEntry);
    entries.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = entries.take(leaderboardMaxEntries).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      prefKeyScores,
      trimmed.map((e) => jsonEncode(e.toJson())).toList(),
    );

    // True only if new entry landed at rank 1 (first position after sort)
    return trimmed.isNotEmpty && trimmed.first.score == _score &&
        trimmed.first.date == newEntry.date;
  }

  void dispose() {
    _scoreController.close();
    _comboController.close();
  }
}
