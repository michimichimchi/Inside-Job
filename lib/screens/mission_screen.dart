import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../providers/game_provider.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  bool _isRevealed = false;

  void _handleSuccess(BuildContext context) {
    Provider.of<GameProvider>(context, listen: false).completeMission();
    Navigator.pushReplacementNamed(context, '/result');
  }

  void _handleCaught(BuildContext context) {
    Provider.of<GameProvider>(context, listen: false).gotCaught();
    Navigator.pushReplacementNamed(context, '/result');
  }

  void _handleFalseAccusation(BuildContext context) {
    Provider.of<GameProvider>(context, listen: false).falseAccusation();
    Navigator.pushReplacementNamed(context, '/result');
  }

  @override
  Widget build(BuildContext context) {
    final mission = Provider.of<GameProvider>(context).currentMission;

    if (mission == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Secret Mission')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isRevealed = !_isRevealed;
                  });
                },
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
                                      ? "Reward: Distribute 2 Sips"
                                      : "Reward: Distribute 4 Sips",
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
                                Text("(Keep it secret!)", style: TextStyle(color: Colors.black54)),
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
                  onPressed: () => _handleSuccess(context),
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
                      onPressed: () => _handleCaught(context),
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
                      onPressed: () => _handleFalseAccusation(context),
                      child: const Text("FALSE ACCUSATION", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
