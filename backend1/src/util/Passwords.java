package backend.util;

import org.mindrot.jbcrypt.BCrypt;

public class Passwords {
    public static String hash(String plain) {
        return BCrypt.hashpw(plain, BCrypt.gensalt());
    }
    public static boolean verify(String plain, String hashed) {
        if (hashed == null || hashed.isEmpty()) return false;
        return BCrypt.checkpw(plain, hashed);
    }
}
