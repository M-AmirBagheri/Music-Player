public class User {
    private int id;
    private String username;
    private String email;
    private String password;
    private double credit;
    private String subscription;

    public User(int id, String username, String email, String password, double credit, String subscription) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.credit = credit;
        this.subscription = subscription;
    }

    public int getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public double getCredit() {
        return credit;
    }

    public String getSubscription() {
        return subscription;
    }

    public void setCredit(double credit) {
        this.credit = credit;
    }

    public void setSubscription(String subscription) {
        this.subscription = subscription;
    }
}
