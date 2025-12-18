import 'package:firebase_core/firebase_core.dart'; // Neu hinzugefügt
import 'package:firebase_database/firebase_database.dart';
import '../models/player.dart';
import '../models/mission.dart';

class FirebaseService {

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> createRoom(String roomCode, Player host) async {
    // Ensure the creator is marked as host
    final hostPlayer = host.copyWith(isHost: true);

    await _db.child('rooms/$roomCode').set({
      'state': 'lobby',
      'lastActivity': ServerValue.timestamp,
      'players': {
        hostPlayer.id: hostPlayer.toJson(),
      },
    });
    
    // Dead Man's Switch removed in favor of lastActivity timeout
  }

  Future<bool> doesRoomExist(String roomCode) async {
    final snapshot = await _db.child('rooms/$roomCode').get();
    return snapshot.exists;
  }

  Future<void> joinRoom(String roomCode, Player player) async {
    final roomRef = _db.child('rooms/$roomCode');
    final snapshot = await roomRef.get();

    if (snapshot.exists) {
      // Ensure the joining player is not marked as host
      final guestPlayer = player.copyWith(isHost: false);
      await roomRef.child('players/${guestPlayer.id}').set(guestPlayer.toJson());
      // Update activity to keep room alive
      await roomRef.update({'lastActivity': ServerValue.timestamp});
      
      // Setze Status auf offline, wenn die Verbindung abbricht (nur für Spieler Status, nicht Host/Raum)
      await roomRef.child('players/${guestPlayer.id}').onDisconnect().update({
        'status': 'offline',
      });
    } else {
      throw Exception('Room not found');
    }
  }

  Stream<DatabaseEvent> listenToRoom(String roomCode) {
    return _db.child('rooms/$roomCode').onValue;
  }

  Stream<bool> get connectedStream {
    return FirebaseDatabase.instance.ref('.info/connected').onValue.map((event) {
      return (event.snapshot.value as bool?) ?? false;
    });
  }

  Future<void> startGame(String roomCode) async {
    await _db.child('rooms/$roomCode').update({
      'state': 'playing',
      'lastActivity': ServerValue.timestamp,
    });
  }

  Future<void> updatePlayerStatus(String roomCode, String playerId, PlayerStatus status, int sips) async {
    await _db.child('rooms/$roomCode').update({
      'players/$playerId/status': status.toString().split('.').last,
      'players/$playerId/sipsToGive': sips,
      'lastActivity': ServerValue.timestamp,
    });
  }

  Future<void> assignMission(String roomCode, String playerId, Mission mission) async {
    await _db.child('rooms/$roomCode').update({
      'players/$playerId/currentMission': mission.toJson(),
      'lastActivity': ServerValue.timestamp,
    });
  }

  Future<void> clearMission(String roomCode, String playerId) async {
    await _db.child('rooms/$roomCode/players/$playerId/currentMission').remove();
    // No explicit activity update needed strictly here as it usually happens with assignMission, but good practice if needed.
    // Keeping it simple for now to avoid too many writes if not critical.
  }

  Future<void> removePlayer(String roomCode, String playerId) async {
    await _db.child('rooms/$roomCode/players/$playerId').remove();
  }

  Future<void> deleteRoom(String roomCode) async {
    await _db.child('rooms/$roomCode').remove();
  }


}