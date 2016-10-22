import processing.video.*;

Movie myMovie;
Minim minim;

String filePath = "G:\\MultiMedia\\project\\1.mp4";
String audioPath = "G:\\MultiMedia\\project\\audio.wav";
Sound sound;

void setup() {
  size(800, 500);
  myMovie = new Movie(this, filePath );
  Command c = new Command();
  //c.exeCmd("D:\\Program Files\\ffmpeg-3.1.4-win64-static\\bin\\ffmpeg -i "+filePath+" -ab 160k -ac 2 -ar 44100 -vn "+audioPath);
  //myMovie.play();
  minim = new Minim(this);
  sound = new Sound(minim);
  sound.loaddata("audio.wav");
}

void draw() {
  //tint(255, 20);
  //image(myMovie, 0, 0);
  //float newSpeed = map(mouseX, 0, width, 0.1, 2);
  //myMovie.speed(newSpeed);
  
  //fill(255);
  //text(nfc(newSpeed, 2) + "X", 10, 30); 
  
  background(0);
  // first perform a forward fft on one of song's buffers
  // I'm using the mix buffer
  //  but you can use any one you like
  sound.fft.forward(sound.song.mix);
 
  stroke(255, 0, 0, 128);
  // draw the spectrum as a series of vertical lines
  // I multiple the value of getBand by 4 
  // so that we can see the lines better
  for(int i = 0; i < sound.fft.specSize(); i++)
  {
    line(i, height, i, height - sound.fft.getBand(i)*4);
  }
  
  stroke(255);
  // we draw the waveform by connecting neighbor values with a line
  // we multiply each of the values by 50 
  // because the values in the buffers are normalized
  // this means that they have values between -1 and 1. 
  // If we don't scale them up our waveform 
  // will look more or less like a straight line.
  for(int i = 0; i < sound.song.bufferSize() - 1; i++)
  {
    line(i, 50 + sound.song.left.get(i)*50, i+1, 50 + sound.song.left.get(i+1)*50);
    line(i, 150 + sound.song.right.get(i)*50, i+1, 150 + sound.song.right.get(i+1)*50);
  }
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}