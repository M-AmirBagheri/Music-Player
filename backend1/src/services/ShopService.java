package backend.services;

import backend.dao.SongDao;
import backend.filedb.UserFileStore;
import backend.models.Song;
import backend.models.UserSnapshot;
import backend.protocol.Responses;

public class ShopService {
    private final SongDao songDao = new SongDao();
    private final UserFileStore store = new UserFileStore();

    public String purchase(String username, int songId) {
        try {
            Song s = songDao.getSongById(songId);
            if (s == null) return Responses.error("SONG_NOT_FOUND");
            if (store.hasPurchased(username, songId)) return Responses.ok("ALREADY_OWNED");

            UserSnapshot u = store.load(username);
            if (u == null) return Responses.error("USER_NOT_FOUND");

            boolean allowedFree = s.isFree || "premium".equalsIgnoreCase(u.subscriptionTier) || s.price <= 0.0;
            if (!allowedFree) {
                if (u.credit < s.price) return Responses.error("NOT_ENOUGH_CREDIT");
                store.updateCredit(username, -s.price);
            }
            store.appendPurchase(username, songId);
            return "PURCHASE_OK;" + backend.util.JsonUtil.toJson(store.load(username));
        } catch (Exception e) {
            return Responses.error("SERVER_ERROR");
        }
    }
}
