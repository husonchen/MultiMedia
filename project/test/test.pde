import processing.video.*;
import java.io.BufferedReader;  
import java.io.File;  
import java.io.FileOutputStream;  
import java.io.FileReader;  
import java.io.RandomAccessFile;

Movie myMovie;
MyMinim minim;

String filePath = "G:\\MultiMedia\\project\\1.mp4";
String audioPath = "G:\\MultiMedia\\project\\audio.wav";
String beatPath = "G:\\MultiMedia\\project\\audio.txt";
Sound sound;
float sum = 0 ;
int total = 0;
long starttime;
float average;
FileOutputStream o=null;

void setup() {
  size(800, 500);
  myMovie = new Movie(this, filePath );
  Command c = new Command();
  //c.exeCmd("D:\\Program Files\\ffmpeg-3.1.4-win64-static\\bin\\ffmpeg -i "+filePath+" -ab 160k -ac 2 -ar 44100 -vn "+audioPath);
  //myMovie.play();
  minim = new MyMinim(this);
  sound = new Sound(minim);
  sound.loaddata(audioPath,1024);
  sound.recordkick();
  frameRate(100);
  starttime = System.currentTimeMillis();
  
  RandomAccessFile mm=null;  
  boolean flag=false;  
    
  try {  
   o = new FileOutputStream(beatPath); 
  } catch (Exception e) {  
   // TODO: handle exception  
   e.printStackTrace();  
  }
}

void draw() {
  //sound.beat.detect(sound.song.mix);
  //if ( sound.beat.isKick() ){
  //  long now = System.currentTimeMillis();
  //  try {  
  //    o.write(String.valueOf(now - starttime).getBytes("GBK"));
  //    o.write(String.valueOf(' ').getBytes("GBK"));
  //    o.flush();
  //    println("beat");
  //  }catch (Exception e) {  
  //   // TODO: handle exception  
  //   e.printStackTrace();  
  //  }
  //}
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}