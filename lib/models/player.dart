import 'mission.dart';

enum PlayerStatus {
  active,
  success,
  failed,
}

class Player {
  final String id;
  final String name;
  final bool isHost;
  final PlayerStatus status;
  final Mission? currentMission;
  final int sipsToGive;

  const Player({
    required this.id,
    required this.name,
    this.isHost = false,
    this.status = PlayerStatus.active,
    this.currentMission,
    this.sipsToGive = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isHost': isHost,
      'status': status.toString().split('.').last,
      'currentMission': currentMission?.toJson(),
      'sipsToGive': sipsToGive,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      isHost: json['isHost'] as bool? ?? false,
      status: PlayerStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PlayerStatus.active,
      ),
      currentMission: json['currentMission'] != null
          ? Mission.fromJson(Map<String, dynamic>.from(json['currentMission']))
          : null,
      sipsToGive: json['sipsToGive'] as int? ?? 0,
    );
  }

  Player copyWith({
    String? id,
    String? name,
    bool? isHost,
    PlayerStatus? status,
    Mission? currentMission,
    int? sipsToGive,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isHost: isHost ?? this.isHost,
      status: status ?? this.status,
      currentMission: currentMission ?? this.currentMission,
      sipsToGive: sipsToGive ?? this.sipsToGive,
    );
  }
}
