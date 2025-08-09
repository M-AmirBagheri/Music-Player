package server;

import database.DatabaseManager;
import models.Song;
import com.google.gson.Gson;
import java.io.*;
import java.net.*;
import java.util.List;

public class ClientHandler extends Thread {
    private Socket clientSocket;
    private DatabaseManager db;
    private PrintWriter out;
    private BufferedReader in;

    public ClientHandler(Socket clientSocket, DatabaseManager db) {
        this.clientSocket = clientSocket;
        this.db = db;
        try {
            out = new PrintWriter(clientSocket.getOutputStream(), true);
            in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
        } catch (IOException e) {
            System.err.println("Error in ClientHandler constructor: " + e.getMessage());
        }
    }

    @Override
    public void run() {
        String message;
        try {
            while ((message = in.readLine()) != null) {
                System.out.println("Received: " + message);
                handleRequest(message);
            }
        } catch (IOException e) {
            System.err.println("Error in ClientHandler run(): " + e.getMessage());
        }
    }

    private void handleRequest(String message) {
        String[] messageParts = message.split(";");
        String command = messageParts[0];

        switch (command) {
            case "GET_ALL_SONGS":
                sendAllSongs();
                break;

            case "LOGIN":
                handleLogin(messageParts[1], messageParts[2]);
                break;

            case "PURCHASE_SONG":
                handlePurchaseSong(messageParts[1], Integer.parseInt(messageParts[2]));
                break;

            case "RATE_SONG":
                handleRateSong(Integer.parseInt(messageParts[1]), Integer.parseInt(messageParts[2]), Integer.parseInt(messageParts[3]));
                break;

            case "ADD_COMMENT":
                handleAddComment(Integer.parseInt(messageParts[1]), Integer.parseInt(messageParts[2]), messageParts[3]);
                break;

            default:
                sendMessage("ERROR;Invalid command");
                break;
        }
        }


         private void sendAllSongs() {
            List<Song> songs = db.getAllSongs();
            Gson gson = new Gson();
            String jsonResponse = gson.toJson(songs);
            sendMessage("SONG_LIST;" + jsonResponse);
        }

       
        private void handleLogin(String username, String password) {
            if (db.validateLogin(username, password) != null) {
                sendMessage("LOGIN_SUCCESS");
            } else {
                sendMessage("ERROR;Invalid credentials");
            }
        }

   
        private void handlePurchaseSong(String username, int songId) {
            if (db.purchaseSong(username, songId)) {
                sendMessage("PURCHASE_SUCCESS");
            } else {
                sendMessage("ERROR;Purchase failed");
            }
        }

       
        private void handleRateSong(int userId, int songId, int rating) {
            if (db.rateSong(userId, songId, rating)) {
                sendMessage("RATE_SUCCESS");
            } else {
                sendMessage("ERROR;Rating failed");
            }
        }

      
        private void handleAddComment(int songId, int userId, String commentText) {
            if (db.addComment(userId, songId, commentText)) {
                sendMessage("COMMENT_ADDED");
            } else {
                sendMessage("ERROR;Adding comment failed");
            }
        }

       
        private void sendMessage(String message) {
            out.println(message);
        }
}   
