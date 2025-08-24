package backend.src.model;

import java.util.ArrayList;
import java.util.List;

public class UserSnapshot {
    public String username;
    public String email;
    public double credit;
    public String subscriptionTier;   // none | premium
    public String subscriptionExpiry; // YYYY-MM-DD یا خالی
    public List<Integer> purchased = new ArrayList<>();
}
