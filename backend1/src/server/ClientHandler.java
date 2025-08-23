package backend.server;

import backend.services.AuthService;
import backend.protocol.MessageParser;
import backend.protocol.Responses;

import java.io.*;
import java.net.*;

public class ClientHandler implements Runnable {
    private Socket clientSocket;
    private BufferedReader in;
    private PrintWriter out;

    private AuthService authService;

    public ClientHandler(Socket socket) {
        this.clientSocket = socket;
        this.authService = new AuthService();
    }

    @Override
    public void run() {
        try {
            in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            out = new PrintWriter(clientSocket.getOutputStream(), true);

            String message;
            while ((message = in.readLine()) != null) {
                System.out.println("Received: " + message);
                String response = processRequest(message);
                out.println(response);
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

    private String processRequest(String message) {
        String command = MessageParser.parseCommand(message).name();
        String response = "";

        switch (command) {
            case "REGISTER":
                // داده‌ها از پیام استخراج می‌شود
                String registerResponse = authService.registerUser("username", "password", "email");
                response = registerResponse;
                break;

            case "LOGIN":
                String loginResponse = authService.loginUser("username", "password");
                response = loginResponse;
                break;

            default:
                response = Responses.errorResponse("Unknown command");
                break;
        }

        return response;
    }
}
