package backend.services;

import backend.dao.InMemorySongDao;
import backend.dao.SongDao;
import backend.filedb.UserFileStore;
import backend.util.Passwords;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ShopServiceTest {

    private ShopService shopService;
    private UserFileStore userStore;
    private InMemorySongDao songDao;

    // برای جلوگیری از تداخل فایل کاربر در تست‌ها
    private String makeUser() { return "u_" + UUID.randomUUID().toString().replace("-", "").substring(0, 8); }
    private void deleteUserFile(String username) {
        new File("data/users/" + username + ".txt").delete();
    }

    @BeforeEach
    void setUp() {
        userStore = new UserFileStore();
        songDao   = new InMemorySongDao();
        // ⚠️ نیاز به این سازنده در ShopService دارید (پایین توضیح داده‌ام)
        shopService = new ShopService(userStore, songDao);
    }

    @AfterEach
    void tearDown() {
        // پاکسازی احتمالی فایل‌های کاربر (اختیاری)
        // چون نام‌ها رندوم‌اند، معمولاً تداخلی پیش نمی‌آید.
    }

    @Test
    void testPurchaseSongSuccess() {
        // Arrange
        String username = makeUser();
        userStore.createUser(username, username + "@ex.com", Passwords.hash("p1"));
        userStore.updateCredit(username, 20.0); // اعتبار کافی

        int songId = songDao.addSongForTest("Song A", "Artist", 4.5, 10.0, "cover.jpg");

        // Act
        String res = shopService.purchase(username, songId);

        // Assert
        assertEquals("SUCCESS;PURCHASE_OK", res);
    }

    @Test
    void testPurchaseSongAlreadyOwned() {
        String username = makeUser();
        userStore.createUser(username, username + "@ex.com", Passwords.hash("p1"));
        userStore.updateCredit(username, 50.0);

        int songId = songDao.addSongForTest("Song B", "Artist", 4.2, 12.0, "cover.jpg");
        userStore.appendPurchase(username, songId); // قبلاً خریده

        String res = shopService.purchase(username, songId);

        // اگر در ShopService برای این حالت ERROR برمی‌گردانی، انتظار را "ERROR;ALREADY_OWNED" بگذار.
        assertEquals("SUCCESS;ALREADY_OWNED", res);
    }

    @Test
    void testPurchaseSongInsufficientCredit() {
        String username = makeUser();
        userStore.createUser(username, username + "@ex.com", Passwords.hash("p1"));
        userStore.updateCredit(username, 5.0); // اعتبار ناکافی

        int songId = songDao.addSongForTest("Song C", "Artist", 4.8, 15.0, "cover.jpg");

        String res = shopService.purchase(username, songId);

        assertEquals("ERROR;NOT_ENOUGH_CREDIT", res);
    }

    @Test
    void testPurchaseSongNotFound() {
        String username = makeUser();
        userStore.createUser(username, username + "@ex.com", Passwords.hash("p1"));
        userStore.updateCredit(username, 100.0);

        int invalidSongId = 9999; // در InMemorySongDao وجود ندارد

        String res = shopService.purchase(username, invalidSongId);

        assertEquals("ERROR;SONG_NOT_FOUND", res);
    }
}
