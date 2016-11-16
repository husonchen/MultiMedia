class Circle {



  float x = 0;                        // Specify global Variables
  float y = 0;
  float speedX = 4.5;                 // Standard speed of ball. 
  float speedY = 0.5;                 // Speed of ball on the Y axis (Falling Down)




  // Constructor 
  Circle(float posx, float posy) {      // posx & posy(position of x and y). Using FLOAT as i can control speed better.    

    x = posx;
    y = posy;                          // A way of being able to change position of the circle. I named them "POS" for position.
  }


  // Function
  void run() {                      // Building functions. The behaviour of the ellipse's will be all determined here. 
    display();  
    move();
    bounce();
    gravity();
  }

  void gravity() {              // Adds 0.2 to the Y axis. Making the Ellipse fall. 
    speedY += 0.2;
  }

  void bounce() {          // This part of the code will keep bal in the window.    
    if (x > width) {          // If X comes to the width boundary on X
      speedX = speedX * -1; // Will change from + to - which makes the ellipse appear like it is bounceing off the right wall.
    }
    if (x < 0) {
      speedX = speedX * -1; // Creating a wall on the left of the window
    }
    if (y > height) {
      speedY = speedY * -1; // Putting a roof on the window so balls cannot bounce out.
    }
    if (y < 0) {
      speedY = speedY * -1; // The floor of the window which balls will bounce off.
    }
  }

  void move() {          // Make the Circle move depending on speed.
    x += speedX;        // add asign ( x = x + x)
    y += speedY;
  }
  void display() {                                // When you click the mouse, the size of the ellipse will change.
    if (mousePressed == true) {
      ellipse(x, y, 40, 40); // Create an elippse      // Click and you will create an ellipse 40x40
    } 
    else if (mousePressed == false) {
      ellipse(x, y, 90, 90);                        // Let go and you will create an ellipse 90x90
    }
  }
}