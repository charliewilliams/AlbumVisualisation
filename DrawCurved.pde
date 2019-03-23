
void drawCurved(String message, float startAngle, float endAngle) {

  String text = " " + message + "   ";
  
  float textRadius = radius * 1.1;

  pushMatrix();

  float arc = (endAngle - startAngle) * textRadius;

  float naturalLength = textWidth(text);
  float spacing = arc / naturalLength;

  //translate(arc, 0);
  rotate(PI + startAngle);
  float pos = 0;

  // For every box
  for (int i = 0; i < text.length(); i ++ ) {

    // The character and its width
    char currentChar = text.charAt(i);
    // Instead of a constant width, we check the width of each character.
    float w = textWidth(currentChar); 
    // Each box is centered so we move half the width
    pos += spacing * w / 2; //w/2;

    // Angle in radians is the arclength divided by the radius
    // Starting on the left side of the circle by adding PI
    float theta = PI + pos / textRadius;

    pushMatrix();


    translate(textRadius * cos(theta), textRadius * sin(theta)); 
    // Rotate the box (rotation is offset by 90 degrees)
    rotate(theta + HALF_PI); 

    // Display the character
    text(currentChar, 0, 0);

    popMatrix();

    // Move halfway again
    pos += spacing * w / 2;
  }

  popMatrix();
}
