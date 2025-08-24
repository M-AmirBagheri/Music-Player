package backend.src.server;

import backend.src.protocol.MessageParser;
import backend.src.protocol.Responses;
import backend.src.protocol.payloads.*;
import backend.src.services.*;

import java.io.*;
import java.net.Socket;

public class ClientHandler implements Runnable {
    private final Socket clientSocket;
    private BufferedReader in;
    private PrintWriter out;

    private final AuthService auth = new AuthService();
    private final PaymentService payment = new PaymentService();
    private final ShopService shop = new ShopService();
    private final DownloadService download = new DownloadService();

    public ClientHandler(Socket socket) { this.clientSocket = socket; }

    @Override public void run() {
        try {
            in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(clientSocket.getOutputStream())), true);

            String line;
            while ((line = in.readLine()) != null) {
                String[] parts = MessageParser.split(line);
                String cmd = parts[0];
                String payload = parts.length > 1 ? parts[1] : "";

                switch (cmd) {
                    case "REGISTER" -> {
                        RegisterReq r = MessageParser.parse(payload, RegisterReq.class);
                        if (r == null || r.username == null || r.password == null || r.email == null) {
                            out.println(Responses.error("BAD_REQUEST")); break;
                        }
                        out.println(auth.register(r.username, r.email, r.password));
                    }
                    case "LOGIN" -> {
                        LoginReq r = MessageParser.parse(payload, LoginReq.class);
                        if (r == null || r.login == null || r.password == null) { out.println(Responses.error("BAD_REQUEST")); break; }
                        out.println(auth.login(r.login, r.password));
                    }
                    case "TOPUP" -> {
                        TopupReq r = MessageParser.parse(payload, TopupReq.class);
                        if (r == null) { out.println(Responses.error("BAD_REQUEST")); break; }
                        out.println(payment.topup(r.username, r.amount));
                    }
                    case "SUBSCRIBE" -> {
                        SubscribeReq r = MessageParser.parse(payload, SubscribeReq.class);
                        if (r == null) { out.println(Responses.error("BAD_REQUEST")); break; }
                        out.println(payment.subscribe(r.username, r.plan));
                    }
                    case "PURCHASE" -> {
                        PurchaseReq r = MessageParser.parse(payload, PurchaseReq.class);
                        if (r == null) { out.println(Responses.error("BAD_REQUEST")); break; }
                        out.println(shop.purchase(r.username, r.song_id));
                    }
                    case "DOWNLOAD_START" -> {
                        DownloadStartReq r = MessageParser.parse(payload, DownloadStartReq.class);
                        if (r == null) { out.println(Responses.error("BAD_REQUEST")); break; }
                        download.sendSongChunks(out, r.song_id);
                    }
                    default -> out.println(Responses.error("UNKNOWN_COMMAND"));
                }
            }
        } catch (IOException e) {
            System.err.println("Client error: " + e.getMessage());
        } finally {
            try { clientSocket.close(); } catch (IOException ignored) {}
        }
    }
}
