public class PasswordHasher {
    public static String hashPassword(String plainPassword) {
        
        return Integer.toHexString(plainPassword.hashCode());
    }
}
