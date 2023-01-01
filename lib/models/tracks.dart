import 'package:runningmusic/models/track.dart';

class Tracks {
  Tracks();
  static Set<Track> titles = {
    Track(80, '80bpm.mp3', 'Road to Nowhere - Ozzy Osbourne'),
    Track(90, '90bpm.mp3', 'Painkiller - Three Days Green'),
    Track(100, '100bpm.mp3', 'Runnin with the Devil - Van Halen'),
    Track(110, '110bpm.mp3', 'Walk this Way - Aerosmith'),
    Track(120, '120bpm.mp3', 'Rock n Roll Train AC/DC'),
    Track(130, '130bpm.mp3', 'Upspring - Muse'),
    Track(140, '140bpm.mp3', 'Born to be Wild - Steppenwolf'),
    Track(150, '150bpm.mp3', 'Run Around - Bluse Traveler'),
    Track(160, '160bpm.mp3', 'Paint it Black - The Rolling Stones'),
    Track(170, '170bpm.mp3', 'Free Falling - Tom Petty'),
    Track(180, '180bpm.mp3', 'Last Resort - Papa Roach'),
    Track(190, '190bpm.mp3', 'Wait for me - Rise Against'),
  };

  Track getTitleForBpm(int bpm) {
    for (var title in titles) {
      if (bpm <= title.bpm) {
        return title;
      }
    }
    return titles.last;
  }
}
