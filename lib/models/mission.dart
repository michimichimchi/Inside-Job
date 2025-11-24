enum Difficulty {
  easy,
  hard,
}

class Mission {
  final String text;
  final Difficulty difficulty;

  const Mission({
    required this.text,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'difficulty': difficulty.toString().split('.').last,
    };
  }

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      text: json['text'] as String,
      difficulty: Difficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => Difficulty.easy,
      ),
    );
  }
}
