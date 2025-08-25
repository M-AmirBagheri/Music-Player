package backend.services;

import backend.filedb.UserFileStore;
import backend.model.Song;
import backend.dao.SongDao;
import backend.model.UserSnapshot;
import backend.protocol.Responses;

public class ShopService {

    private UserFileStore userStore = new UserFileStore();  // مقداردهی صحیح
    private SongDao songDao = new SongDao();  // مقداردهی صحیح

    public String purchase(String username, int songId) {
        Song song = songDao.getSongById(songId);  // گرفتن اطلاعات آهنگ از DAO
        if (song == null) {
            return Responses.error("SONG_NOT_FOUND");
        }

        // بارگذاری اطلاعات کاربر
        UserSnapshot user = userStore.load(username);
        if (user == null) {
            return Responses.error("USER_NOT_FOUND");
        }

        // بررسی اینکه کاربر قبلاً آهنگ را خریداری کرده است
        if (user.hasPurchased(songId)) {
            return Responses.error("ALREADY_OWNED");
        }

        // بررسی اعتبار کاربر
        if (user.getCredit() < song.getPrice()) {
            return Responses.error("NOT_ENOUGH_CREDIT");
        }

        // خرید آهنگ
        userStore.updateCredit(username, -song.getPrice());
        userStore.appendPurchase(username, songId);
        return Responses.success("PURCHASE_OK");
    }
}
