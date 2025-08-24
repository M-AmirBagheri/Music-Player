package backend.src.server;

import backend.src.services.AuthService;
import backend.src.services.ShopService;
import backend.src.services.DownloadService;
import backend.src.services.PaymentService;
import backend.src.services.CommentService;
import backend.src.services.RatingService;
import backend.src.protocol.MessageParser;
import backend.src.protocol.Responses;
import backend.src.protocol.payloads.*;

import java.io.*;
import java.net.Socket;

public class ClientHandler implements Runnable {
    private final Socket clientSocket;
    private BufferedReader in;
    private PrintWriter out;

    private final AuthService authService;
    private final ShopService shopService;
    private final DownloadService downloadService;
    private final PaymentService paymentService;
    private final CommentService commentService;
    private final RatingService ratingService;

    public ClientHandler(Socket socket) {
        this.clientSocket = socket;
        this.authService = new AuthService();
        this.shopService = new ShopService();
        this.downloadService = new DownloadService();
        this.paymentService = new PaymentService();
        this.commentService = new CommentService();
        this.ratingService = new RatingService();
    }

    @Override
    public void run() {
        try {
            in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(clientSocket.getOutputStream())), true);

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
        String[] parts = MessageParser.split(message);
        String command = parts[0];
        String payload = parts[1];

        String response = "";

        switch (command) {
            case "REGISTER":
                RegisterReq registerRequest = MessageParser.parse(payload, RegisterReq.class);
                response = authService.register(registerRequest.username, registerRequest.email, registerRequest.password);
                break;

            case "LOGIN":
                LoginReq loginRequest = MessageParser.parse(payload, LoginReq.class);
                response = authService.login(loginRequest.login, loginRequest.password);
                break;

            case "TOPUP":
                TopupReq topupRequest = MessageParser.parse(payload, TopupReq.class);
                response = paymentService.topup(topupRequest.username, topupRequest.amount);
                break;

            case "SUBSCRIBE":
                SubscribeReq subscribeRequest = MessageParser.parse(payload, SubscribeReq.class);
                response = paymentService.subscribe(subscribeRequest.username, subscribeRequest.plan);
                break;

            case "PURCHASE":
                PurchaseReq purchaseRequest = MessageParser.parse(payload, PurchaseReq.class);
                response = shopService.purchase(purchaseRequest.username, purchaseRequest.songId);
                break;

            case "DOWNLOAD_START":
                DownloadStartReq downloadStartRequest = MessageParser.parse(payload, DownloadStartReq.class);
                downloadService.sendSongChunks(out, downloadStartRequest.songId);
                break;

            case "COMMENT":
                CommentReq commentRequest = MessageParser.parse(payload, CommentReq.class);
                response = commentService.addComment(commentRequest.songId, commentRequest.username, commentRequest.commentText);
                break;

            case "RATE_SONG":
                RatingReq ratingRequest = MessageParser.parse(payload, RatingReq.class);
                response = ratingService.rateSong(ratingRequest.songId, ratingRequest.username, ratingRequest.rating);
                break;

            default:
                response = Responses.error("UNKNOWN_COMMAND");
                break;
        }

        return response;
    }
}
