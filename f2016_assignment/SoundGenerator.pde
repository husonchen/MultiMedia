class SoundGenerator implements Runnable {
    private int samplingRate = 44100; // Number of samples used for 1 second of sound
    private int nyquistFrequency = samplingRate / 2; // Nyquist frequency

    private AudioSamples soundSamples;   // the sound samples (two channels)
    private int sound;
    private float amplitude = 1.0;
    private float frequency = 256;
    private float duration = 5;  // the duration of the sound to be generated (in seconds)

    private float minValue = -1.0;
    private float maxValue = 1.0;

    // Constructors
    SoundGenerator(int sound, float amplitude, float frequency, float duration, int samplingRate) {
        this.samplingRate = samplingRate;
        this.nyquistFrequency = samplingRate / 2;
        this.sound = sound;
        this.amplitude = amplitude;
        this.frequency = frequency;
        this.duration = duration;
        soundSamples = new AudioSamples(duration, samplingRate);
    }

    SoundGenerator(int sound, float amplitude, float frequency, float duration) {
        this.sound = sound;
        this.amplitude = amplitude;
        this.frequency = frequency;
        this.duration = duration;
        soundSamples = new AudioSamples(duration, samplingRate);
    }

    SoundGenerator(int sound, float amplitude, float frequency) {
        this.sound = sound;
        this.amplitude = amplitude;
        this.frequency = frequency;
        soundSamples = new AudioSamples(duration, samplingRate);
    }

    // This function is called when using thread
    public void run() {
        generateSound(sound, amplitude, frequency, duration);
    }

    // Setter and getter
    public void setSound(int sound) {
        this.sound = sound;
    }

    public int getSound() {
        return sound;
    }

    public void setAmp(float amplitude) {
        this.amplitude = amplitude;
    }

    public float getAmp() {
        return amplitude;
    }

    public void setFrequency(float frequency) {
        this.frequency = frequency;
    }

    public float getFrequency() {
        return frequency;
    }

    public AudioSamples getGeneratedSound() {
        return soundSamples;
    }

    // This function generates an individual sound, using the paramters passed into the constructor
    public AudioSamples generateSound() {
        return this.generateSound(sound, amplitude, frequency, duration);
    }

    public AudioSamples generateSound(int sound, float amplitude, float frequency) {
        return this.generateSound(sound, amplitude, frequency, duration);
    }

    // This function generates an individual sound
    public AudioSamples generateSound(int sound, float amplitude, float frequency, float duration) {
        // Reset audio samples before generating audio
        soundSamples.clear();

        switch(sound) {
            case (1): generateSineInTimeDomain(amplitude, frequency, duration); break;
            case (2): generateSquareInTimeDomain(amplitude, frequency, duration); break;
            case (3): generateSquareAdditiveSynthesis(amplitude, frequency, duration); break;
            case (4): generateSawtoothInTimeDomain(amplitude, frequency, duration); break;
            case (5): generateSawtoothAdditiveSynthesis(amplitude, frequency, duration); break;
            case (6): generateTriangleAdditiveSynthesis(amplitude, frequency, duration); break;
            case (7): generateBellFMSynthesis(amplitude, frequency, duration); break;
            case (8): generateKarplusStrongSound(amplitude, frequency, duration); break;
            case (9): generateWhiteNoise(amplitude, frequency, duration); break;
            case(10): generateFourSineWave(amplitude, frequency, duration); break;
            case(11): generateRepeatingNarrowPulse(amplitude, frequency, duration); break;
            case(12): generateTriangleInTimeDomain(amplitude, frequency, duration); break;
            case(13): generateSciFiSound(amplitude, frequency, duration); break;
            case(14): generateKarplusStrongSound2(amplitude, frequency, duration); break;
            case(15): generateAxB(1, 1, amplitude, frequency, duration); break;
            case(16): generateAxB(1, 5, amplitude, frequency, duration); break;
            case(17): generateAxB(1, 10, amplitude, frequency, duration); break;
            case(18): generateAxB(4, 4, amplitude, frequency, duration); break;
            case(19): generateAxB(5, 6, amplitude, frequency, duration); break;
            case(20): generateSound20(amplitude, frequency, duration); break; // You can add your own sound(s) if you want to
            case(21): generateSound21(amplitude, frequency, duration); break; // You can add your own sound(s) if you want to
            case(22): generateSound22(amplitude, frequency, duration); break; // You can add your own sound(s) if you want to
            case(23): generateSound23(amplitude, frequency, duration); break; // You can add your own sound(s) if you want to
            case(24): generateSound24(amplitude, frequency, duration); break; // You can add your own sound(s) if you want to
        }

        return soundSamples;
    }

    // This function generates a sine wave using the time domain method
    private void generateSineInTimeDomain(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float currentTime = float(i) / samplingRate;
            soundSamples.leftChannelSamples[i] = amplitude * sin(TWO_PI * frequency * currentTime);
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates a square wave -_-_ using the time domain method
    private void generateSquareInTimeDomain(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);
        float oneCycle = samplingRate / frequency;
        float halfCycle = oneCycle / 2;
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float whereInCycle = i % int(oneCycle);
            if (whereInCycle < halfCycle) {
                soundSamples.leftChannelSamples[i] = amplitude * maxValue;
                soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
            } else {
                soundSamples.leftChannelSamples[i] = amplitude * minValue;
                soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
            }
        }
    }

    // This function generates a square wave -_-_ using the additive synthesis method
    private void generateSquareAdditiveSynthesis(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);

        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float sampleValue = 0;
            float currentTime = float(i) / samplingRate;
            for(int wave = 1; wave * frequency < nyquistFrequency; wave += 2) {
                sampleValue += (1.0 / wave) * sin(wave * TWO_PI * frequency * currentTime);
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates a sawtooth wave /|/| using time domain method
    private void generateSawtoothInTimeDomain(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);
        float oneCycle = samplingRate / frequency;
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float sampleValue = int(i % oneCycle) / oneCycle * 2.0f - 1.0f;
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates a sawtooth wave \|\| using the additive synthesis method
    private void generateSawtoothAdditiveSynthesis(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);

        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float sampleValue = 0;
            float currentTime = float(i) / samplingRate;
            for(int wave = 1; wave * frequency < nyquistFrequency; wave += 1) {
                sampleValue += (1.0 / wave) * sin(wave * TWO_PI * frequency * currentTime);
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates a triangle wave \/\/ using the additive synthesis method (with cosine)
    private void generateTriangleAdditiveSynthesis(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);

        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float sampleValue = 0;
            float currentTime = float(i) / samplingRate;
            for(int wave = 1; wave * frequency < nyquistFrequency; wave += 2) {
                sampleValue += (1.0 / wave) * (1.0 / wave) * cos(wave * TWO_PI * frequency * currentTime);
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates a 'bell' sound using FM synthesis
    private void generateBellFMSynthesis(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);
        float carrierFrequency = 100f;
        float modulatorFrequency = 280f;
        float indexAm = 6f;
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float currentTime = float(i) / samplingRate;
            soundSamples.leftChannelSamples[i] = amplitude * // amp=the carrier amplitude 
            sin(TWO_PI * carrierFrequency * currentTime + indexAm * sin(TWO_PI * modulatorFrequency * currentTime) ); 
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generate a sound using Karplus-Strong algorithm
    private void generateKarplusStrongSound(float amplitude, float frequency, float duration) {
      int delay = 800;
      int samplesToGenerate = int(duration * samplingRate);
          for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            soundSamples.leftChannelSamples[i] = amplitude * random(-1,1);
        }
        for(int i = delay + 1; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            soundSamples.leftChannelSamples[i] = 0.5 * (soundSamples.leftChannelSamples[i - delay] + soundSamples.leftChannelSamples[i - delay - 1]) ;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generats a white noise
    private void generateWhiteNoise(float amplitude, float frequency, float duration) {
      int samplesToGenerate = int(duration * samplingRate);
          for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            soundSamples.leftChannelSamples[i] = amplitude * random(-1,1);
        }
    }

    // This function generates '3 sine wave' sound
    private void generateFourSineWave(float amplitude, float frequency, float duration) {
        // Generate the 3 sine waves by adding the sine waves at the correct frequency and
        // correct amplitude. The fundamental frequency comes from the variable 'frequency'.
        
        /*** complete this function ***/
       int samplesToGenerate = int(duration * samplingRate);
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float currentTime = float(i) / samplingRate;
            soundSamples.leftChannelSamples[i] = amplitude * (sin(TWO_PI * frequency * currentTime) 
            + sin(TWO_PI * frequency * currentTime + (float(1)/4) * TWO_PI * frequency) 
            + sin(TWO_PI * frequency * currentTime + (float(2)/4) * TWO_PI * frequency) 
            + sin(TWO_PI * frequency * currentTime + (float(3)/4) * TWO_PI * frequency)) / 4;
            soundSamples.rightChannelSamples[i] =  soundSamples.leftChannelSamples[i];
        }
              
    }

    // This function generates a repeating narrow pulse
    private void generateRepeatingNarrowPulse(float amplitude, float frequency, float duration) {
      int samplesToGenerate = int(duration * samplingRate);
          for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            soundSamples.leftChannelSamples[i] = amplitude * random(-1,1);
            if(random(0,1) > 0.4){
              soundSamples.leftChannelSamples[i] = 0;
            }
            soundSamples.rightChannelSamples[i] =  soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates a triangle wave using the time domain method
    private void generateTriangleInTimeDomain(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);
        float oneCycle =  samplingRate / frequency;
        float quarterCycle = oneCycle / 4;
        for(int i = 0 ; i < samplesToGenerate && i < soundSamples.totalSamples ; ++ i){
          float whereInCycle = i % (int) oneCycle;
          if( whereInCycle < quarterCycle){
            soundSamples.leftChannelSamples[i] =0 - amplitude *  whereInCycle / quarterCycle;
          }else if ( whereInCycle >= quarterCycle && whereInCycle < 2 * quarterCycle){
            soundSamples.leftChannelSamples[i] =  amplitude *  ((whereInCycle - quarterCycle)/ quarterCycle - 1);
          }else if ( whereInCycle >= 2 * quarterCycle && whereInCycle < 3 * quarterCycle){
            soundSamples.leftChannelSamples[i] =  amplitude *  ((whereInCycle - quarterCycle)/ quarterCycle  - 1);
          }else if ( whereInCycle >= 3 * quarterCycle && whereInCycle < 4 * quarterCycle){
            soundSamples.leftChannelSamples[i] = 0 - amplitude *  ((whereInCycle - 3 * quarterCycle)/ quarterCycle - 1);
          }
          soundSamples.rightChannelSamples[i] =  soundSamples.leftChannelSamples[i];
        }
        
    }

    // This function generates a science fiction movie sound using FM synthesis
    private void generateSciFiSound(float amplitude, float frequency, float duration) {
        int samplesToGenerate = int(duration * samplingRate);
        float carrierFrequency = 500f;
        float modulatorFrequency = 500f;
        float indexAm = 10f;
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float currentTime = float(i) / samplingRate;
            soundSamples.leftChannelSamples[i] = amplitude * // amp=the carrier amplitude 
            sin(TWO_PI * carrierFrequency * currentTime + indexAm * sin(TWO_PI * modulatorFrequency * currentTime) ); 
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generate a sound using Karplus-Strong algorithm
    private void generateKarplusStrongSound2(float amplitude, float frequency, float duration) {
        int delay = 800;
        float blendFactor = 0.5f;
      int samplesToGenerate = int(duration * samplingRate);
          for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            soundSamples.leftChannelSamples[i] = amplitude * random(-1,1);
        }
        for(int i = delay + 1; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
          float t = random(0,1);
          if(t <= blendFactor){
            soundSamples.leftChannelSamples[i] = 0.5 * (soundSamples.leftChannelSamples[i - delay] + soundSamples.leftChannelSamples[i - delay - 1]) ;
          }else{
            soundSamples.leftChannelSamples[i] = -0.5 * (soundSamples.leftChannelSamples[i - delay] + soundSamples.leftChannelSamples[i - delay - 1]) ;
          }
          soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // This function generates a waveform that is the multiplication of another 2 waveforms
    // Use AudioSamples::reMap if needed
    private void generateAxB(int soundA, int soundB, float amplitude, float frequency, float duration) {
      AudioSamples result = new AudioSamples(duration,samplingRate);
      AudioSamples samplesA = generateSound(soundA,amplitude,frequency,duration);
      result.add(samplesA,0.5,0);
      AudioSamples samplesB = generateSound(soundB,amplitude,frequency,duration);
      result.add(samplesB,0.5,0);
      result.reMap(-2,2,-1,1);
      soundSamples = result;
    }

    // You can add your own sound if you want to
    private void generateSound20(float amplitude, float frequency, float duration) {
      int samplesToGenerate = int(duration * samplingRate);

        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float sampleValue = 0;
            float currentTime = float(i) / samplingRate;
            for(int wave = 1; wave * frequency < nyquistFrequency; wave += 1) {
                sampleValue += (1.0 / wave) * cos(wave * TWO_PI * frequency * currentTime);
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // You can add your own sound if you want to
    private void generateSound21(float amplitude, float frequency, float duration) {
      int samplesToGenerate = int(duration * samplingRate);
        float modulatorFrequency = 500f;
        float indexAm = 10f;
        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float currentTime = float(i) / samplingRate;
            soundSamples.leftChannelSamples[i] = amplitude * // amp=the carrier amplitude 
            sin(TWO_PI * frequency * currentTime + indexAm * sin(TWO_PI * modulatorFrequency * currentTime) ); 
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // You can add your own sound if you want to
    private void generateSound22(float amplitude, float frequency, float duration) {
      generateSawtoothAdditiveSynthesis(amplitude,frequency,duration);
        int delay = 800;
      for(int i = delay + 1;  i < soundSamples.totalSamples; ++i) {
            soundSamples.leftChannelSamples[i] = 0.5 * (soundSamples.leftChannelSamples[i - delay] + soundSamples.leftChannelSamples[i - delay - 1]) ;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // You can add your own sound if you want to
    private void generateSound23(float amplitude, float frequency, float duration) {
      generateTriangleInTimeDomain(amplitude,frequency,duration);
       int delay = 800;
      for(int i = delay + 1; i < soundSamples.totalSamples; ++i) {
            soundSamples.leftChannelSamples[i] = 0.5 * (soundSamples.leftChannelSamples[i - delay] + soundSamples.leftChannelSamples[i - delay - 1]) ;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }

    // You can add your own sound if you want to
    private void generateSound24(float amplitude, float frequency, float duration) {
      int samplesToGenerate = int(duration * samplingRate);

        for(int i = 0; i < samplesToGenerate && i < soundSamples.totalSamples; ++i) {
            float sampleValue = 0;
            float currentTime = float(i) / samplingRate;
            for(int wave = 1; wave * frequency < nyquistFrequency; wave += 2) {
                sampleValue += (1.0 / wave) * (1.0 / wave) * sin(wave * TWO_PI * frequency * currentTime);
            }
            soundSamples.leftChannelSamples[i] = amplitude * sampleValue;
            soundSamples.rightChannelSamples[i] = soundSamples.leftChannelSamples[i];
        }
    }
}