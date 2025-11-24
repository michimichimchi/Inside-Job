import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/online_game_provider.dart';
import 'screens/start_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/gameplay_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // IMPORTANT: User must add google-services.json for this to work
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  
  runApp(const InsideJobOnlineApp());
}

class InsideJobOnlineApp extends StatelessWidget {
  const InsideJobOnlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnlineGameProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Inside Job Online',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
          colorScheme: ColorScheme.dark(
            primary: Colors.deepPurpleAccent,
            secondary: Colors.amber,
            surface: Colors.grey[900]!,
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const GameRouter(),
      ),
    );
  }
}

class GameRouter extends StatelessWidget {
  const GameRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlineGameProvider>(
      builder: (context, game, child) {
        // 1. Not in a room -> Start Screen
        if (game.roomCode == null) {
          return const StartScreen();
        }

        // 2. In a room, but game hasn't started -> Lobby
        if (game.roomState == 'lobby') {
          return const LobbyScreen();
        }

        // 3. Game started -> Gameplay Screen
        return const GameplayScreen();
      },
    );
  }
}
