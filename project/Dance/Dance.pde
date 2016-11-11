import controlP5.*;
import java.io.BufferedReader;  
import java.io.File;  
import java.io.FileOutputStream;  
import java.io.FileReader;  

import processing.video.*;

ControlP5 cp5;
int normal = 0xFFFFFFFF;
int highlighted = 0xFFFF9900;
Command command = new Command();
String videoPath = "G:\\MultiMedia\\project\\video.mp4";
String audioPath = "G:\\MultiMedia\\project\\audio.wav";
String beatPath = "G:\\MultiMedia\\project\\video.txt";
String toBeatPath = "G:\\MultiMedia\\project\\audio_";

Minim minim;
Sound sound;

int frameRate = 100;

KickRecordStat recordKick = KickRecordStat.FINISHRECORD;
long starttime;
FileOutputStream o=null;

Movie mov;
Util util;

Textlabel pro;

int progress = 100;

void setup() {
  size(800,500,P2D);
  noStroke();

  frameRate(frameRate);
  
  minim = new Minim(this);
  sound = new Sound(minim);
  playMovie();
  
  cp5 = new ControlP5(this);
  pro = cp5.addTextlabel("label0").setText("Progress:").setPosition(0, 15).setFont(createFont("Arial", 36)).setVisible(true);
  // create a new button with name 'buttonA'
  cp5.addButton("select video")
     .setValue(0)
     .setPosition(700,100)
     .setSize(80,30)
     .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
            if(theEvent.getAction() == ControlP5.ACTION_RELEASED) {
                selectInput("Select video file:", "generateVideo");
            }
        }
    })
    ;
  cp5.addButton("play")
     .setValue(0)
     .setPosition(700,50)
     .setSize(80,30)
     .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
          if(theEvent.getAction() == ControlP5.ACTION_RELEASED) {
            playMovie();
          }
        }
    })
    ;
   
  cp5.addButton("change music")
     .setValue(0)
     .setPosition(700,150)
     .setSize(80,30)
     .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
          if(theEvent.getAction() == ControlP5.ACTION_RELEASED) {
            selectInput("Select video file:", "changeMusic");
          }
        }
    })
    ;
}

void draw() {
  background(normal);
  switch (recordKick){
    case RECORDING:
      recordingBeat();
      break;
    case FINISHRECORD:
      image(mov, 0, 0,700,490);
      break;
    case CONVERTTING:
      recordingBeat();
      break;
    case FINISHCONVERT:
      playSpeedVideo();
      break;
  }
  fill(255);
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}

public void generateVideo(File selection) {
  if(selection == null){
    return;
  }
  println("Start to generte video");
  //sperate music and video
  command.sperateVideo(selection.getPath(),videoPath);
  println("Start to generte audio");
  command.sperateMusic(selection.getPath(),audioPath);
  //analyse the video beats
  println("end generate");
  try {  
   o = new FileOutputStream(beatPath); 
  } catch (Exception e) {  
   // TODO: handle exception  
   e.printStackTrace();  
  }
  
  sound.stop();
  mov.pause();
  sound = new Sound(minim);
  sound.loaddata(audioPath,1024);
  sound.recordkick();
  starttime = System.currentTimeMillis();
  recordKick = KickRecordStat.RECORDING;
}

public void playMovie(){
  mov = new Movie(this,videoPath);
  mov.frameRate(100);
  recordKick = KickRecordStat.FINISHRECORD;
  sound.stop();
  sound.loaddata(audioPath,1024);
  //mov = new Movie(this,videoPath);
  mov.play();
  sound.song.play();
  
}

public void changeMusic(File selection){
  if(selection == null){
    return;
  }
  println("Start to analyse audio");
  File record = new File(toBeatPath+ Util.getMD5Checksum(selection.getPath()) +".txt");
  if(!record.exists()){
    try {  
     o = new FileOutputStream(record); 
    } catch (Exception e) {  
     // TODO: handle exception  
     e.printStackTrace();  
    }

    sound.stop();
    mov.pause();
    sound = new Sound(minim);
    sound.loaddata(selection.getPath(),1024);
    sound.recordkick();
    starttime = System.currentTimeMillis();
    recordKick = KickRecordStat.CONVERTTING;
  }
  
}

void movieEvent(Movie movie) {
  mov.read();  
}

void recordingBeat(){
  if( !sound.song.isPlaying()){
      if(recordKick == KickRecordStat.RECORDING)
        recordKick = KickRecordStat.FINISHRECORD;
      else if(recordKick == KickRecordStat.CONVERTTING)
        recordKick = KickRecordStat.FINISHCONVERT;
      pro.setText("Progress: 100");
    }else{
      if ( sound.beat.isKick() ){
        long now = System.currentTimeMillis();
        try {  
          o.write(String.valueOf(now - starttime).getBytes("GBK"));
          o.write(String.valueOf(' ').getBytes("GBK"));
          o.flush();
        }catch (Exception e) {  
         // TODO: handle exception  
          e.printStackTrace();  
        }
      }
      pro.setText("Progress: "+frameRate * sound.song.length() / 100);
    }
}

void playSpeedVideo(){
  
}