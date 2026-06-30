import 'package:audioplayers/audioplayers.dart';

class MusicService {
  // 1. Singleton Pattern (ถูกต้องแล้ว)
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  // 2. ตัวเล่นเพลง
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  // ฟังก์ชันเริ่มเล่น (Start)
  Future<void> startMusic() async {
    // เช็คก่อนว่าเล่นอยู่ไหม ถ้ายังไม่เล่นค่อยเริ่ม
    if (!isPlaying) {
      try {
        await _player.setReleaseMode(ReleaseMode.loop); // เล่นวน
        await _player.setVolume(0.5); // ความดัง 50%
        // ระบุ path ให้ตรงกับ pubspec.yaml
        await _player.play(AssetSource('sounds/backgroundbar.mp3'));
        isPlaying = true;
      } catch (e) {
        print("Error playing music: $e");
      }
    }
  }

  // ฟังก์ชันหยุด (Stop)
  Future<void> stopMusic() async {
    if (isPlaying) {
      await _player.stop();
      isPlaying = false;
    }
  }

  // ฟังก์ชันสลับ เปิด/ปิด (Toggle) - เอาไว้ผูกกับปุ่มลำโพง
  Future<bool> toggleMusic() async {
    if (isPlaying) {
      await stopMusic();
    } else {
      await startMusic();
    }
    return isPlaying;
  }
}
