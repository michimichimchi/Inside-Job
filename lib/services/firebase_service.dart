import 'package:firebase_core/firebase_core.dart'; // Neu hinzugefügt
import 'package:firebase_database/firebase_database.dart';
import '../models/player.dart';
import '../models/mission.dart';

class FirebaseService {
  // VORHER: final DatabaseReference _db = FirebaseDatabase.instance.ref();
  
  // NEU: Wir geben explizit die URL für den Server in Belgien an:
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://inside-job-f8677-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  Future<void> createRoom(String roomCode, Player host) async {
    await _db.child('rooms/$roomCode').set({
      'state': 'lobby',
      'players': {
        host.id: host.toJson(),
      },
    });
  }

  Future<void> joinRoom(String roomCode, Player player) async {
    final roomRef = _db.child('rooms/$roomCode');
    final snapshot = await roomRef.get();

    if (snapshot.exists) {
      await roomRef.child('players/${player.id}').set(player.toJson());
    } else {
      throw Exception('Room not found');
    }
  }

  Stream<DatabaseEvent> listenToRoom(String roomCode) {
    return _db.child('rooms/$roomCode').onValue;
  }

  Future<void> startGame(String roomCode) async {
    await _db.child('rooms/$roomCode/state').set('playing');
  }

  Future<void> updatePlayerStatus(String roomCode, String playerId, PlayerStatus status, int sips) async {
    await _db.child('rooms/$roomCode/players/$playerId').update({
      'status': status.toString().split('.').last,
      'sipsToGive': sips,
    });
  }

  Future<void> assignMission(String roomCode, String playerId, Mission mission) async {
    await _db.child('rooms/$roomCode/players/$playerId/currentMission').set(mission.toJson());
  }
}