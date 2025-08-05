public class User {
    private int id;
    private String username;
    private String email;
    private String passwordHash;
    private double credit;
    private SubscriptionType subscription;
    private String profilePicturePath;

    public enum SubscriptionType {
        NONE, PREMIUM
    }
}