package backend.filedb;

import backend.model.UserSnapshot;
import backend.util.Passwords;

import java.io.*;
import java.nio.file.*;
import java.util.*;

public class UserFileStore {
    private static final String ROOT = "D:/music_player_project/back/data/users/";

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
            if (exists(username)) return false;  // اگر کاربر از قبل موجود باشد

            // ایجاد فایل و نوشتن اطلاعات
            File file = fileOf(username);
            file.getParentFile().mkdirs(); // ایجاد پوشه‌ها در صورت نبود

            List<String> lines = Arrays.asList(
                    "password=" + hashedPassword,
                    "email=" + email,
                    "credit=0.0",
                    "subscription_tier=none",
                    "subscription_expiry=",
                    "purchased="
            );

            Files.write(file.toPath(), lines, StandardOpenOption.CREATE);  // ایجاد فایل و ذخیره‌سازی
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

    // به‌روزرسانی اشتراک
    public boolean setSubscription(String username, String plan, String expiry) {
        UserSnapshot user = load(username);
        if (user != null) {
            user.setSubscriptionTier(plan);
            user.setSubscriptionExpiry(expiry);
            save(user);
            return true;
        }
        return false;
    }

    // بارگذاری اطلاعات کاربر
    public UserSnapshot load(String username) {
        File file = fileOf(username);
        if (!file.exists()) return null;

        try {
            BufferedReader reader = Files.newBufferedReader(file.toPath());
            String line;
            UserSnapshot userSnapshot = new UserSnapshot(username);

            while ((line = reader.readLine()) != null) {
                if (line.startsWith("credit=")) {
                    userSnapshot.setCredit(Double.parseDouble(line.split("=")[1]));
                } else if (line.startsWith("subscription_tier=")) {
                    userSnapshot.setSubscriptionTier(line.split("=")[1]);
                } else if (line.startsWith("subscription_expiry=")) {
                    userSnapshot.setSubscriptionExpiry(line.split("=")[1]);
                } else if (line.startsWith("purchased=")) {
                    String[] purchasedSongs = line.split("=")[1].split(",");
                    // بررسی اینکه آرایه خریداری‌شده خالی نباشد
                    for (String songId : purchasedSongs) {
                        if (!songId.isEmpty()) {
                            userSnapshot.addPurchasedSong(Integer.parseInt(songId));
                        }
                    }
                }
            }

            return userSnapshot;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    // افزودن خرید جدید برای کاربر
    public boolean appendPurchase(String username, int songId) {
        UserSnapshot user = load(username);
        if (user != null) {
            user.addPurchasedSong(songId);
            save(user);
            return true;
        }
        return false;
    }

    // ذخیره تغییرات به فایل
    private void save(UserSnapshot user) {
        File file = fileOf(user.getUsername());
        try {
            List<String> lines = Arrays.asList(
                    "password=" + user.getPassword(),
                    "email=" + user.getEmail(),
                    "credit=" + user.getCredit(),
                    "subscription_tier=" + user.getSubscriptionTier(),
                    "subscription_expiry=" + user.getSubscriptionExpiry(),
                    "purchased=" + String.join(",", user.getPurchasedSongs().stream().map(String::valueOf).toArray(String[]::new))
            );
            Files.write(file.toPath(), lines, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // بررسی اینکه کاربر آهنگ را خریداری کرده یا خیر
    public boolean hasPurchased(String username, int songId) {
        UserSnapshot user = load(username);
        return user != null && user.getPurchasedSongs().contains(songId);
    }

    // به‌روزرسانی اعتبار کاربر
    public boolean updateCredit(String username, double amount) {
        UserSnapshot user = load(username);
        if (user != null) {
            user.setCredit(user.getCredit() + amount);
            save(user);
            return true;
        }
        return false;
    }


}
