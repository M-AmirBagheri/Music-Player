import java.io.*;
import java.net.Socket;

public class TestClient {
    public static void main(String[] args) {
        String serverAddress = "localhost";  
        int port = 12345;  

        try (
            Socket socket = new Socket(serverAddress, port);
            PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        ) {
            
            out.println("GET_ALL_SONGS");

            
            String response;
            while ((response = in.readLine()) != null) {
                System.out.println("Server response: " + response);
                if (response.startsWith("SONG_LIST")) break; 
            }

        } catch (IOException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
