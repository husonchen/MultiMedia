import java.io.File;  
import java.io.FileInputStream;  
import java.io.FileNotFoundException;  
import java.io.IOException;  
import java.io.InputStream;  
import java.security.MessageDigest; 

static class Util{
  private static byte[] createChecksum(String filename) {  
        InputStream fis = null;  
        try {  
            fis = new FileInputStream(filename);  
            byte[] buffer = new byte[1024];  
            MessageDigest complete = MessageDigest.getInstance("MD5");  
            int numRead = -1;  
  
            while ((numRead = fis.read(buffer)) != -1) {  
                complete.update(buffer, 0, numRead);  
            }  
            return complete.digest();  
        } catch (Exception e) {  
            e.printStackTrace(); 
        } finally {  
            try {  
                if (null != fis) {  
                    fis.close();  
                }  
            } catch (IOException e) {  
                e.printStackTrace(); 
            }  
        }  
        return null;  
  
    }  
  
    // see this How-to for a faster way to convert  
    // a byte array to a HEX string  
    public static String getMD5Checksum(String filename) {  
      
            if (!new File(filename).isFile()) {  
              println("file not find");
                return null;  
            }  
            byte[] b = createChecksum(filename);  
            if(null == b){  
                println("Error:create md5 string failure!");  
                return null;  
            }  
            StringBuilder result = new StringBuilder();  
  
            for (int i = 0; i < b.length; i++) {  
                result.append(Integer.toString((b[i] & 0xff) + 0x100, 16)  
                        .substring(1));  
            }  
            return result.toString();  
  
    }  
}