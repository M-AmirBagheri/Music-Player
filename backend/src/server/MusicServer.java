package backend.src.server;

import java.io.*;
import java.net.*;
import backend.protocol.*;
import backend.services.*;

public class MusicServer {
    private static final int PORT = Integer.parseInt(System.getProperty("PORT", "12345"));
    
    public static void main(String[] args) {
        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("✅ Music server started on port " + PORT);
            
            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("✅ New client connected: " + clientSocket.getInetAddress());

                // ایجاد یک Thread برای هر اتصال جدید
                new Thread(new ClientHandler(clientSocket)).start();
            }
        } catch (IOException e) {
            System.err.println("❌ Server failed: " + e.getMessage());
        }
    }
}
