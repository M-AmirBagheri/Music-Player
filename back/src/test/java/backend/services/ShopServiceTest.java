package backend.services;

import backend.filedb.UserFileStore;
import backend.dao.SongDao;
import backend.model.Song;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ShopServiceTest {

    private ShopService shopService;
    private UserFileStore userStore;
    private SongDao songDao;

    @BeforeEach
    void setUp() {
        // مقداردهی به متغیرها
        userStore = new UserFileStore();  // درست مقداردهی
        songDao = new SongDao();  // درست مقداردهی
        shopService = new ShopService();  // درست مقداردهی

        // اضافه کردن آهنگ‌ها به DAO
        songDao.addSong("Song 1", "Artist A", 4.5, 10.0, "/covers/song1.jpg");
        songDao.addSong("Song 2", "Artist B", 4.2, 20.0, "/covers/song2.jpg");

        // ایجاد کاربر و دادن اعتبار کافی
        String username = "testUser";
        if (!userStore.exists(username)) {
            userStore.createUser(username, "test@example.com", "password123");
        }
        userStore.updateCredit(username, 100.0); // اعتبار کافی
    }

    @Test
    void testPurchaseSongSuccess() {
        String result = shopService.purchase("testUser", 1);
        assertEquals("SUCCESS;PURCHASE_OK", result);
    }

    @Test
    void testPurchaseSongAlreadyOwned() {
        shopService.purchase("testUser", 1); // خرید اول
        String result = shopService.purchase("testUser", 1); // خرید دوباره
        assertEquals("ERROR;ALREADY_OWNED", result);
    }

    @Test
    void testPurchaseSongInsufficientCredit() {
        userStore.updateCredit("testUser", -100.0); // کاهش اعتبار
        String result = shopService.purchase("testUser", 2);
        assertEquals("ERROR;NOT_ENOUGH_CREDIT", result);
    }
}
