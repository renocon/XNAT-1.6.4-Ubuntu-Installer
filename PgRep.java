import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;


public class PgRep {
	
	
	public static void main(String [] args){
		String find = "PG_DATA_PLACE";
		String use = System.getProperty("user.dir")+"/pg944/data";
		System.out.println(use);
		String file = "postgresql.conf";
		
		String path = use;
		try {
			String data = readFileAsString(path+'/'+file);
			data = data.replace(find, use);
			PrintWriter out = new PrintWriter(path+'/'+file);
			out.println(data);
			out.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.out.println("failed");
			return;
		}
		
		System.out.println("postgres conf file success");
	}
	
	private static String readFileAsString(String filePath) throws IOException {
        StringBuffer fileData = new StringBuffer();
        BufferedReader reader = new BufferedReader(new FileReader(filePath));
        char[] buf = new char[1024];
        int numRead=0;
        while((numRead=reader.read(buf)) != -1){
            String readData = String.valueOf(buf, 0, numRead);
            fileData.append(readData);
        }
        reader.close();
        return fileData.toString();
    }
}
