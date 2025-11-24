import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/online_game_provider.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlineGameProvider>(
      builder: (context, game, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lobby'),
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => game.leaveGame(),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text("ROOM CODE", style: TextStyle(color: Colors.grey)),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: game.roomCode ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied!')),
                    );
                  },
                  child: Text(
                    game.roomCode ?? '...',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text("PLAYERS", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: game.players.length,
                    itemBuilder: (context, index) {
                      final player = game.players[index];
                      final isMe = player.id == game.playerId;
                      return Card(
                        color: isMe ? Colors.deepPurple.withOpacity(0.3) : null,
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(
                            player.name + (isMe ? " (You)" : ""),
                            style: TextStyle(
                              fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                if (game.isHost)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: game.players.length >= 2
                          ? () => game.startGame()
                          : null,
                      child: const Text('START GAME', style: TextStyle(fontSize: 20)),
                    ),
                  )
                else
                  const Text(
                    "Waiting for host to start...",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
