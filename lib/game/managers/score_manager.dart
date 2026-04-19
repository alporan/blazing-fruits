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

  // ── Streams ────────────────────────────────────────────────────────────────
  final _scoreController = StreamController<int>.broadcast();

  Stream<int> get scoreStream => _scoreController.stream;

  // ── Getters ────────────────────────────────────────────────────────────────
  int get score => _score;

  // ── Scoring ────────────────────────────────────────────────────────────────
  void addPoints() {
    _score += pointsPerBurn;
    _scoreController.add(_score);
  }

  void reset() {
    _score = 0;
    _scoreController.add(_score);
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
  }
}
