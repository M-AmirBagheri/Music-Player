package backend.model;

import java.util.HashSet;
import java.util.Set;

public class UserSnapshot {
    private String username;
    private String email;
    private String password;
    private double credit;  // فیلد private
    private String subscriptionTier;
    private String subscriptionExpiry;
    private Set<Integer> purchasedSongs = new HashSet<>();

    // سازنده
    public UserSnapshot(String username) {
        this.username = username;
    }

    // گتر و ستر برای username
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    // گتر و ستر برای credit (برای دسترسی به credit)
    public double getCredit() {
        return credit;
    }

    public void setCredit(double credit) {
        this.credit = credit;
    }

    // گتر و ستر برای subscriptionTier
    public String getSubscriptionTier() {
        return subscriptionTier;
    }

    public void setSubscriptionTier(String subscriptionTier) {
        this.subscriptionTier = subscriptionTier;
    }

    // گتر و ستر برای subscriptionExpiry
    public String getSubscriptionExpiry() {
        return subscriptionExpiry;
    }

    public void setSubscriptionExpiry(String subscriptionExpiry) {
        this.subscriptionExpiry = subscriptionExpiry;
    }

    // گتر و ستر برای purchasedSongs
    public Set<Integer> getPurchasedSongs() {
        return purchasedSongs;
    }

    public void addPurchasedSong(int songId) {
        purchasedSongs.add(songId);
    }

    // گتر و ستر برای password
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    // گتر و ستر برای email
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
