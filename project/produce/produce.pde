/**
 * Speed. 
 *
 * Use the Movie.speed() method to change
 * the playback speed.
 * 
 */

import processing.video.*;
import ddf.minim.*;

Movie mov;
BeatAnalyser beatAnalyser;
Minim minim;
int frameRate = 100; 

String filePath = "G:\\MultiMedia\\project\\video.mp4";
String audioPath = "G:\\MultiMedia\\project\\cry.mp3";
String beatPath = "G:\\MultiMedia\\project\\audio.txt";
String toBeatPath = "G:\\MultiMedia\\project\\beat2.txt";

int counter = 0;
int currentBeat = 0;
float speed = 0;

void setup() {
  size(800, 500);  
  background(0);
  minim = new Minim(this);
  beatAnalyser = new BeatAnalyser(beatPath,toBeatPath);
  mov = new Movie(this, filePath);
  mov.frameRate(100);
  AudioPlayer song = minim.loadFile(audioPath);
  song.play();
  mov.loop();
  frameRate(frameRate);
}

void movieEvent(Movie movie) {
  mov.read();  
}

void draw() {    
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
  image(mov, 0, 0,800,500);
   
  mov.speed(speed);
  
  fill(255);
  text(nfc(speed, 2) + "X", 10, 30); 
}  