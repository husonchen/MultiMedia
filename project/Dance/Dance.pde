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
String beatPath_prex = "G:\\MultiMedia\\project\\video_";
String toBeatPath_prex = "G:\\MultiMedia\\project\\audio_";
String micRecordPath = "G:\\MultiMedia\\project\\micrecord.wav";
int counter = 0;
int currentBeat = 0;
float speed = 0;

Minim minim;
Sound sound;

int frameRate = 100;

KickRecordStat recordKick = KickRecordStat.NONE;
FileOutputStream o=null;

Movie mov;
Util util;

Textlabel pro;
MicRecord micRecord = null;

int progress = 100;
BeatAnalyser beatAnalyser;
String currentBeatPath ;
String currentToBeatPath;
String currentMuiscPath;
int everageSpeed;

void setup() {
  size(800,500,P2D);
  noStroke();
smooth();
  frameRate(frameRate);
  
  minim = new Minim(this);
  sound = new Sound(minim);
  //playMovie();
  
  cp5 = new ControlP5(this);
  pro = cp5.addTextlabel("label0").setText("Progress:").setPosition(0, 15).setFont(createFont("Arial", 36)).setVisible(true);
  // create a new button with name 'buttonA'
  
  cp5.addButton("play")
     .setValue(0)
     .setPosition(700,50)
     .setSize(80,30)
     .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
          if(theEvent.getAction() == ControlP5.ACTION_RELEASED) {
            playMovie(videoPath,audioPath);
          }
        }
    })
    ;
    
    cp5.addButton("stop","stop")
     .setValue(0)
     .setPosition(700,100)
     .setSize(80,30)
     .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
          if(theEvent.getAction() == ControlP5.ACTION_RELEASED) {
            stopMovie();
          }
        }
    })
    ;
   cp5.addButton("select video")
     .setValue(0)
     .setPosition(700,150)
     .setSize(80,30)
     .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
            if(theEvent.getAction() == ControlP5.ACTION_RELEASED) {
                selectInput("Select video file:", "generateVideo");
            }
        }
    })
    ;
  cp5.addButton("change music")
     .setValue(0)
     .setPosition(700,200)
     .setSize(80,30)
     .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
          if(theEvent.getAction() == ControlP5.ACTION_RELEASED) {
            selectInput("Select video file:", "changeMusic");
          }
        }
    })
    ;
    
  cp5.addButton("Use mic")
     .setValue(0)
     .setPosition(700,250)
     .setSize(80,30)
     .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
          if(theEvent.getAction() == ControlP5.ACTION_RELEASED) {
            BeatAnalyser beatAnalyse = new BeatAnalyser();
            everageSpeed = beatAnalyse.getAverageBeatTime(currentBeatPath);
            println("everageSpeed:"+everageSpeed);
            micRecord = new MicRecord(minim);
            recordKick = KickRecordStat.MICRECORDING;
            if(sound.song != null){
              sound.song.close();
            }
          }
        }
    })
    ;
}

void draw() {
  if(progress != 100){
    pro.setText("Progress: "+ progress);
  }else{
    pro.setText("");
  }
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
    case NONE:
      if(mov != null)
        image(mov, 0, 0,700,490);
      break;
    case MICRECORDING:
      recordMic();
      break;
  }
  fill(255);
}

//public void controlEvent(ControlEvent theEvent) {
//  println(theEvent.getController().getName());
//}

public void generateVideo(File selection) {
  if(selection == null){
    return;
  }
  if(mov != null)
    mov.stop();
  if(sound.song != null)
    sound.song.close();
  println("Start to generte video");
  //sperate music and video
  command.sperateVideo(selection.getPath(),videoPath);
  println("Start to generte audio");
  command.sperateMusic(selection.getPath(),audioPath);
  //analyse the video beats
  println("end generate");
  currentBeatPath = beatPath_prex + Util.getMD5Checksum(audioPath) + ".txt";
  File videoBeatPath = new File(currentBeatPath);
  if(! videoBeatPath.exists()){
    try {  
     o = new FileOutputStream(currentBeatPath); 
    } catch (Exception e) {  
     // TODO: handle exception  
     e.printStackTrace();  
    }
    
    sound.loaddata(audioPath,1024);
    sound.recordkick();
    recordKick = KickRecordStat.RECORDING;
  }else{
    playMovie(videoPath,audioPath);
    recordKick = KickRecordStat.FINISHRECORD;
  }
}

public void playMovie(String videoPath,String audioPath){
  if(mov != null)
    mov.stop();
  if(sound.song != null)
    sound.song.close();
  mov = new Movie(this,videoPath);
  mov.frameRate(100);
  //mov = new Movie(this,videoPath);
  sound.loaddata(audioPath,1024);
  sound.song.play();
  mov.play();
  
}

public void changeMusic(File selection){
  if(selection == null){
    return;
  }
  currentMuiscPath = selection.getPath();
  if(mov != null)
    mov.stop();
  if(sound.song != null)
    sound.song.close();
  
  currentToBeatPath = toBeatPath_prex+ Util.getMD5Checksum(selection.getPath()) +".txt";
  File record = new File(currentToBeatPath);
  if(!record.exists()){
    println("Start to analyse audio");
    try {  
     o = new FileOutputStream(record); 
    } catch (Exception e) {  
     // TODO: handle exception  
     e.printStackTrace();  
    }

    sound = new Sound(minim);
    sound.loaddata(selection.getPath(),1024);
    sound.recordkick();
   
    recordKick = KickRecordStat.CONVERTTING;
  }else{
    println("already anaylse music");
    beatAnalyser = new BeatAnalyser(currentBeatPath,currentToBeatPath);
    recordKick = KickRecordStat.FINISHCONVERT;
    playMovie(videoPath,currentMuiscPath);
  }
  
}

void movieEvent(Movie movie) {
  mov.read();  
}

void recordingBeat(){
  if( !sound.song.isPlaying()){
      //once stop
      try{
        o.close();
      }catch(Exception e){
      }
      if(recordKick == KickRecordStat.RECORDING){
        recordKick = KickRecordStat.FINISHRECORD;
      }
      else if(recordKick == KickRecordStat.CONVERTTING){
        //start analyse the beat
        recordKick = KickRecordStat.FINISHCONVERT;
        beatAnalyser = new BeatAnalyser(currentBeatPath,currentToBeatPath);
      }
      playMovie(videoPath,currentMuiscPath);
      pro.setText("Progress: 100");
    }else{
      if ( sound.isKick() ){
        long now = System.currentTimeMillis();
        try {  
          o.write(String.valueOf(sound.song.position()).getBytes("GBK"));
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
    //already record music, now to play
      if(counter == 0){
        long originalBeatTime = beatAnalyser.beats1[currentBeat + 1] -  beatAnalyser.beats1[currentBeat];
        long toBeatTime = beatAnalyser.beats2[currentBeat + 1] -  beatAnalyser.beats2[currentBeat];
        speed = (float)originalBeatTime/toBeatTime;
        counter = frameRate * (int) toBeatTime / 1000;
        println(speed);
        currentBeat ++;
      }else{
        counter --;
      }
      image(mov, 0, 0,700,490);
   
  mov.speed(speed);
  
}

void stopMovie(){
  mov.pause();
  sound.song.pause();
  //if(micRecord != null){
  //  micRecord.recorder.endRecord();
  //  println( "Stop recording" );
  //  micRecord.recorder.save();
  //  println("Done saving");
  //}
}

void recordMic(){
  image(mov, 0, 0,700,490);
  if(micRecord == null){
    micRecord = new MicRecord(minim);
  }
  micRecord.recordMic();
  
}