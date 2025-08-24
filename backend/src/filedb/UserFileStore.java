package backend.src.filedb;

import backend.src.model.UserSnapshot;
import backend.src.util.Passwords;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

public class UserFileStore {
    private static final String ROOT = "data/users/";
    private static final Map<String, Object> LOCKS = new ConcurrentHashMap<>();

    private static File fileOf(String username) { return new File(ROOT + username + ".txt"); }
    private static Object lock(String username) { return LOCKS.computeIfAbsent(username, k -> new Object()); }

    public boolean exists(String username) { return fileOf(username).exists(); }

    public boolean createUser(String username, String email, String plainPassword) {
        synchronized (lock(username)) {
            if (exists(username)) return false;
            fileOf(username).getParentFile().mkdirs();
            String hashed = Passwords.hash(plainPassword);
            List<String> lines = Arrays.asList(
                    "password=" + hashed,
                    "email=" + email,
                    "credit=0.0",
                    "subscription_tier=none",
                    "subscription_expiry=",
                    "purchased="
            );
            return writeAtomically(username, lines);
        }
    }

    public boolean verifyPassword(String login, String plain) throws IOException {
        // login می‌تواند username باشد؛ (برای سادگی ایمیل = نام فایل نداریم)
        String username = login; // اگر خواستید ایمیل→یوزرنیم map کنید، اینجا اضافه کنید.
        File f = fileOf(username);
        if (!f.exists()) return false;
        Properties p = loadProps(f);
        String hashed = p.getProperty("password", "");
        return Passwords.verify(plain, hashed);
    }

    public UserSnapshot load(String username) throws IOException {
        File f = fileOf(username);
        if (!f.exists()) return null;
        Properties p = loadProps(f);
        UserSnapshot u = new UserSnapshot();
        u.username = username;
        u.email = p.getProperty("email", "");
        u.credit = Double.parseDouble(p.getProperty("credit", "0.0"));
        u.subscriptionTier = p.getProperty("subscription_tier", "none");
        u.subscriptionExpiry = p.getProperty("subscription_expiry", "");
        String purchased = p.getProperty("purchased", "");
        if (!purchased.isEmpty()) {
            for (String s : purchased.split(",")) if (!s.isEmpty()) u.purchased.add(Integer.parseInt(s.trim()));
        }
        return u;
    }

    public boolean updateCredit(String username, double delta) throws IOException {
        synchronized (lock(username)) {
            UserSnapshot u = load(username);
            if (u == null) return false;
            u.credit = Math.max(0.0, u.credit + delta);
            return save(username, u);
        }
    }

    public boolean setSubscription(String username, String tier, String expiry) throws IOException {
        synchronized (lock(username)) {
            UserSnapshot u = load(username);
            if (u == null) return false;
            u.subscriptionTier = tier;
            u.subscriptionExpiry = expiry;
            return save(username, u);
        }
    }

    public boolean appendPurchase(String username, int songId) throws IOException {
        synchronized (lock(username)) {
            UserSnapshot u = load(username);
            if (u == null) return false;
            if (!u.purchased.contains(songId)) u.purchased.add(songId);
            return save(username, u);
        }
    }

    public boolean hasPurchased(String username, int songId) throws IOException {
        UserSnapshot u = load(username);
        return u != null && u.purchased.contains(songId);
    }

    private boolean save(String username, UserSnapshot u) throws IOException {
        List<String> lines = Arrays.asList(
                "password=" + readProp(fileOf(username), "password"),
                "email=" + u.email,
                "credit=" + u.credit,
                "subscription_tier=" + u.subscriptionTier,
                "subscription_expiry=" + (u.subscriptionExpiry == null ? "" : u.subscriptionExpiry),
                "purchased=" + join(u.purchased)
        );
        return writeAtomically(username, lines);
    }

    private String readProp(File f, String key) throws IOException {
        return loadProps(f).getProperty(key, "");
    }

    private Properties loadProps(File f) throws IOException {
        Properties p = new Properties();
        try (BufferedReader r = Files.newBufferedReader(f.toPath())) {
            String line;
            while ((line = r.readLine()) != null) {
                int k = line.indexOf('=');
                if (k > 0) p.setProperty(line.substring(0, k), line.substring(k + 1));
            }
        }
        return p;
    }

    private boolean writeAtomically(String username, List<String> lines) {
        File target = fileOf(username);
        File tmp = new File(target.getParent(), username + ".tmp");
        try {
            tmp.getParentFile().mkdirs();
            Files.write(tmp.toPath(), lines, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            Files.move(tmp.toPath(), target.toPath(), StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            try { Files.deleteIfExists(tmp.toPath()); } catch (IOException ignored) {}
            return false;
        }
    }

    private String join(List<Integer> ids) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < ids.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append(ids.get(i));
        }
        return sb.toString();
    }
}
