import java.io.*;
import java.net.*;
import java.util.List;

public class MusicServer {
    private static final int PORT = 12345;
    private static final String SERVER_HOST = "10.0.2.2";
    private ServerSocket serverSocket;
    private DatabaseManager db;

    public MusicServer() {
        try {
            db = new DatabaseManager();

            serverSocket = new ServerSocket(PORT);
            System.out.println("Server is running on port " + PORT);

            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("New client connected: " + clientSocket.getInetAddress());
                new ClientHandler(clientSocket, db).start();
            }

        } catch (IOException e) {
            System.err.println("Error in MusicServer: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        new MusicServer();
    }
}
