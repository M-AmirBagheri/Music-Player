package backend.services;

import backend.filedb.UserFileStore;
import backend.dao.SongDao;
import backend.protocol.Responses;
import backend.model.Song;

public class ShopService {
    private final UserFileStore store;
    private final SongDao songDao;

    public ShopService() {
        this.store = new UserFileStore();
        this.songDao = new SongDao();
    }

    // خرید آهنگ
    public String purchase(String username, int songId) {
        try {
            // بررسی موجودیت آهنگ
            Song song = songDao.getSongById(songId);
            if (song == null) return Responses.error("SONG_NOT_FOUND");

            // بررسی خرید قبلی
            if (store.hasPurchased(username, songId)) {
                return Responses.success("ALREADY_OWNED");
            }

            // بررسی اعتبار کاربر
            double userCredit = store.load(username).credit;
            if (song.price > userCredit) {
                return Responses.error("NOT_ENOUGH_CREDIT");
            }

            // کسر اعتبار و ثبت خرید
            store.updateCredit(username, -song.price);
            store.appendPurchase(username, songId);
            return Responses.success("PURCHASE_OK");

        } catch (Exception e) {
            return Responses.error("SERVER_ERROR");
        }
    }
}
