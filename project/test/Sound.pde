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
    fft = new FFT(song.bufferSize(), song.sampleRate());
  }
  
  public void recordkick(){
    beat = new BeatDetect(song.bufferSize(), song.sampleRate());
    beat.setSensitivity(300);  
    kickSize = snareSize = hatSize = 16;
    // make a new beat listener, so that we won't miss any buffers for the analysis
    //bl = new BeatListener(beat, song);  
    song.play();
    //song.skip( 100);
    //song.play();
    //for(int i = 0; i <= 10000; i ++){
    //  song.skip( 10);
    //  //song.play();
    //  beat.detect(song.mix);
    //  if(beat.isKick()) {
    //    System.out.println("beat");
    //  }else{
    //    //System.out.println("no");
    //  }
    //}
    System.out.println(song.position());
  }
  
}