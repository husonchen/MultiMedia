class BeatGenerator  implements Runnable{
  Sound sound;
  //float[] mix;
  
  public BeatGenerator(Sound sound){
    this.sound = sound;    
  }
  public void run() {
    while(true){
      temp = new float[1024];
      //System.out.println(sampleRate);
      System.arraycopy(sound.mix,i * sound.sampleRate * 10,temp,0,1024);
      sound.beat.detect(temp);
      //System.out.println(Arrays.toString(temp1));  
      if ( sound.beat.isKick() ){
        println("beat");
      }
      i ++;
      if(i == 1000){
        break;
      }
    }
  }
}