import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.javasound.*;
import ddf.minim.spi.* ;

public class Sound {
  Minim minim;
  AudioPlayer song;
  FFT fft;
  BeatDetect beat;
  BeatListener bl;
  String path;
  float[] mix;
  AudioSample samples;
  int sampleRate;
  
  float kickSize, snareSize, hatSize;

  public Sound(Minim minim){
    this.minim = minim;
  }
  
  public void loaddata(String path,int bufferSize){
    // this loads mysong.wav from the data folder
    this.path = path;
    //song = minim.loadFile(path,bufferSize);
    samples = minim.loadSample(path,bufferSize);
    sampleRate = samples.getMetaData().sampleFrameCount() / samples.length();
    //fft = new FFT(song.bufferSize(), song.sampleRate());
  }
  
  public void recordkick(){
   
    kickSize = snareSize = hatSize = 16;
    // make a new beat listener, so that we won't miss any buffers for the analysis
    //bl = new BeatListener(beat, song);  
    //song.play();
    //System.out.println(song.mix);
    //song.skip( 100);
    //song.play();
    //long totalbits = song.length() * song.sampleRate();
    samples = minim.loadSample(path,1024);
    mix = mixStero(samples.getChannel(1),samples.getChannel(2));
    System.out.println(mix[11000000]);
    //for(int z = 0 ; z < mix.length; z++ ){
    //  if(mix[z] != 0){
    //    System.out.println(z);
    //    break;
    //  }
    //}
    System.out.println("a");
    //samples.trigger();
    beat = new BeatDetect(samples.bufferSize(), samples.sampleRate());
    System.out.println(samples.sampleRate());
    beat.setSensitivity(300);
    while(true){
      temp = new float[1024];
      //System.out.println(sampleRate);
      System.arraycopy(mix,i * sampleRate * 10,temp,0,1024);
      beat.detect(temp);
      //System.out.println(Arrays.toString(temp1));  
      if ( beat.isKick() ){
        println("beat");
      }
      i ++;
    } //<>//
  }
  
  public float[] mixStero(float[] b1, float[] b2)
  {
    float[] samples = new float[b1.length];
    if ((b1.length != b2.length)
        || (b1.length != samples.length || b2.length != samples.length))
    {
      Minim.error("MAudioBuffer.mix: The two passed buffers must be the same size as this MAudioBuffer.");
    }
    else
    {
      for (int i = 0; i < samples.length; i++)
      {
        samples[i] = (b1[i] + b2[i]) / 2;
      }
    }
  
  return samples;
  }
}