import 'package:flutter/material.dart';
import '../constants.dart';
import '../game/managers/score_manager.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _manager = ScoreManager();
  List<ScoreEntry> _scores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scores = await _manager.loadScores();
    if (mounted) {
      setState(() {
        _scores = scores;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white24))
          : _scores.isEmpty
              ? const Center(
                  child: Text(
                    'No scores yet.\nPlay your first game!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  itemCount: _scores.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (_, i) {
                    final entry = _scores[i];
                    final rank = i + 1;
                    final isTop3 = rank <= 3;
                    final rankEmoji = isTop3 ? ['🥇', '🥈', '🥉'][rank - 1] : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          // Rank
                          SizedBox(
                            width: 44,
                            child: isTop3
                                ? Text(
                                    rankEmoji!,
                                    style: const TextStyle(fontSize: 22),
                                  )
                                : Text(
                                    '$rank',
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          // Score
                          Expanded(
                            child: Text(
                              entry.score.toString().padLeft(6, '0'),
                              style: TextStyle(
                                color: isTop3
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: isTop3 ? 22 : 18,
                                fontWeight: isTop3
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          // Date
                          Text(
                            _formatDate(entry.date),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
