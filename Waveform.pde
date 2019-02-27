import ddf.minim.*;
Minim minim; 
AudioSample sound; 

int stride = 16384;
PGraphics pg_waveform;

void drawWaveform(String name, float startAngle, float endAngle) {

  if (minim == null) {
    minim = new Minim(this);
  }

  if (pg_waveform == null) {
    pg_waveform = createGraphics(width, height);
  }

  float myRad = radius / 2;

  println(name);

  sound = minim.loadSample(name, 512);

  // Figure out how many pixels we have to play with
  float angleDelta = endAngle - startAngle;
  float arcLength = myRad * angleDelta;

  // Load
  float[] left = sound.getChannel(AudioSample.LEFT);
  float[] right = sound.getChannel(AudioSample.RIGHT);

  int pixelStride = 4;
  arcLength /= pixelStride;
  int stride = left.length / (int)arcLength;

  // Average / bin
  FloatList reducedL = new FloatList();
  float runningAverage = 0;

  for (int i = 0; i < left.length; i++) {
    runningAverage += abs(left[i]); // sample are low value so *1000
    if (i % stride == 0 && i!=0) { 
      reducedL.append(runningAverage / stride);
      runningAverage = 0;
    }
  }

  FloatList reducedR = new FloatList();
  for (int i = 0; i < right.length; i++) {
    runningAverage += abs(right[i]); // sample are low value so *1000
    if (i % stride == 0 && i!=0) { 
      reducedR.append(runningAverage / stride);
      runningAverage = 0;
    }
  }

  sound.close();

  // Draw
  stroke(255);
  //noFill();
  fill(200, 20);
  strokeWeight(0.5);

  float gain = 100;
  PShape shape = createShape();
  shape.beginShape();

  //shape.vertex(0, 0);

  //println(reducedL.size());

  for (int i = 0; i < reducedL.size(); i++) {
    float angle = startAngle + map(i, 0, reducedL.size(), 0, angleDelta);
    float mult = myRad + reducedL.get(i) * gain;
    float x = mult * cos(angle);
    float y = mult * sin(angle);
    shape.vertex(x, y);
  }

  for (int i = reducedR.size() - 1; i >= 0; i--) {
    float angle = startAngle + map(i, 0, reducedL.size(), 0, angleDelta);
    float mult = myRad - reducedR.get(i) * gain;
    float x = mult * cos(angle);
    float y = mult * sin(angle);
    shape.vertex(x, y);
  }

  shape.endShape(CLOSE);

  pg_waveform.beginDraw();
  pg_waveform.pushMatrix();
  pg_waveform.translate(width/2, height/2);
  pg_waveform.colorMode(HSB, 360, 100, 100, 100);
  pg_waveform.shape(shape);
  pg_waveform.popMatrix();
  pg_waveform.endDraw();

  pg_waveform.save("data/waveform.png");

  shape(shape);
}
