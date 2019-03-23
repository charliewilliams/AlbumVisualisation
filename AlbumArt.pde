
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

import processing.pdf.*;

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
String[] keys = {"D", "Bbm", "Bm/D", "G", "Am", "E", "A", "Bbm", "Dm", "Bb"};
int[] roots = {2, 10, 11, 7, 9, 4, 9, 10, 2, 10};
int[] modes = {1, -1, 0, 1, -1, 1, 1, -1, -1, 1}; // -1 minor, 1 major, 0 mixed
float totalLengthMillis;
float radius;

ArrayList<Song>songs = new ArrayList<Song>();
PImage img;
PFont font;

boolean drawText = false;

PGraphics pg;
PGraphicsPDF pdf;

PGraphics pg_waveform, pg_waveform_pdf;
//PGraphics pg_waveforms;

void setup() {

  size(1024, 1024);
  pixelDensity(2);
  colorMode(HSB, 360, 100, 100, 100);
  noLoop();

  pg = createGraphics(width, height);
  pdf = (PGraphicsPDF)createGraphics(width * 2, height * 2, PDF, "render-art.pdf");
  pdf.ellipseMode(CENTER);
  pdf.rectMode(CENTER);

  pg_waveform = createGraphics(width * 2, height * 2);
  pg_waveform_pdf = createGraphics(width * 2, height * 2, PDF, "render-waveform.pdf");

  pg.smooth(4);
  pdf.smooth(4);

  //img = loadImage("waveform.png");
  font = createFont("EBGaramond-SemiBold.ttf", 12);

  radius = width * 0.3;
  int totalLength = 0;

  for (int i = 0; i < trackCount; i++) {

    Song s = new Song(titles[i], keys[i], roots[i], modes[i], nf(i + 1, 2) + ".json", trackLengthsSecs[i]);
    songs.add(s);
    totalLength += trackLengthsSecs[i];

    //println(s.title, s.noteCount, s.lengthMillis / 1000, trackLengthsSecs[i]);
  }

  totalLengthMillis = totalLength * 1000;
}

void drawTo(PGraphics p, PGraphics waveform) {

  p.colorMode(HSB, 360, 100, 100, 100);
  p.ellipseMode(CENTER);
  waveform.ellipseMode(CENTER);

  //p.beginDraw();
  p.background(0);
  p.translate(width / 2, height / 2);

  if (font != null) {
    p.textFont(font);
  }
  //textMode(CENTER);

  float startAngle = -PI/2;
  float hueAngle = 0;
  float hueIncr = 90;
  float wrapIncr = 45;

  int idx = 0;
  int startTimeMillis = 0;

  for (Song s : songs) {

    idx++;

    // draw a line to demarcate the start of the song
    p.noFill();
    p.strokeWeight(0.5);
    p.stroke(200);
    PVector end = new PVector(radius * cos(startAngle), radius * sin(startAngle));
    p.line(0, 0, end.x, end.y);

    // put the title on at the end of the line
    p.pushMatrix();
    p.translate(end.x, end.y);

    float offset = 0;
    String title = s.title; //.toUpperCase();
    String startTimeString = timeFormat(startTimeMillis);

    if (startAngle > PI / 2) { // 180°
      offset = p.textWidth(s.title) + 12; // whyyyyyy
      p.rotate(PI + startAngle);
    } else {
      p.rotate(startAngle);
    }

    p.fill(150);

    // track start time
    if (drawText) {
      p.textSize(12);
      p.text(title, 5 - offset, 0);
      p.text(startTimeString, 5 - offset, p.textDescent() + p.textAscent());
    }
    startTimeMillis += s.lengthMillis;

    p.popMatrix();

    // draw an arc
    float angle = angleForSong(s);
    //noStroke();
    p.fill(hueAngle, 100, 100, 10);
    //fill(random(255), random(255), random(255), 10);
    float outer = radius * 1.95;
    float inner = radius * 0.35;
    p.arc(0, 0, outer, outer, startAngle, startAngle + angle, PIE);

    if (idx == 1 && drawText) {
      // draw the title along the top of the arc
      p.fill(150);
      p.textSize(10);
      drawCurved(s.title.toUpperCase(), startAngle, startAngle + angle);
    }

    // put all the notes in the arc as mini-arcs
    p.noFill();

    for (Float startTime : s.timestamps) {

      Note n = s.notes.get(startTime);

      float weight = map(n.velocity, 0, 1, 0.25, 5);
      p.strokeWeight(weight);

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

      p.stroke(hueAngle + hueOffset, sat, bri, 100);

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

      p.line(notePos.x, notePos.y, noteEnd.x, noteEnd.y);
    }

    if (img == null) {
      // draw the song's waveform
      p.endDraw();
      waveform.beginDraw();
      drawWaveform(waveform, nf(idx, 2) + ".mp3", startAngle, startAngle + angle);
      waveform.endDraw();
      p.beginDraw();
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

  waveform.beginDraw();
  waveform.dispose();
  waveform.endDraw();

  //p.endDraw();

  if (img != null) {
    p.imageMode(CENTER);
    p.image(img, 0, 0, p.width, p.height);
  }
}

void draw() {

  pg.beginDraw();
  drawTo(pg, pg_waveform);
  pg.endDraw();
  pg.save("render.png");

  pdf.beginDraw();
  drawTo(pdf, pg_waveform_pdf);
  pdf.dispose();
  pdf.endDraw();
  //pdf.save("render.pdf");

  //pg_waveform.save("data/waveform.png");
  //pg_waveform_pdf.save("data/waveform.pdf");

  image(pg, 0, 0);
  saveFrame("output.png");
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

  return nf(min) + ":" + nf(sec, 2);
}
