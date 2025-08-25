package backend.services;

import backend.dao.SongDao;
import backend.filedb.UserFileStore;
import backend.model.Song;
import backend.protocol.Responses;

public class ShopService {

    private final UserFileStore store;
    private final SongDao songDao;

    /** سازنده پیش‌فرض برای اجرای عادی برنامه */
    public ShopService() {
        this(new UserFileStore(), new SongDao());
    }

    /** سازنده مخصوص تست: وابستگی‌ها را از بیرون تزریق می‌کنیم */
    public ShopService(UserFileStore store, SongDao songDao) {
        this.store = store;
        this.songDao = songDao;
    }

    /** خرید آهنگ */
    public String purchase(String username, int songId) {
        Song song = songDao.getSongById(songId);
        if (song == null) return Responses.error("SONG_NOT_FOUND");

        if (store.hasPurchased(username, songId)) {
            // اگر قبلاً خریده، خروجی را طبق قراردادی که گذاشتیم برگردان
            return Responses.success("ALREADY_OWNED");
        }

        var snapshot = store.load(username);
        if (snapshot == null) return Responses.error("USER_NOT_FOUND");

        double credit = snapshot.getCredit();
        if (song.getPrice() > credit) {
            return Responses.error("NOT_ENOUGH_CREDIT");
        }

        boolean ok1 = store.updateCredit(username, -song.getPrice());
        boolean ok2 = store.appendPurchase(username, songId);
        if (!ok1 || !ok2) return Responses.error("SERVER_ERROR");

        return Responses.success("PURCHASE_OK");
    }
}
