import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyRoomCode = 'room_code';
  static const String _keyPlayerId = 'player_id';

  Future<void> saveSession(String roomCode, String playerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRoomCode, roomCode);
    await prefs.setString(_keyPlayerId, playerId);
  }

  Future<Map<String, String>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final roomCode = prefs.getString(_keyRoomCode);
    final playerId = prefs.getString(_keyPlayerId);

    if (roomCode != null && playerId != null) {
      return {
        'roomCode': roomCode,
        'playerId': playerId,
      };
    }
    return null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRoomCode);
    await prefs.remove(_keyPlayerId);
  }
}
