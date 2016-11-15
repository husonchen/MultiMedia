/*
 *  Copyright (c) 2007 - 2008 by Damien Di Fede <ddf@compartmental.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as published
 *   by the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

package ddf.minim;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;

import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.Mixer;

import ddf.minim.javasound.JSMinim;
import ddf.minim.spi.AudioOut;
import ddf.minim.spi.AudioRecording;
import ddf.minim.spi.AudioRecordingStream;
import ddf.minim.spi.AudioStream;
import ddf.minim.spi.MinimServiceProvider;
import ddf.minim.spi.SampleRecorder;

/**
 * The <code>Minim</code> class is the starting point for most everything
 * you will do with this library. There are methods for obtaining objects for playing audio files:
 * AudioSample and AudioPlayer. There are methods for obtaining an AudioRecorder, 
 * which is how you record audio to disk. There are methods for obtaining an AudioInput, 
 * which is how you can monitor the computer's line-in or microphone, depending on what the
 * user has set as the record source. Finally there are methods for obtaining an AudioOutput, 
 * which is how you can play audio generated by your program, typically by connecting classes 
 * found in the ugens package. 
 * <p>
 * Minim keeps references to all of the resources that are 
 * returned from these various methods so that you don't have to worry about closing them.
 * Instead, when your application ends you can simply call the stop method of your Minim instance.
 * Processing users <em>do not</em> need to do this because Minim detects when a PApplet is passed 
 * to the contructor and registers for a notification of application shutdown.
 * <p>
 * Minim requires an Object that can handle two important
 * file system operations so that it doesn't have to worry about details of 
 * the current environment. These two methods are:
 * <p>
 * <code>
 * String sketchPath( String fileName )<br/>
 * InputStream createInput( String fileName )<br/>
 * </code>
 * </p>
 * These are methods that are defined in Processing, which Minim was originally 
 * designed to cleanly interface with. The <code>sketchPath</code> method is 
 * expected to transform a filename into an absolute path and is used when 
 * attempting to create an AudioRecorder. The <code>createInput</code> method 
 * is used when loading files and is expected to take a filename, which is 
 * not necessarily an absolute path, and return an <code>InputStream</code> 
 * that can be used to read the file. For example, in Processing, the <code>createInput</code>
 * method will search in the data folder, the sketch folder, handle URLs, and absolute paths.
 * If you are using Minim outside of Processing, you can handle whatever cases are 
 * appropriate for your project.
 * 
 * @example Basics/PlayAFile
 * 
 * @author Damien Di Fede
 */

public class MyMinim
{
  /** Specifies that you want a MONO AudioInput or AudioOutput */
  public static final int        MONO        = 1;
  /** Specifies that you want a STEREO AudioInput or AudioOutput */
  public static final int        STEREO        = 2;

  public static final int        LOOP_CONTINUOUSLY  = -1;

  /** The .wav file format. */
  public static AudioFileFormat.Type  WAV          = AudioFileFormat.Type.WAVE;
  /** The .aiff file format. */
  public static AudioFileFormat.Type  AIFF        = AudioFileFormat.Type.AIFF;
  /** The .aifc file format. */
  public static AudioFileFormat.Type  AIFC        = AudioFileFormat.Type.AIFC;
  /** The .au file format. */
  public static AudioFileFormat.Type  AU          = AudioFileFormat.Type.AU;
  /** The .snd file format. */
  public static AudioFileFormat.Type  SND          = AudioFileFormat.Type.SND;

  private static boolean        DEBUG        = false;

  private MinimServiceProvider    mimp        = null;
  
  // we keep track of all the resources we are asked to create
  // so that when shutting down the library, users can simply call stop(),
  // and don't have to call close() on all of the things they've created.
  // in the event that they *do* call close() on resource we've created,
  // it will be removed from this list.
  private ArrayList<AudioSource>     sources        = new ArrayList<AudioSource>();
  // and unfortunately we have to track stream separately
  private ArrayList<AudioStream>    streams        = new ArrayList<AudioStream>();

  /**
   * Creates an instance of Minim.
   * <p>
   * Minim requires an Object that can handle two important
   * file system operations so that it doesn't have to worry about details of 
   * the current environment. These two methods are:
   * <p>
   * <code>
   * String sketchPath( String fileName )<br/>
   * InputStream createInput( String fileName )<br/>
   * </code>
   * </p>
   * These are methods that are defined in Processing, which Minim was originally 
   * designed to cleanly interface with. The <code>sketchPath</code> method is 
   * expected to transform a filename into an absolute path and is used when 
   * attempting to create an AudioRecorder. The <code>createInput</code> method 
   * is used when loading files and is expected to take a filename, which is 
   * not necessarily an absolute path, and return an <code>InputStream</code> 
   * that can be used to read the file. For example, in Processing, the <code>createInput</code>
   * method will search in the data folder, the sketch folder, handle URLs, and absolute paths.
   * If you are using Minim outside of Processing, you can handle whatever cases are 
   * appropriate for your project.
   * 
   * @param fileSystemHandler
   *            The Object that will be used for file operations.
   *            When using Processing, simply pass <strong>this</strong> to Minim's constructor.
   */
  public MyMinim( Object fileSystemHandler )
  {
    this( new JSMinim(fileSystemHandler) );
    
    // see if we're dealing with Processing and register for a dispose call if we are
    Class<?> superClass = fileSystemHandler.getClass().getSuperclass();
    if( superClass.getName() == "processing.core.PApplet" )
    {
      try
      {
        Method registerDispose = superClass.getMethod( "registerMethod", String.class, Object.class );
        registerDispose.invoke( fileSystemHandler, "dispose", this );
      }
      catch ( SecurityException e )
      {
        e.printStackTrace();
      }
      catch ( NoSuchMethodException e )
      {
        e.printStackTrace();
      }
      catch ( IllegalArgumentException e )
      {
        e.printStackTrace();
      }
      catch ( IllegalAccessException e )
      {
        e.printStackTrace();
      }
      catch ( InvocationTargetException e )
      {
        e.printStackTrace();
      }
    }
  }

  /** @invisible
   * 
   * Creates an instance of Minim that will use the provided implementation
   * for audio.
   * 
   * @param implementation
   *            the MinimServiceProvider that will be used for returning audio
   *            resources
   */
  public Minim( MinimServiceProvider implementation )
  {
    mimp = implementation;
    mimp.start();
  }

  /** @invisible
   * 
   * Used internally to report error messages. These error messages will
   * appear in the console area of the PDE if you are running a sketch from
   * the PDE, otherwise they will appear in the Java Console.
   * 
   * @param message
   *            the error message to report
   */
  public static void error(String message)
  {
    System.out.println( "=== Minim Error ===" );
    System.out.println( "=== " + message );
    System.out.println();
  }

  /** @invisible
   * 
   * Displays a debug message, but only if {@link #debugOn()} has been called.
   * The message will be displayed in the console area of the PDE, if you are
   * running your sketch from the PDE. Otherwise, it will be displayed in the
   * Java Console.
   * 
   * @param message
   *            the message to display
   * @see #debugOn()
   */
  public static void debug(String message)
  {
    if ( DEBUG )
    {
      String[] lines = message.split( "\n" );
      System.out.println( "=== Minim Debug ===" );
      for ( int i = 0; i < lines.length; i++ )
      {
        System.out.println( "=== " + lines[i] );
      }
      System.out.println();
    }
  }

  /**
   * Turns on debug messages.
   */
  public void debugOn()
  {
    DEBUG = true;
    if ( mimp != null )
    {
      mimp.debugOn();
    }
  }

  /**
   * Turns off debug messages.
   * 
   */
  public void debugOff()
  {
    DEBUG = false;
    if ( mimp != null )
    {
      mimp.debugOff();
    }
  }
  
  /** @invisible
   *  
   * Library callback used by Processing when a sketch is being shutdown. 
   * It is not necessary to call this directly. It simply calls stop().
   * 
   * 
   */
  public void dispose()
  {
    stop();
  }

  /**
   * 
   * Stops Minim and releases all audio resources.
   * <p>
   * If using Minim outside of Processing, you must call this to 
   * release all of the audio resources that Minim has generated.
   * It will call close() on all of them for you.
   * 
   */
  public void stop()
  {
    debug( "Stopping Minim..." );
    
    // close all sources and release them
    for( AudioSource s : sources )
    {
      // null the parent so the AudioSource doesn't try to call removeSource
      s.parent = null;
      s.close();
    }
    sources.clear();
    
    for( AudioStream s : streams )
    {
      s.close();
    }
    
    // stop the implementation
    mimp.stop();
  }
  
  void addSource( AudioSource s )
  {
    sources.add( s );
    s.parent = this;
  }
  
  void removeSource( AudioSource s )
  {
    sources.remove( s );
  }

  /**
   * When using the JavaSound implementation of Minim, this sets the JavaSound Mixer 
   * that will be used for obtaining input sources such as AudioInputs.
   * THIS METHOD WILL BE REPLACED IN A FUTURE VERSION.
   * 
   * @param mixer
   *            The Mixer we should try to acquire inputs from.
   */
  @Deprecated
  public void setInputMixer(Mixer mixer)
  {
    if ( mimp instanceof JSMinim )
    {
      ( (JSMinim)mimp ).setInputMixer( mixer );
    }
  }

  /**
   * When using the JavaSound implementation of Minim, this sets the JavaSound Mixer 
   * that will be used for obtain output destinations such as those required by AudioOuput, 
   * AudioPlayer, AudioSample, and so forth. 
   * THIS METHOD WILL BE REPLACED IN A FUTURE VERSION.
   * 
   * @param mixer
   *            The Mixer we should try to acquire outputs from.
   */
  @Deprecated
  public void setOutputMixer(Mixer mixer)
  {
    if ( mimp instanceof JSMinim )
    {
      ( (JSMinim)mimp ).setOutputMixer( mixer );
    }
  }

  /**
   * Creates an AudioSample using the provided sample data and AudioFormat. 
   * When a buffer size is not provided, it defaults to 1024. The buffer size 
   * of a sample controls the size of the left, right, and mix AudioBuffer 
   * fields of the returned AudioSample.
   * 
   * @shortdesc Creates an AudioSample using the provided sample data and AudioFormat.
   * 
   * @param sampleData
   *            float[]: the single channel of sample data
   * @param format
   *            the AudioFormat describing the sample data
   *            
   * @return an AudioSample that can be triggered to make sound
   * 
   * @example Advanced/CreateAudioSample
   * 
   * @related AudioSample
   */
  public AudioSample createSample(float[] sampleData, AudioFormat format)
  {
    return createSample( sampleData, format, 1024 );
  }

  /**
   * Creates an AudioSample using the provided sample data and
   * AudioFormat, with the desired output buffer size.
   * 
   * @param sampleData
   *            float[]: the single channel of sample data
   * @param format
   *            the AudioFormat describing the sample data
   * @param bufferSize
   *            int: the output buffer size to use,
   *            which controls the size of the left, right, and mix AudioBuffer
   *            fields of the returned AudioSample.
   *            
   * @return an AudioSample that can be triggered to make sound
   */
  public AudioSample createSample( float[] sampleData, AudioFormat format, int bufferSize )
  {
    AudioSample sample = mimp.getAudioSample( sampleData, format, bufferSize );
    addSource( sample );
    return sample;
  }

  /**
   * Creates an AudioSample using the provided left and right channel
   * sample data with an output buffer size of 1024.
   * 
   * @param leftSampleData
   *            float[]: the left channel of the sample data
   * @param rightSampleData
   *            float[]: the right channel of the sample data
   * @param format
   *            the AudioFormat describing the sample data
   *            
   * @return an AudioSample that can be triggered to make sound            
   */
  public AudioSample createSample( float[] leftSampleData, float[] rightSampleData, AudioFormat format )
  {
    return createSample( leftSampleData, rightSampleData, format, 1024 );
  }

  /**
   * Creates an AudioSample using the provided left and right channel
   * sample data.
   * 
   * @param leftSampleData
   *            float[]: the left channel of the sample data
   * @param rightSampleData
   *            float[]: the right channel of the sample data
   * @param format
   *            the AudioFormat describing the sample data
   * @param bufferSize
   *            int: the output buffer size to use,
   *            which controls the size of the left, right, and mix AudioBuffer
   *            fields of the returned AudioSample.
   *            
   * @return an AudioSample that can be triggered to make sound
   */
  public AudioSample createSample(float[] leftSampleData, float[] rightSampleData, AudioFormat format, int bufferSize)
  {
    AudioSample sample = mimp.getAudioSample( leftSampleData, rightSampleData, format, bufferSize );
    addSource( sample );
    return sample;
  }

  /**
   * Loads the requested file into an AudioSample.
   * By default, the buffer size used is 1024.
   * 
   * @shortdesc Loads the requested file into an AudioSample.
   * 
   * @param filename
   *            the file or URL that you want to load
   *            
   * @return an AudioSample that can be triggered to make sound
   * 
   * @example Basics/TriggerASample
   * 
   * @see #loadSample(String, int)
   * @see AudioSample
   * @related AudioSample
   */
  public AudioSample loadSample(String filename)
  {
    return loadSample( filename, 1024 );
  }

  /**
   * Loads the requested file into an AudioSample.
   * 
   * @param filename
   *            the file or URL that you want to load
   * @param bufferSize
   *            int: The sample buffer size you want.
   *            This controls the size of the left, right, and mix
   *            AudioBuffer fields of the returned AudioSample.
   *            
   * @return an AudioSample that can be triggered to make sound
   */
  public AudioSample loadSample(String filename, int bufferSize)
  {
    AudioSample sample = mimp.getAudioSample( filename, bufferSize );
    addSource( sample );
    return sample;
  }

  /** @invisible 
   * Loads the requested file into an {@link AudioSnippet}
   * 
   * @param filename
   *            the file or URL you want to load
   * @return an <code>AudioSnippet</code> of the requested file or URL
   */
  @Deprecated
  public AudioSnippet loadSnippet(String filename)
  {
    AudioRecording c = mimp.getAudioRecording( filename );
    if ( c != null )
    {
      return new AudioSnippet( c );
    }
    else
    {
      Minim.error( "Couldn't load the file " + filename );
    }
    return null;
  }

  /**
   * Loads the requested file into an AudioPlayer.
   * The default buffer size is 1024 samples and the 
   * buffer size determines the size of the left, right, 
   * and mix AudioBuffer fields on the returned AudioPlayer.
   * 
   * @shortdesc Loads the requested file into an AudioPlayer.
   * 
   * @example Basics/PlayAFile
   * 
   * @param filename
   *            the file or URL you want to load
   * @return an <code>AudioPlayer</code> that plays the file
   * 
   * @related AudioPlayer
   * 
   * @see #loadFile(String, int)
   */
  public AudioPlayer loadFile(String filename)
  {
    return loadFile( filename, 1024 );
  }

  /**
   * Loads the requested file into an {@link AudioPlayer} with the request
   * buffer size.
   * 
   * @param filename
   *            the file or URL you want to load
   * @param bufferSize
   *            int: the sample buffer size you want, which determines the 
   *            size of the left, right, and mix AudioBuffer fields of the 
   *            returned AudioPlayer.
   * 
   * @return an <code>AudioPlayer</code> with a sample buffer of the requested
   *         size
   */
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

  /**
   * Loads the file into an AudioRecordingStream, which allows you to stream 
   * audio data from the file yourself. Note that doing this will not 
   * result in any sound coming out of your speakers, unless of course you
   * send it there. You would primarily use this to perform offline-analysis
   * of a file or for very custom sound streaming schemes.
   * 
   * @shortdesc Loads the file into an AudioRecordingStream.
   * 
   * @example Analysis/offlineAnalysis
   * 
   * @param filename
   *            the file to load
   * @param bufferSize
   *            int: the bufferSize to use, which controls how much 
   *            of the streamed file is stored in memory at a time.
   * @param inMemory
   *            boolean: whether or not the file should be cached in memory as it is read
   *            
   * @return an AudioRecordingStream that you can use to read from the file.
   * 
   * 
   */
  public AudioRecordingStream loadFileStream(String filename, int bufferSize, boolean inMemory)
  {
    AudioRecordingStream stream = mimp.getAudioRecordingStream( filename, bufferSize, inMemory );
    streams.add( stream );
    return stream;
  }
  
  /**
   * Loads the requested file into a MultiChannelBuffer. The buffer's channel count
   * and buffer size will be adjusted to match the file.
   * 
   * @shortdesc Loads the requested file into a MultiChannelBuffer.
   * 
   * @example Advanced/loadFileIntoBuffer
   * 
   * @param filename 
   *       the file to load
   * @param outBuffer
   *       the MultiChannelBuffer to fill with the file's audio samples
   * 
   * @return  the sample rate of audio samples in outBuffer, or 0 if the load failed.
   * 
   * @related MultiChannelBuffer
   */
  public float loadFileIntoBuffer( String filename, MultiChannelBuffer outBuffer )
  {
    final int readBufferSize     = 4096;
    float     sampleRate       = 0;
    AudioRecordingStream  stream   = mimp.getAudioRecordingStream( filename, readBufferSize, false );
    if ( stream != null )
    {
      //stream.open();
      stream.play();
      sampleRate = stream.getFormat().getSampleRate();
      final int channelCount = stream.getFormat().getChannels();
      // for reading the file in, in chunks.
      MultiChannelBuffer readBuffer = new MultiChannelBuffer( channelCount, readBufferSize );
      // make sure the out buffer is the correct size and type.
      outBuffer.setChannelCount( channelCount );
      // how many samples to read total
      final long totalSampleCount = stream.getSampleFrameLength();
      outBuffer.setBufferSize( (int)totalSampleCount );
      
      // now read in chunks.
      long totalSamplesRead = 0;
      while( totalSamplesRead < totalSampleCount )
      {
        // is the remainder smaller than our buffer?
        if ( totalSampleCount - totalSamplesRead < readBufferSize )
        {
          readBuffer.setBufferSize( (int)(totalSampleCount - totalSamplesRead) );
        }
        
        stream.read( readBuffer );
        
        // copy data from one buffer to the other.
        for(int i = 0; i < channelCount; ++i)
        {
          // a faster way to do this would be nice.
          for(int s = 0; s < readBuffer.getBufferSize(); ++s)
          {
            outBuffer.setSample( i, (int)totalSamplesRead+s, readBuffer.getSample( i, s ) );
          }
        }
        
        totalSamplesRead += readBuffer.getBufferSize();
      }
      
      stream.close();
    }
      else
      {
          debug("Unable to load an AudioRecordingStream for " + filename);
      }

    return sampleRate;
  }
  
  /**
   * Creates an AudioRecorder that will use the provided Recordable object as its
   * record source and that will save to the file name specified. Recordable 
   * classes in Minim include AudioOutput, AudioInput, AudioPlayer, and AudioSample.
   * The format of the file will be inferred from the extension in the file name. 
   * If the extension is not a recognized file type, this will return null.
   * 
   * @shortdesc Creates an AudioRecorder.
   * 
   * @example Basics/RecordAudioOutput
   * 
   * @param source
   *            the <code>Recordable</code> object you want to use as a record source
   * @param fileName
   *            the name of the file to record to
   * 
   * @return an <code>AudioRecorder</code> for the record source
   * 
   * @related AudioRecorder
   */
  
  public AudioRecorder createRecorder( Recordable source, String fileName )
  {
    return createRecorder( source, fileName, false );
  }

  /**
   * Creates an AudioRecorder that will use the provided Recordable object as its
   * record source and that will save to the file name specified. Recordable 
   * classes in Minim include AudioOutput, AudioInput, AudioPlayer, and AudioSample.
   * The format of the file will be inferred from the extension in the file name. 
   * If the extension is not a recognized file type, this will return null. Be aware
   * that if you choose buffered recording the call to AudioRecorder's save method
   * will block until the entire buffer is written to disk. 
   * In the event that the buffer is very large, your app will noticeably hang.
   * 
   * @shortdesc Creates an AudioRecorder.
   * 
   * @example Basics/RecordAudioOutput
   * 
   * @param source
   *            the <code>Recordable</code> object you want to use as a record source
   * @param fileName
   *            the name of the file to record to
   * @param buffered
   *            boolean: whether or not to use buffered recording
   * 
   * @return an <code>AudioRecorder</code> for the record source
   * 
   * @related AudioRecorder
   * @invisible
   */
  public AudioRecorder createRecorder(Recordable source, String fileName, boolean buffered)
  {
    SampleRecorder rec = mimp.getSampleRecorder( source, fileName, buffered );
    if ( rec != null )
    {
      return new AudioRecorder( source, rec );
    }
    else
    {
      error( "Couldn't create an AudioRecorder for " + fileName + "." );
    }
    return null;
  }

  /**
   * An AudioInput is used when you want to monitor the active audio input 
   * of the computer. On a laptop, for instance, this will typically be 
   * the built-in microphone. On a desktop it might be the line-in
   * port on the soundcard. The default values are for a stereo input
   * with a 1024 sample buffer (ie the size of left, right, and mix 
   * buffers), sample rate of 44100 and bit depth of 16. Generally
   * speaking, you will not want to specify these things, but it's
   * there if you need it.
   * 
   * @shortdesc get an AudioInput that reads from the active audio input of the soundcard
   * 
   * @return an AudioInput that reads from the active audio input of the soundcard
   *         
   * @see #getLineIn(int, int, float, int)
   * @related AudioInput
   * @example Basics/MonitorInput
   */
  public AudioInput getLineIn()
  {
    return getLineIn( STEREO );
  }

  /**
   * Gets either a MONO or STEREO {@link AudioInput}.
   * 
   * @param type
   *            Minim.MONO or Minim.STEREO
   * @return an <code>AudioInput</code> with the requested type, a 1024 sample
   *         buffer, a sample rate of 44100 and a bit depth of 16
   * @see #getLineIn(int, int, float, int)
   */
  public AudioInput getLineIn(int type)
  {
    return getLineIn( type, 1024, 44100, 16 );
  }

  /**
   * Gets an {@link AudioInput}.
   * 
   * @param type
   *            Minim.MONO or Minim.STEREO
   * @param bufferSize
   *            int: how long you want the <code>AudioInput</code>'s sample buffer
   *            to be (ie the size of left, right, and mix buffers)
   * @return an <code>AudioInput</code> with the requested attributes, a
   *         sample rate of 44100 and a bit depth of 16
   * @see #getLineIn(int, int, float, int)
   */
  public AudioInput getLineIn(int type, int bufferSize)
  {
    return getLineIn( type, bufferSize, 44100, 16 );
  }

  /**
   * Gets an {@link AudioInput}.
   * 
   * @param type
   *            Minim.MONO or Minim.STEREO
   * @param bufferSize
   *            int: how long you want the <code>AudioInput</code>'s sample buffer
   *            to be (ie the size of left, right, and mix buffers)
   * @param sampleRate
   *            float: the desired sample rate in Hertz (typically 44100)
   * @return an <code>AudioInput</code> with the requested attributes and a
   *         bit depth of 16
   * @see #getLineIn(int, int, float, int)
   */
  public AudioInput getLineIn(int type, int bufferSize, float sampleRate)
  {
    return getLineIn( type, bufferSize, sampleRate, 16 );
  }

  /**
   * Gets an {@link AudioInput}.
   * 
   * @param type
   *            Minim.MONO or Minim.STEREO
   * @param bufferSize
   *            int: how long you want the <code>AudioInput</code>'s sample buffer
   *            to be (ie the size of left, right, and mix buffers)
   * @param sampleRate
   *            float: the desired sample rate in Hertz (typically 44100)
   * @param bitDepth
   *            int: the desired bit depth (typically 16)
   * @return an <code>AudioInput</code> with the requested attributes
   */
  public AudioInput getLineIn(int type, int bufferSize, float sampleRate, int bitDepth)
  {
    AudioInput  input  = null;
    AudioStream stream = mimp.getAudioInput( type, bufferSize, sampleRate, bitDepth );
    if ( stream != null )
    {
      AudioOut out = mimp.getAudioOutput( type, bufferSize, sampleRate, bitDepth );
      if ( out != null )
      {
        input = new AudioInput( stream, out );
      }
      else
      {
        stream.close();
      }
    }
    
    if ( input != null )
    {
      addSource( input );
    }
    else
    {
      error( "Minim.getLineIn: attempt failed, could not secure an AudioInput." );
    }
    
    return input;
  }

  /**
   * Get the input as an AudioStream that you can read from yourself, rather
   * than wrapped in an AudioInput that does that work for you.
   * 
   * @param type
   *            Minim.MONO or Minim.STEREO
   * @param bufferSize
   *            int: how long you want the AudioStream's interal 
   *            buffer to be.
   * @param sampleRate
   *            float: the desired sample rate in Hertz (typically 44100)
   * @param bitDepth
   *            int: the desired bit depth (typically 16)
   * @return an AudioStream that reads from the input source of the soundcard.
   */
  public AudioStream getInputStream(int type, int bufferSize, float sampleRate, int bitDepth)
  {
    AudioStream stream = mimp.getAudioInput( type, bufferSize, sampleRate, bitDepth );
    streams.add( stream );
    return stream;
  }

  /**
   * An AudioOutput is used to generate sound in real-time and output it to
   * the soundcard. Usually, the sound generated by an AudioOutput will be
   * heard through the speakers or headphones attached to a computer. The
   * default parameters for an AudioOutput are STEREO sound, a 1024 sample
   * buffer (ie the size of the left, right, and mix buffers), a sample 
   * rate of 44100, and a bit depth of 16. To actually generate sound
   * with an AudioOutput you need to patch at least one sound generating
   * UGen to it, such as an Oscil.
   * <p> 
   * Using setOutputMixer you can also create AudioOutputs that 
   * send sound to specific output channels of a soundcard.
   * 
   * @example Basics/SynthesizeSound
   * 
   * @shortdesc get an AudioOutput that can be used to generate audio
   * 
   * @return an AudioOutput that can be used to generate audio
   * @see #getLineOut(int, int, float, int)
   * @related AudioOutput
   * @related UGen
   */
  public AudioOutput getLineOut()
  {
    return getLineOut( STEREO );
  }

  /**
   * Gets an {@link AudioOutput}.
   * 
   * @param type
   *            Minim.MONO or Minim.STEREO
   * @return an <code>AudioOutput</code> with the requested type, a 1024
   *         sample buffer, a sample rate of 44100 and a bit depth of 16
   * @see #getLineOut(int, int, float, int)
   */
  public AudioOutput getLineOut(int type)
  {
    return getLineOut( type, 1024, 44100, 16 );
  }

  /**
   * Gets an {@link AudioOutput}.
   * 
   * @param type
   *            Minim.MONO or Minim.STEREO
   * @param bufferSize
   *            int: how long you want the AudioOutput's sample buffer
   *            to be (ie the size of the left, right, and mix buffers)
   * @return an <code>AudioOutput</code> with the requested attributes, a
   *         sample rate of 44100 and a bit depth of 16
   * @see #getLineOut(int, int, float, int)
   */
  public AudioOutput getLineOut(int type, int bufferSize)
  {
    return getLineOut( type, bufferSize, 44100, 16 );
  }

  /**
   * Gets an {@link AudioOutput}.
   * 
   * @param type
   *            Minim.MONO or Minim.STEREO
   * @param bufferSize
   *            int: how long you want the AudioOutput's sample buffer
   *            to be (ie the size of the left, right, and mix buffers)
   * @param sampleRate
   *            float: the desired sample rate in Hertz (typically 44100)
   * @return an <code>AudioOutput</code> with the requested attributes and a
   *         bit depth of 16
   * @see #getLineOut(int, int, float, int)
   */
  public AudioOutput getLineOut(int type, int bufferSize, float sampleRate)
  {
    return getLineOut( type, bufferSize, sampleRate, 16 );
  }

  /**
   * Gets an {@link AudioOutput}.
   * 
   * @param type
   *            Minim.MONO or Minim.STEREO
   * @param bufferSize
   *            int: how long you want the AudioOutput's sample buffer
   *            to be (ie the size of the left, right, and mix buffers)
   * @param sampleRate
   *            float: the desired sample rate in Hertz (typically 44100)
   * @param bitDepth
   *            int: the desired bit depth (typically 16)
   * @return an <code>AudioOutput</code> with the requested attributes
   */
  public AudioOutput getLineOut(int type, int bufferSize, float sampleRate, int bitDepth)
  {
    AudioOut out = mimp.getAudioOutput( type, bufferSize, sampleRate, bitDepth );
    if ( out != null )
    {
      AudioOutput output = new AudioOutput( out );
      addSource( output );
      return output;
    }

    error( "Minim.getLineOut: attempt failed, could not secure a LineOut." );
    return null;
  }
}