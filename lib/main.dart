import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/online_game_provider.dart';
import 'screens/start_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/gameplay_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
        Widget activeScreen;

        // Determine active screen
        if (game.roomCode == null) {
          activeScreen = const StartScreen();
        } else if (game.roomState == 'lobby') {
          activeScreen = const LobbyScreen();
        } else {
          activeScreen = const GameplayScreen();
        }

        return Stack(
          children: [
            activeScreen,
            // Connection Overlay
            if (!game.isConnected)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        "reconnecting...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
