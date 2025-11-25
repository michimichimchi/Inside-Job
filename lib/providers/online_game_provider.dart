import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/player.dart';
import '../models/mission.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../data/mission_data.dart';

class OnlineGameProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  String? _roomCode;
  String? _playerId;
  String _roomState = 'lobby'; // lobby, playing
  List<Player> _players = [];
  Player? _currentPlayer;
  StreamSubscription? _roomSubscription;

  String? get roomCode => _roomCode;
  String? get playerId => _playerId;
  String get roomState => _roomState;
  List<Player> get players => _players;
  Player? get currentPlayer => _currentPlayer;
  bool get isHost => _currentPlayer?.isHost ?? false;

  Future<void> init() async {
    final session = await _storageService.getSession();
    if (session != null) {
      _roomCode = session['roomCode'];
      _playerId = session['playerId'];
      _listenToRoom();
    }
  }

  Future<void> createRoom(String playerName) async {
    _roomCode = _generateRoomCode();
    _playerId = _uuid.v4();
    final host = Player(id: _playerId!, name: playerName);

    await _firebaseService.createRoom(_roomCode!, host);
    await _storageService.saveSession(_roomCode!, _playerId!);
    _listenToRoom();
  }

  Future<void> joinRoom(String code, String playerName) async {
    _roomCode = code.toUpperCase();
    _playerId = _uuid.v4();
    final player = Player(id: _playerId!, name: playerName);

    await _firebaseService.joinRoom(_roomCode!, player);
    await _storageService.saveSession(_roomCode!, _playerId!);
    _listenToRoom();
  }

  void _listenToRoom() {
    if (_roomCode == null) return;

    _roomSubscription?.cancel();
    _roomSubscription = _firebaseService.listenToRoom(_roomCode!).listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _roomState = data['state'] ?? 'lobby';
        
        // Room Timeout Check
        // Room Timeout Check
        if (data.containsKey('hostLeftAt')) {
          // If I am the host and I just reconnected (and I see hostLeftAt), 
          // it means I was gone. I should clear it to "reclaim" the room.
          if (isHost) {
             _firebaseService.clearHostDisconnectedAt(_roomCode!);
          } else {
            // I am a guest, check if host is gone too long
            final hostLeftAt = data['hostLeftAt'] as int;
            final now = DateTime.now().millisecondsSinceEpoch;
            // 3 minutes = 180,000 ms
            if (now - hostLeftAt > 180000) {
              // Timeout reached: Delete the room from Firebase so it doesn't persist.
              // We do this before leaving.
              _firebaseService.deleteRoom(_roomCode!).whenComplete(() {
                 leaveGame();
              });
              return;
            }
          }
        }
        
        final playersMap = Map<String, dynamic>.from(data['players'] ?? {});
        _players = playersMap.entries.map((e) {
          return Player.fromJson(Map<String, dynamic>.from(e.value));
        }).toList();
        
        // Sort players by join time (roughly, or just keep consistent order)
        // Ideally we'd have a timestamp, but for now just sorting by ID is deterministic
        _players.sort((a, b) => a.id.compareTo(b.id));

        try {
          _currentPlayer = _players.firstWhere((p) => p.id == _playerId);
        } catch (e) {
          // Player might have been removed or error
          _currentPlayer = null;
        }

        notifyListeners();
      } else {
        // Room does not exist anymore (deleted by host or timeout)
        leaveGame();
      }
    });
  }

  Future<void> startGame() async {
    if (_roomCode != null && isHost) {
      await _firebaseService.startGame(_roomCode!);
    }
  }

  Future<void> nextMission() async {
    if (_roomCode != null && _playerId != null) {
      // Reset status to active so they can pick a new mission
      await _firebaseService.updatePlayerStatus(_roomCode!, _playerId!, PlayerStatus.active, 0);
      
      // Clear current mission to force re-selection
      await _firebaseService.clearMission(_roomCode!, _playerId!);
    }
  }

  Future<void> selectDifficulty(Difficulty difficulty) async {
    if (_roomCode != null && _playerId != null) {
      final missions = difficulty == Difficulty.easy
          ? MissionData.easyMissions
          : MissionData.hardMissions;
      final mission = missions[Random().nextInt(missions.length)];
      
      await _firebaseService.assignMission(_roomCode!, _playerId!, mission);
    }
  }

  Future<void> reportResult(PlayerStatus status) async {
    if (_roomCode != null && _playerId != null && _currentPlayer != null) {
      int sips = 0;
      if (status == PlayerStatus.success) {
        sips = _currentPlayer!.currentMission!.difficulty == Difficulty.easy ? 2 : 4;
      } else if (status == PlayerStatus.failed) {
        // Caught or False Accusation (handled same for now, finish drink)
        sips = -1; // Special code for "Finish Drink"
      }
      
      await _firebaseService.updatePlayerStatus(_roomCode!, _playerId!, status, sips);
    }
  }

  Future<void> leaveGame() async {
    // 1. Stop listening immediately to avoid reacting to our own exit updates
    _roomSubscription?.cancel();
    _roomSubscription = null;

    final code = _roomCode;
    final pid = _playerId;
    final wasHost = isHost;

    // 2. Clear local session
    await _storageService.clearSession();
    _roomCode = null;
    _playerId = null;
    _players = [];
    _currentPlayer = null;
    notifyListeners();

    // 3. Perform Firebase operations if we were connected
    if (code != null && pid != null) {
      if (wasHost) {
        // Host leaving manually -> Trigger 3 minute timer (same as crash)
        await _firebaseService.setHostDisconnectedAt(code, pid);
      } else {
        // Guest leaving manually -> Remove self
        await _firebaseService.removePlayer(code, pid);
      }
    }
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
