package backend.services;

import backend.filedb.UserFileStore;
import backend.model.UserSnapshot;
import backend.protocol.Responses;

import java.time.LocalDate;

public class PaymentService {
    private final UserFileStore store = new UserFileStore();

    public String topup(String username, double amount) {
        try {
            if (amount <= 0) return Responses.error("BAD_AMOUNT");
            boolean ok = store.updateCredit(username, amount);
            if (!ok) return Responses.error("USER_NOT_FOUND");
            return "USER;" + backend.util.JsonUtil.toJson(store.load(username));
        } catch (Exception e) { return Responses.error("SERVER_ERROR"); }
    }

    public String subscribe(String username, String plan) {
        try {
            int months = switch (plan) { case "monthly" -> 1; case "3m" -> 3; case "yearly" -> 12; default -> 0; };
            if (months == 0) return Responses.error("BAD_PLAN");
            LocalDate exp = LocalDate.now().plusMonths(months);
            boolean ok = store.setSubscription(username, "premium", exp.toString());
            if (!ok) return Responses.error("USER_NOT_FOUND");
            return "USER;" + backend.util.JsonUtil.toJson(store.load(username));
        } catch (Exception e) { return Responses.error("SERVER_ERROR"); }
    }

    // به‌روزرسانی اشتراک
    public String setSubscription(String username, String plan, String expiry) {
        // بارگذاری اطلاعات کاربر
        UserSnapshot user = store.load(username);
        if (user == null) {
            return Responses.userNotFound();  // اگر کاربر وجود نداشته باشد
        }

        // به‌روزرسانی اطلاعات اشتراک
        boolean success = store.setSubscription(username, plan, expiry);
        if (success) {
            return Responses.success("SUBSCRIPTION_SET");
        } else {
            return Responses.error("SUBSCRIPTION_FAILED");
        }
    }

}
