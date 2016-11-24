import processing.video.*;
import java.io.BufferedReader;  
import java.io.File;  
import java.io.FileOutputStream;  
import java.io.FileReader;  
import java.io.RandomAccessFile;
import java.util.Arrays;

Movie myMovie;
Minim minim;

String filePath = "G:\\MultiMedia\\project\\1.mp4";
String audioPath = "G:\\MultiMedia\\project\\audio.wav";
String beatPath = "G:\\MultiMedia\\project\\audio.txt";
Sound sound;
float sum = 0 ;
int total = 0;
long starttime;
float average;
FileOutputStream o=null;
int i = 0;
float[] temp;
BeatDetect beat;
AudioInput  audioIn;

void setup() {
  size(800, 500,P3D);
  smooth();
  myMovie = new Movie(this, filePath );
  myMovie.play();
  Command c = new Command();
  //c.exeCmd("D:\\Program Files\\ffmpeg-3.1.4-win64-static\\bin\\ffmpeg -i "+filePath+" -ab 160k -ac 2 -ar 44100 -vn "+audioPath);
  //myMovie.play();
  minim = new Minim(this);
  sound = new Sound(minim);
  sound.loaddata(audioPath,1024);
  sound.recordkick();
  frameRate(100);
  starttime = System.currentTimeMillis();
  
  RandomAccessFile mm=null;  
  boolean flag=false;  
  audioIn = minim.getLineIn(Minim.STEREO, 4096, 44100);
  beat = new BeatDetect(4096, 44100);
    beat.setSensitivity(1000); //in milliseconds
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
  //temp = new float[1024];
  //System.arraycopy(sound.mix,i*sound.sampleRate * 10,temp,0,1024);
  //sound.beat.detect(temp);
  //if ( sound.beat.isKick() ){
  //  println("beat");
  //  println(i);
    
  //}
  //if(i == 0)
  //  System.out.println(Arrays.toString(temp));  
  //i++;
  //if(frameCount==1){
  //  while(true){
  //      temp = new float[1024];
  //      //System.out.println(sampleRate);
  //      System.arraycopy(sound.mix,i * sound.sampleRate * 10,temp,0,1024);
  //      sound.beat.detect(temp);
  //      //System.out.println(Arrays.toString(temp1));  
  //      if ( sound.beat.isKick() ){
  //        println("beat");
  //      }
  //      i ++;
  //      if(i == 100){
  //        break;
  //      }
  //    }
  //}
  beat.detect(audioIn.mix);
    if(beat.isKick()){
      println("beat");
    }
    //image(myMovie, 0, 0,700,490);
    //fill( random(255), random(255), random(255));
    //ellipse(300, 50, 90, 90);
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}