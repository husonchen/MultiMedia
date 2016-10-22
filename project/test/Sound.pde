import ddf.minim.*;
import ddf.minim.analysis.*;

public class Sound{
  Minim minim;
  AudioPlayer song;
  FFT fft;


  public Sound(Minim minim){
    this.minim = minim;
  }
  public void loaddata(String path){
    // this loads mysong.wav from the data folder
    song = minim.loadFile(path);
    song.play();
    fft = new FFT(song.bufferSize(), song.sampleRate());
  }
}