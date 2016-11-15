import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.javasound.*;
import ddf.minim.spi.* ;

public class Sound{
  MyMinim minim;
  AudioPlayer song;
  FFT fft;
  BeatDetect beat;
  BeatListener bl;
  String path;
  
  float kickSize, snareSize, hatSize;

  public Sound(MyMinim minim){
    this.minim = minim;
  }
  
  public void loaddata(String path,int bufferSize){
    // this loads mysong.wav from the data folder
    this.path = path;
    song = minim.loadFile(path,bufferSize);
    fft = new FFT(song.bufferSize(), song.sampleRate());
  }
  
  public void recordkick(){
    beat = new BeatDetect(song.bufferSize(), song.sampleRate());
    beat.setSensitivity(300);  
    kickSize = snareSize = hatSize = 16;
    // make a new beat listener, so that we won't miss any buffers for the analysis
    bl = new BeatListener(beat, song);  
    song.play();
    System.out.println(song.mix);
    //song.skip( 100);
    //song.play();
    //long totalbits = song.length() * song.sampleRate();
    int totalFrame = song.getMetaData().sampleFrameCount();
    song = minim.loadFile(path,totalFrame);
    System.out.println(song.mix.size());
    song.play();
    float[] mix = song.mix.toArray();
    System.out.println(mix[1000]); //<>//
  }
  
  public AudioPlayer loadFile(String filename, int bufferSize)
  {
    AudioPlayer player       = null;
    AudioRecordingStream rec   = mimp.getAudioRecordingStream( filename, bufferSize, false );
    if ( rec != null )
    {
      AudioFormat format   = rec.getFormat();
      AudioOut out     = mimp.getAudioOutput( format.getChannels(),
                             bufferSize, 
                             format.getSampleRate(),
                             format.getSampleSizeInBits() );
      
      if ( out != null )
      {
        player = new AudioPlayer( rec, out );
      }
      else
      {
        rec.close();
      }
    }
    
    if ( player != null )
    {
      addSource( player );
    }
    else
    {
      error( "Couldn't load the file " + filename );
    }
    
    return player;
  }
  
}