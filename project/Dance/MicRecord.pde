class MicRecord{
  AudioInput audioIn;
  BeatDetect beat;
  long lastBeat = 0;
  long nowBeat = 0;
  float micSpeed = 0;
  boolean findBeat = false;
  Circle[] circleLots = new Circle [3];
  color c ;
  
  public MicRecord(Minim minim){
    System.out.println("Start record");
    int bufferSize = 4096;
    float sampleRate = 44100;
    audioIn = minim.getLineIn(Minim.STEREO, bufferSize, sampleRate);
    beat = new BeatDetect(bufferSize, sampleRate);
    beat.setSensitivity(1000); //in milliseconds
    beat.detectMode(BeatDetect.SOUND_ENERGY);
    
    // Initailize
    for ( int i = 0; i < 3; i ++) {                             // Building class. Size of the array. Use this to                   generate different elements (ellipse). Up to 20 at the one time.
      circleLots[i] = new Circle(300 + i* 100, 50); // Generate a random number each time the for   loop runs. i represents the number of elements in the array. i = 0
    // Generate at random positions across the x axis. Will change everytime the for loop runs.
    }
    c = color(random(255), random(255), random(255));
  }
  
  public void recordMic(){
    beat.detect(audioIn.mix);
    if(beat.isOnset()){
      c = color(random(255), random(255), random(255));
      fill(c);
      System.out.println("beat");
      findBeat = true;
      nowBeat = System.currentTimeMillis();
      if(lastBeat != 0){;
        long toBeatTime = nowBeat - lastBeat;
        micSpeed = (float)everageSpeed/toBeatTime;
        mov.speed(micSpeed);
        System.out.println(micSpeed);
      }
      ellipse(300, 50, 90, 90);
      lastBeat = nowBeat;
      //currentBeat ++;
    }else{
      fill( c);
      ellipse(300, 50, 40, 40);
    }
    
  }
  
  
}