import '../models/mission.dart';

class MissionData {
  static const List<Mission> easyMissions = [
    Mission(text: "Touch your nose with your tongue.", difficulty: Difficulty.easy),
    Mission(text: "Speak in a whisper for the next round.", difficulty: Difficulty.easy),
    Mission(text: "Stand on one leg for 30 seconds.", difficulty: Difficulty.easy),
    Mission(text: "Compliment the person to your left.", difficulty: Difficulty.easy),
    Mission(text: "Do 5 jumping jacks.", difficulty: Difficulty.easy),
  ];

  static const List<Mission> hardMissions = [
    Mission(text: "Let the group go through your photo gallery for 1 minute.", difficulty: Difficulty.hard),
    Mission(text: "Send a risky text to a contact chosen by the group.", difficulty: Difficulty.hard),
    Mission(text: "Eat a spoonful of a condiment chosen by the group.", difficulty: Difficulty.hard),
    Mission(text: "Let the person to your right post a status on your social media.", difficulty: Difficulty.hard),
    Mission(text: "Call a random contact and sing 'Happy Birthday'.", difficulty: Difficulty.hard),
  ];
}
