import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../data/mission_data.dart';

class GameProvider with ChangeNotifier {
  final List<String> _players = [];
  int _currentPlayerIndex = 0;
  Mission? _currentMission;
  String? _lastResultTitle;
  String? _lastResultDescription;

  List<String> get players => List.unmodifiable(_players);
  String get currentPlayerName => _players.isNotEmpty ? _players[_currentPlayerIndex] : '';
  Mission? get currentMission => _currentMission;
  String? get lastResultTitle => _lastResultTitle;
  String? get lastResultDescription => _lastResultDescription;

  void addPlayer(String name) {
    if (name.trim().isNotEmpty) {
      _players.add(name.trim());
      notifyListeners();
    }
  }

  void startGame() {
    _currentPlayerIndex = 0;
    _currentMission = null;
    notifyListeners();
  }

  void selectDifficulty(Difficulty difficulty) {
    final missions = difficulty == Difficulty.easy
        ? MissionData.easyMissions
        : MissionData.hardMissions;
    _currentMission = missions[Random().nextInt(missions.length)];
    notifyListeners();
  }

  void completeMission() {
    final sips = _currentMission?.difficulty == Difficulty.easy ? 2 : 4;
    _lastResultTitle = "MISSION SUCCESS!";
    _lastResultDescription = "Distribute $sips Sips!";
    notifyListeners();
  }

  void gotCaught() {
    _lastResultTitle = "YOU GOT CAUGHT!";
    _lastResultDescription = "FINISH YOUR DRINK!";
    notifyListeners();
  }

  void falseAccusation() {
    _lastResultTitle = "FALSE ACCUSATION!";
    _lastResultDescription = "THE ACCUSER MUST FINISH THEIR DRINK!";
    notifyListeners();
  }

  void nextTurn() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    _currentMission = null;
    _lastResultTitle = null;
    _lastResultDescription = null;
    notifyListeners();
  }
}
