import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../providers/game_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _selectDifficulty(BuildContext context, Difficulty difficulty) {
    Provider.of<GameProvider>(context, listen: false).selectDifficulty(difficulty);
    Navigator.pushNamed(context, '/mission');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Inside Job')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "It's your turn,",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.currentPlayerName,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 48),
                  const Text("Choose your Mission:"),
                  const SizedBox(height: 24),
                  _DifficultyButton(
                    label: "EASY MISSION",
                    subLabel: "Reward: Distribute 2 Sips",
                    color: Colors.green,
                    onPressed: () => _selectDifficulty(context, Difficulty.easy),
                  ),
                  const SizedBox(height: 24),
                  _DifficultyButton(
                    label: "HARD MISSION",
                    subLabel: "Reward: Distribute 4 Sips",
                    color: Colors.red,
                    onPressed: () => _selectDifficulty(context, Difficulty.hard),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
