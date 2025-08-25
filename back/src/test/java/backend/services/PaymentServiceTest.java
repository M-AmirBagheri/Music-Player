package backend.services;

import backend.filedb.UserFileStore;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class PaymentServiceTest {

    private PaymentService paymentService;

    @BeforeEach
    void setUp() {
        paymentService = new PaymentService();
    }

    @Test
    void testSetSubscription() {
        // ایجاد کاربر جدید
        String username = "testUser";
        String plan = "premium";
        String expiry = "2025-12-31";

        // ارتقاء اشتراک کاربر
        String result = paymentService.setSubscription(username, plan, expiry);
        assertEquals("SUCCESS;SUBSCRIPTION_SET", result);
    }

    @Test
    void testSetSubscriptionForNonExistentUser() {
        // تلاش برای ارتقاء اشتراک کاربری که وجود ندارد
        String result = paymentService.setSubscription("nonExistentUser", "premium", "2025-12-31");
        assertEquals("ERROR;USER_NOT_FOUND", result);
    }
}
