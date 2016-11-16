import ddf.minim.*;
import ddf.minim.analysis.*;

public class Sound{
  Minim minim;
  AudioPlayer song;
  FFT fft;
  BeatDetect beat;
  BeatListener bl;

  float kickSize, snareSize, hatSize;

  public Sound(Minim minim){
    this.minim = minim;
  }
  
  public void loaddata(String path,int bufferSize){
    // this loads mysong.wav from the data folder
    song = minim.loadFile(path,bufferSize);
    //fft = new FFT(song.bufferSize(), song.sampleRate());
  }
  
  public void recordkick(){
    beat = new BeatDetect(song.bufferSize(), song.sampleRate());
    beat.setSensitivity(1000);  
    kickSize = snareSize = hatSize = 16;
    // make a new beat listener, so that we won't miss any buffers for the analysis
    //bl = new BeatListener(beat, song);  
    song.play();
  }
  
  public void stop(){
    if(song != null){
      song.pause();
    }
  }
  
  public boolean isKick(){
    beat.detect(song.mix);
    return beat.isKick();
  }
}