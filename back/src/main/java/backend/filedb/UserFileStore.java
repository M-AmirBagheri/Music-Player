package backend.filedb;

import backend.util.Passwords;
import java.io.*;
import java.nio.file.*;
import java.util.*;

public class UserFileStore {
    private static final String ROOT = "data/users/";

    private static File fileOf(String username) {
        return new File(ROOT + username + ".txt");
    }

    // بررسی اینکه کاربر وجود دارد یا خیر
    public boolean exists(String username) {
        return fileOf(username).exists();
    }

    // ایجاد کاربر جدید و ذخیره‌سازی در فایل
    public boolean createUser(String username, String email, String hashedPassword) {
        try {
            // بررسی اگر کاربر از قبل وجود دارد
            if (exists(username)) return false;

            // ایجاد فایل و نوشتن اطلاعات
            File file = fileOf(username);
            file.getParentFile().mkdirs();

            List<String> lines = Arrays.asList(
                    "password=" + hashedPassword,
                    "email=" + email,
                    "credit=0.0",
                    "subscription_tier=none",
                    "subscription_expiry=",
                    "purchased="
            );

            Files.write(file.toPath(), lines, StandardOpenOption.CREATE);
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // تایید پسورد
    public boolean verifyPassword(String username, String password) {
        try {
            File file = fileOf(username);
            if (!file.exists()) return false;

            // خواندن پسورد ذخیره شده
            BufferedReader reader = Files.newBufferedReader(file.toPath());
            String line;
            String hashedPassword = null;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("password=")) {
                    hashedPassword = line.split("=")[1];
                    break;
                }
            }

            return Passwords.verify(password, hashedPassword);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}
