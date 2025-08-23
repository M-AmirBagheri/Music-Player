package backend.services;

import backend.filedb.UserFileStore;
import backend.models.UserSnapshot;
import backend.protocol.Responses;

public class AuthService {
    private final UserFileStore store = new UserFileStore();

    public String register(String username, String email, String password) {
        if (store.exists(username)) return Responses.error("USERNAME_EXISTS");
        boolean ok = store.createUser(username, email, password);
        return ok ? Responses.ok("REGISTER_OK") : Responses.error("REGISTER_FAILED");
    }

    public String login(String login, String password) {
        try {
            boolean ok = store.verifyPassword(login, password);
            if (!ok) return Responses.error("AUTH_FAILED");
            UserSnapshot u = store.load(login);
            return "LOGIN_OK;" + backend.util.JsonUtil.toJson(u);
        } catch (Exception e) {
            return Responses.error("SERVER_ERROR");
        }
    }
}
