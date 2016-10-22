import processing.video.*;
Movie myMovie;

String filePath = "G:\\MultiMedia\\project\\1.mp4";
void setup() {
  size(800, 500);
  myMovie = new Movie(this, filePath );
  Command c = new Command();
  c.exeCmd("D:\\Program Files\\ffmpeg-3.1.4-win64-static\\bin\\ffmpeg -i "+filePath+" -ab 160k -ac 2 -ar 44100 -vn audio.wav");
  myMovie.play();
}

void draw() {
  //tint(255, 20);
  image(myMovie, 0, 0);
  float newSpeed = map(mouseX, 0, width, 0.1, 2);
  myMovie.speed(newSpeed);
  
  fill(255);
  text(nfc(newSpeed, 2) + "X", 10, 30); 
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}