
class Note {

  Note(Integer num, Float vel, Float dur, Integer chan) {
    
    pitchClass = num % 12;
    octave = num / 12;
    pitch = num / 127.0;
    velocity = vel;
    duration = dur;
    freq = midiToFreq(num);
    name = noteNameFromNumber(num);
    channel = chan;
  }

  String description() {
    return name + " " + pitch + " " + velocity + " active: " + isActive;
  }

  /* Boring property boilerplate stuff */

  Boolean isActive;
  int pitchClass; // 0-11
  int octave;
  private Float pitch;
  private String name;
  private Float velocity; // normalized 0-1
  private Float duration; // seconds
  Float freq;
  private Integer channel;


  boolean isAccidental() {
    // json midi conversion calls all black keys sharps afaik
    // for our purposes (D home key) we call an "accidental" any black key except F# and C#.
    return name.charAt(1) == 'b' || (name.charAt(1) == '#' && name.charAt(0) != 'F' && name.charAt(0) != 'D');
  }

  /* Utility */

  private String noteNameFromNumber(int num) {
    int  nNote = num % 12;
    int  nOctave = num / 12;
    return noteNames[nNote] + (nOctave - 1);
  }

  private float midiToFreq(int note) {
    return (pow(2, ((note-69)/12.0)))*440;
  }
}

private static String[] noteNames = {"C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"};
