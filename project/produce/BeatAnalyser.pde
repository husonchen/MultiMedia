import java.io.File;  
import java.io.FileOutputStream;  
import java.io.FileReader;  

class BeatAnalyser{
  
  long[] beats1;
  long[] beats2;
  
  public BeatAnalyser(String beatFile1,String beatFile2){
    beats1 = readBeats(beatFile1);
    beats2 = readBeats(beatFile2);
  }
  
  public long[] readBeats(String fileName) {
    long[] beats =null ;
    String[] beatString = null;
    try{
      File file = new File(fileName);
      FileReader reader = new FileReader(file);
      int fileLen = (int)file.length();
      char[] chars = new char[fileLen];
      reader.read(chars);
      beatString = String.valueOf(chars).split(" ");
    }catch (Exception e){
      e.printStackTrace();  
    }
    if(beatString != null){
      beats =new long[beatString.length];
      for(int i = 0; i < beats.length ; i ++){
        beats[i] = Integer.valueOf(beatString[i]);
      }
    }
    return beats;
  }
}