import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../models/player.dart';
import '../providers/online_game_provider.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlineGameProvider>(
      builder: (context, game, child) {
        final player = game.currentPlayer;
        if (player == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return Scaffold(
          appBar: AppBar(
            title: Text('Inside Job (${game.roomCode})'),
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () async {
                  if (game.isHost) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Disconnect & Leave?'),
                        content: const Text(
                            'If you leave, the room will remain open for 3 minutes to allow reconnection. After that, it will be closed.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      game.leaveGame();
                    }
                  } else {
                    game.leaveGame();
                  }
                },
              ),
            ],
          ),
          body: _buildBody(context, game, player),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OnlineGameProvider game, Player player) {
    // State 3: Result (Success or Failed)
    if (player.status != PlayerStatus.active) {
      return _buildResultView(context, game, player);
    }

    // State 1: No Mission -> Select Difficulty
    if (player.currentMission == null) {
      return _buildDifficultySelection(context, game);
    }

    // State 2: Active Mission -> Show Mission & Actions
    return _buildMissionView(context, game, player.currentMission!);
  }

  Widget _buildDifficultySelection(BuildContext context, OnlineGameProvider game) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose your Path",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 48),
            _DifficultyButton(
              label: "EASY MISSION",
              subLabel: "Reward: Distribute 2 Sips",
              color: Colors.green,
              onPressed: () => game.selectDifficulty(Difficulty.easy),
            ),
            const SizedBox(height: 24),
            _DifficultyButton(
              label: "HARD MISSION",
              subLabel: "Reward: Distribute 4 Sips",
              color: Colors.red,
              onPressed: () => game.selectDifficulty(Difficulty.hard),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionView(BuildContext context, OnlineGameProvider game, Mission mission) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRevealed = !_isRevealed),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isRevealed ? Colors.grey[900] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isRevealed
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mission.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                mission.difficulty == Difficulty.easy
                                    ? "Reward: 2 Sips"
                                    : "Reward: 4 Sips",
                                style: const TextStyle(color: Colors.greenAccent),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app, size: 64, color: Colors.black54),
                              SizedBox(height: 16),
                              Text(
                                "TAP TO REVEAL",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_isRevealed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => game.reportResult(PlayerStatus.success),
                child: const Text("MISSION SUCCESS", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => game.reportResult(PlayerStatus.failed),
                    child: const Text("I GOT CAUGHT!", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => game.reportResult(PlayerStatus.failed),
                    child: const Text("FALSE ACCUSATION", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultView(BuildContext context, OnlineGameProvider game, Player player) {
    final isSuccess = player.status == PlayerStatus.success;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isSuccess ? "MISSION SUCCESS!" : "YOU FAILED!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
            ),
            const SizedBox(height: 32),
            Text(
              isSuccess
                  ? "Distribute ${player.sipsToGive} Sips!"
                  : "FINISH YOUR DRINK!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                onPressed: () => game.nextMission(),
                child: const Text("NEXT MISSION", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final String subLabel;
  final Color color;
  final VoidCallback onPressed;

  const _DifficultyButton({
    required this.label,
    required this.subLabel,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subLabel, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
