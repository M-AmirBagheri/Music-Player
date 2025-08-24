package backend.services;

import backend.filedb.UserFileStore;
import backend.util.Passwords;
import backend.protocol.Responses;

public class AuthService {

    private final UserFileStore store;

    public AuthService() {
        this.store = new UserFileStore();
    }

    // ثبت‌نام کاربر
    public String register(String username, String email, String password) {
        if (store.exists(username)) {
            return Responses.error("USERNAME_EXISTS");  // اگر کاربر قبلاً ثبت‌نام کرده باشد
        }

        // هش کردن پسورد و ذخیره اطلاعات کاربر در فایل
        String hashedPassword = Passwords.hash(password);
        boolean success = store.createUser(username, email, hashedPassword);

        return success ? Responses.success("REGISTER_OK") : Responses.error("REGISTER_FAILED");
    }

    // ورود به سیستم
    public String login(String login, String password) {
        try {
            if (!store.exists(login)) {
                return Responses.error("USER_NOT_FOUND");
            }

            boolean isPasswordCorrect = store.verifyPassword(login, password);
            if (!isPasswordCorrect) {
                return Responses.error("INVALID_PASSWORD");
            }

            return Responses.success("LOGIN_OK");
        } catch (Exception e) {
            return Responses.error("SERVER_ERROR");
        }
    }
}
