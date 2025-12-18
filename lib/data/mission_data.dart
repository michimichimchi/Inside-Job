import '../models/mission.dart';

class MissionData {
  static const List<Mission> easyMissions = [
    Mission(text: "Check your phone or watch 3 times within one minute and sigh quietly.", difficulty: Difficulty.easy),
    Mission(text: "Give a player a very specific compliment about their clothing (e.g. about the seams).", difficulty: Difficulty.easy),
    Mission(text: "Try to high-five a player. It counts if they accept.", difficulty: Difficulty.easy),
    Mission(text: "Raise your glass and say 'To hydration!', regardless of what you are drinking.", difficulty: Difficulty.easy),
    Mission(text: "Fit the word 'spoon' sensibly into a normal sentence.", difficulty: Difficulty.easy),
    Mission(text: "Mirror a gesture (e.g. scratching head) of other players 5 times immediately after they do it.", difficulty: Difficulty.easy),
    Mission(text: "Take a selfie with another player in the background without them posing.", difficulty: Difficulty.easy),
    Mission(text: "Enthusiastically agree with a player's opinion ('Oh yes, 100% agreed!').", difficulty: Difficulty.easy),
    Mission(text: "Address a person by their first name 3 times during a short conversation.", difficulty: Difficulty.easy),
    Mission(text: "Stretch extensively and yawn loudly as if you just woke up.", difficulty: Difficulty.easy),
  ];

  static const List<Mission> hardMissions = [
    Mission(text: "Answer a normal question exclusively by whispering.", difficulty: Difficulty.hard),
    Mission(text: "Speak about yourself in the third person for three sentences (e.g. 'John thinks that...').", difficulty: Difficulty.hard),
    Mission(text: "Stare at your conversation partner's forehead for at least 10 seconds, not into their eyes.", difficulty: Difficulty.hard),
    Mission(text: "Touch the floor in the middle of a conversation and then smell your fingers.", difficulty: Difficulty.hard),
    Mission(text: "Use a foreign word (like 'Bonjour' or 'Amigo') in three consecutive sentences.", difficulty: Difficulty.hard),
    Mission(text: "Swat wildly at a non-existent fly and complain about insects.", difficulty: Difficulty.hard),
    Mission(text: "Repeat the last word of your partner's sentence as a question.", difficulty: Difficulty.hard),
    Mission(text: "Ask someone with a serious face: 'Do you think all of this is actually real?'", difficulty: Difficulty.hard),
    Mission(text: "Laugh out loud for no reason and then say 'Sorry, I just remembered something funny'.", difficulty: Difficulty.hard),
    Mission(text: "Freeze completely in the middle of a movement for 5 seconds.", difficulty: Difficulty.hard),
  ];
}