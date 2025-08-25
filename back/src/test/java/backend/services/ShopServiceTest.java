package backend.services;

import backend.filedb.UserFileStore;
import backend.model.Song;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ShopServiceTest {

    private ShopService shopService;
    private UserFileStore userStore;

    @BeforeEach
    void setUp() {
        userStore = new UserFileStore();
        shopService = new ShopService();

        // ایجاد یک کاربر تستی با اعتبار
        String username = "testUser";
        if (!userStore.exists(username)) {
            userStore.createUser(username, "test@example.com", "password123");
            userStore.updateCredit(username, 100.0); // اضافه کردن اعتبار
        }
    }

    @Test
    void testPurchaseSongSuccess() {
        // فرض کنیم آهنگی با شناسه 1 وجود دارد
        int songId = 1;
        String username = "testUser";

        String result = shopService.purchase(username, songId);
        assertEquals("SUCCESS;PURCHASE_OK", result);
    }

    @Test
    void testPurchaseSongAlreadyOwned() {
        int songId = 1;
        String username = "testUser";

        // خرید آهنگ برای بار اول
        shopService.purchase(username, songId);

        // خرید همان آهنگ دوباره
        String result = shopService.purchase(username, songId);
        assertEquals("ERROR;ALREADY_OWNED", result);
    }

    @Test
    void testPurchaseSongInsufficientCredit() {
        int songId = 2;
        String username = "testUser";

        // اعتبار کاربر را صفر می‌کنیم
        userStore.updateCredit(username, -100.0);

        String result = shopService.purchase(username, songId);
        assertEquals("ERROR;NOT_ENOUGH_CREDIT", result);
    }
}
