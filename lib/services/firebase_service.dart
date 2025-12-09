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
      'hostStatus': 'online',
      'players': {
        hostPlayer.id: hostPlayer.toJson(),
      },
    });
    
    // Dead Man's Switch: Alle Aktionen bei Verbindungsabbruch in EINEM Update zusammenfassen
    await _db.child('rooms/$roomCode').onDisconnect().update({
      'hostStatus': 'offline',
      'hostLeftAt': ServerValue.timestamp,
      'players/${hostPlayer.id}/status': 'offline',
    });
  }

  Future<void> joinRoom(String roomCode, Player player) async {
    final roomRef = _db.child('rooms/$roomCode');
    final snapshot = await roomRef.get();

    if (snapshot.exists) {
      // Ensure the joining player is not marked as host
      final guestPlayer = player.copyWith(isHost: false);
      await roomRef.child('players/${guestPlayer.id}').set(guestPlayer.toJson());
      
      // Setze Status auf offline, wenn die Verbindung abbricht
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

  Future<void> clearMission(String roomCode, String playerId) async {
    await _db.child('rooms/$roomCode/players/$playerId/currentMission').remove();
  }

  Future<void> removePlayer(String roomCode, String playerId) async {
    await _db.child('rooms/$roomCode/players/$playerId').remove();
  }

  Future<void> deleteRoom(String roomCode) async {
    await _db.child('rooms/$roomCode').remove();
  }

  Future<void> setHostDisconnectedAt(String roomCode, String hostId) async {
    await _db.child('rooms/$roomCode').update({
      'hostLeftAt': ServerValue.timestamp,
      'hostStatus': 'offline',
      'players/$hostId/status': 'offline',
    });
  }

  Future<void> clearHostDisconnectedAt(String roomCode) async {
    await _db.child('rooms/$roomCode/hostLeftAt').remove();
    await _db.child('rooms/$roomCode/hostStatus').set('online');
  }
}