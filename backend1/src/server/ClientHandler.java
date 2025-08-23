package backend.server;

import backend.services.ShopService;
import backend.services.DownloadService;
import backend.services.CommentService;
import backend.protocol.MessageParser;
import backend.protocol.Responses;
import backend.protocol.Command;

import java.io.*;
import java.net.*;

public class ClientHandler implements Runnable {
    private Socket clientSocket;
    private BufferedReader in;
    private PrintWriter out;

    private ShopService shopService;
    private DownloadService downloadService;
    private CommentService commentService;

    public ClientHandler(Socket socket) {
        this.clientSocket = socket;
        this.shopService = new ShopService();
        this.downloadService = new DownloadService();
        this.commentService = new CommentService();
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
        Command command = MessageParser.parseCommand(message);
        String response = "";

        switch (command) {
            case REGISTER:
                //  سرویس ثبت‌نام
                break;
            case LOGIN:
                //  سرویس ورود
                break;
            case GET_SONGS:
                response = shopService.getAllSongs();
                break;
            case PURCHASE:
                //  سرویس خرید آهنگ
                break;
            case DOWNLOAD_START:
                //  سرویس دانلود
                response = downloadService.downloadSong(1); // فرض می‌کنیم songId = 1 است
                break;
            case COMMENT:
                //  سرویس ارسال نظر
                response = commentService.addComment(1, "user", "Great song!");
                break;
            default:
                response = Responses.errorResponse("Unknown command");
                break;
        }

        return response;
    }
}
