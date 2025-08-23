package backend.server;

import java.io.*;
import java.net.*;

public class ClientHandler implements Runnable {
    private Socket clientSocket;
    private BufferedReader in;
    private PrintWriter out;

    public ClientHandler(Socket socket) {
        this.clientSocket = socket;
    }

    @Override
    public void run() {
        try {
            in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            out = new PrintWriter(clientSocket.getOutputStream(), true);

            // دریافت پیام از کلاینت
            String message;
            while ((message = in.readLine()) != null) {
                System.out.println("Received: " + message);

                // ارسال پاسخ به کلاینت
                out.println("Hello from server: " + message);
            }
        } catch (IOException e) {
            System.err.println("❌ Error handling client: " + e.getMessage());
        } finally {
            try {
                clientSocket.close();
            } catch (IOException e) {
                System.err.println("❌ Error closing client socket: " + e.getMessage());
            }
        }
    }
}
