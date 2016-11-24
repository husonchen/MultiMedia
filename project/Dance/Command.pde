import java.io.BufferedReader;  
import java.io.InputStreamReader;  
import java.io.File;  

public class Command {  
    public void exeCmd(String commandStr) {  
        BufferedReader br = null;  
        try {  
            Process p = Runtime.getRuntime().exec(commandStr);  
            br = new BufferedReader(new InputStreamReader(p.getInputStream()));  
            String line = null;  
            StringBuilder sb = new StringBuilder();  
            while ((line = br.readLine()) != null) {  
                sb.append(line + "\n");  
            }  
            System.out.println(sb.toString());  
        } catch (Exception e) {  
            e.printStackTrace();  
        }   
        finally  
        {  
            if (br != null)  
            {  
                try {  
                    br.close();  
                } catch (Exception e) {  
                    e.printStackTrace();  
                }  
            }  
        }  
    }  
    
    public void sperateMusic(String filePath,String audioPath){
      File audioFile = new File(audioPath);
      if(audioFile.exists()){
        audioFile.delete();
      }
      //String cmdString = "D:\\Progra~1\\ffmpeg-3.1.4-win64-static\\bin\\ffmpeg -i "+filePath+" -ab 160k -ac 2 -ar 44100 -vn "+audioPath;
      String cmdString = libPath + "\\ffmpeg -i "+filePath+" -ab 160k -ac 2 -ar 44100 -vn "+audioPath;
      println(cmdString);
      exeCmd(cmdString);
    }
    
    public void sperateVideo(String filePath,String videoPath){
      File videoFile = new File(videoPath);
      if(videoFile.exists()){
        videoFile.delete();
      }
      String cmdString = libPath + "\\ffmpeg -i " + filePath+" -vcodec copy -an "+videoPath;
      println(cmdString);
      exeCmd(cmdString);
    }
}  