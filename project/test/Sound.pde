import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.javasound.*;
import ddf.minim.spi.* ;

public class Sound {
  Minim minim;
  AudioPlayer song;
  FFT fft;
  MyBeatDetect beat;
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
    beat = new MyBeatDetect(samples.bufferSize(), samples.sampleRate());
    System.out.println(samples.sampleRate());
    beat.setSensitivity(10);
    //while(true){
    //  temp = new float[1024];
    //  //System.out.println(sampleRate);
    //  System.arraycopy(mix,i * sampleRate * 10,temp,0,1024);
    //  beat.detect(temp);
    //  //System.out.println(Arrays.toString(temp1));  
    //  if ( beat.isKick() ){
    //    println("beat");
    //  }
    //  i ++;
    //  if(i == 1000){
    //    break;
    //  }
    //} //<>//
    //BeatGenerator bg = new BeatGenerator(this);
    //Thread thread = new Thread(bg);
    //thread.start();
    analyzeUsingAudioSample();
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
  
  void analyzeUsingAudioSample()
{
   //AudioSample jingle = minim.loadSample("jingle.mp3", 2048);
   
  // get the left channel of the audio as a float array
  // getChannel is defined in the interface BuffereAudio, 
  // which also defines two constants to use as an argument
  // BufferedAudio.LEFT and BufferedAudio.RIGHT
  //float[] leftChannel = jingle.getChannel(AudioSample.LEFT);
  
  // then we create an array we'll copy sample data into for the FFT object
  // this should be as large as you want your FFT to be. generally speaking, 1024 is probably fine.
  int fftSize = 1024;
  float[] fftSamples = new float[fftSize];
  FFT fft = new FFT( fftSize, samples.sampleRate() );
  
  // now we'll analyze the samples in chunks
  int totalChunks = (mix.length / fftSize) + 1;
  
  // allocate a 2-dimentional array that will hold all of the spectrum data for all of the chunks.
  // the second dimension if fftSize/2 because the spectrum size is always half the number of samples analyzed.
  //spectra = new float[totalChunks][fftSize/2];
  
  for(int chunkIdx = 0; chunkIdx < totalChunks; ++chunkIdx)
  {
    int chunkStartIndex = chunkIdx * fftSize;
   
    // the chunk size will always be fftSize, except for the 
    // last chunk, which will be however many samples are left in source
    int chunkSize = min( mix.length - chunkStartIndex, fftSize );
   
    // copy first chunk into our analysis array
    arraycopy( mix, // source of the copy
               chunkStartIndex, // index to start in the source
               fftSamples, // destination of the copy
               0, // index to copy to
               chunkSize // how many samples to copy
              );
      
    // if the chunk was smaller than the fftSize, we need to pad the analysis buffer with zeroes        
    if ( chunkSize < fftSize )
    {
      // we use a system call for this
      Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0 );
    }
    
    // now analyze this buffer
    //fft.forward( fftSamples );
    beat.detect(fftSamples);
    if ( beat.isKick() ){
        println("beat");
    }
   
    // and copy the resulting spectrum into our spectra array
    //for(int i = 0; i < 512; ++i)
    //{
    //  spectra[chunkIdx][i] = fft.getBand(i);
    //}
  }
  
  samples.close(); 
}
}