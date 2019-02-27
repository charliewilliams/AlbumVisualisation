
/*
01 The Sea Was Never Blue",
 02 Astronomia",
 03 Map and Territory",
 04 Eldridge",
 05 How to Actually Change Your Mind",
 06 Sailing the Farm",
 07 Hide and Seek",
 08 At the Violet Hour",
 09 Light from Other Days",
 10 The River's Tent is Broken",
 */

final int trackCount = 10;
int[] trackLengthsSecs = {496, 231, 403, 427, 128, 387, 268, 227, 214, 175};
String[] titles = {
  "The Sea Was Never Blue", 
  "Astronomia", 
  "Map and Territory", 
  "Eldridge", 
  "How to Actually Change Your Mind", 
  "Sailing the Farm", 
  "Hide and Seek", 
  "At the Violet Hour", 
  "Light from Other Days", 
  "The River's Tent is Broken", 
};
float totalLengthMillis;
float radius;

ArrayList<Song>songs = new ArrayList<Song>();
PImage img;

PGraphics pg_waveforms;

void setup() {
  size(1024, 1024);
  pixelDensity(2);
  colorMode(HSB, 360, 100, 100, 100);
  //size(1024, 1024, P2D);
  //size(1024, 1024, P3D);
  ellipseMode(CENTER);
  noLoop();
  smooth(4);

  img = loadImage("waveform.png");

  radius = width * 0.3;
  int totalLength = 0;

  for (int i = 0; i < trackCount; i++) {

    Song s = new Song(titles[i], nf(i + 1, 2) + ".json", trackLengthsSecs[i]);
    songs.add(s);
    totalLength += trackLengthsSecs[i];

    //println(s.title, s.noteCount, s.lengthMillis / 1000, trackLengthsSecs[i]);
  }

  totalLengthMillis = totalLength * 1000;
}

void draw() {

  background(0);
  translate(width / 2, height / 2);

  float startAngle = -PI/2;
  float hueAngle = 0;
  float hueIncr = 90;
  float wrapIncr = 45;

  int idx = 0;

  for (Song s : songs) {

    idx++;

    // draw a line to demarcate the start of the song
    noFill();
    strokeWeight(0.5);
    stroke(200);
    PVector end = new PVector(radius * cos(startAngle), radius * sin(startAngle));
    line(0, 0, end.x, end.y);

    // put the title on at the end of the line
    pushMatrix();
    translate(end.x, end.y);
    rotate(startAngle);
    fill(150);
    //text(s.title + " (" + timeFormat(s.lengthMillis) + ")", end.x, end.y);
    text(s.title, 5, 0);
    popMatrix();

    // draw an arc
    float angle = angleForSong(s);
    //noStroke();
    fill(hueAngle, 100, 100, 10);
    //fill(random(255), random(255), random(255), 10);
    float outer = radius * 1.8;
    float inner = radius * 0.35;
    arc(0, 0, outer, outer, startAngle, startAngle + angle, PIE);

    // put all the notes in the arc as mini-arcs
    noFill();

    for (Float startTime : s.timestamps) {

      Note n = s.notes.get(startTime);

      float weight = map(n.velocity, 0, 1, 0.25, 5);
      strokeWeight(weight);

      //stroke(random(255), random(255), random(255));
      float hueRandomness = 30;

      //hueAngle = map(n.pitchClass, 0, 11, 0, 360);
      //float hueOffset = map(n.channel, 0, 5, -50, 50) + random(-hueRandomness, hueRandomness);

      hueAngle = map(n.channel, 0, 11, 0, 360);
      float hueOffset = map(n.pitchClass, 0, 5, -20, 20) + random(-hueRandomness, hueRandomness);

      float satRandomness = 30;
      float sat = map(n.velocity, 0, 1, 20, 100) + random(-satRandomness, satRandomness);
      float briRandomness = 30;
      float bri = map(n.velocity, 0, 1, 20, 100) + random(-briRandomness, briRandomness);

      stroke(hueAngle + hueOffset, sat, bri, 40);

      float rad = map(n.pitch, 0, 1, inner * 0.75, outer * 0.65);
      float notePctThroughSong = (startTime * 1000) / s.lengthMillis;
      float noteStartAngle = startAngle + angle * notePctThroughSong;
      float noteDurationAsPctOfSong = (n.duration * 1000) / s.lengthMillis;
      float noteDurationAngle = noteStartAngle + angle * noteDurationAsPctOfSong;

      //println(notePctThroughSong, noteStartAngle, noteDurationAsPctOfSong, noteDurationAngle);

      //arc(0, 0, rad, rad, noteStartAngle, noteStartAngle + noteDurationAngle);

      PVector notePos = new PVector(rad * cos(noteStartAngle), rad * sin(noteStartAngle));
      PVector noteEnd = new PVector(rad * cos(noteDurationAngle), rad * sin(noteDurationAngle));
      //point(notePos.x, notePos.y);

      line(notePos.x, notePos.y, noteEnd.x, noteEnd.y);
    }

    if (img == null) {
      // draw the song's waveform
      drawWaveform(nf(idx, 2) + ".mp3", startAngle, startAngle + angle);
    }

    // increment startAngle for the next song
    startAngle += angle;

    hueAngle += hueIncr;

    if (hueAngle > 360) {
      hueAngle %= 360;
      hueAngle += wrapIncr;
      wrapIncr /= 2;
    }

    //return; // debug
  }

  if (img != null) {
    imageMode(CENTER);
    image(img, 0, 0, width, height);
  }

  saveFrame("output.jpg");
}

float angleForSong(Song s) {
  return 2 * PI * pctOfTotalForSong(s);
}

float pctOfTotalForSong(Song s) {
  return s.lengthMillis / totalLengthMillis;
}

String timeFormat(int millis) {

  int totalSecs = millis / 1000;
  int min = totalSecs / 60;
  int sec = totalSecs % 60;

  return nf(min) + ":" + nf(sec);
}
