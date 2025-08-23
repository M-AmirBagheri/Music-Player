package backend.services;

import backend.dao.SongDao;
import backend.protocol.MessageParser;
import backend.protocol.Responses;
import java.util.List;

public class ShopService {

    private SongDao songDao;

    public ShopService() {
        this.songDao = new SongDao();
    }

    // دریافت تمام آهنگ‌های موجود
    public String getAllSongs() {
        List<String> songs = songDao.getAllSongs();
        if (songs.isEmpty()) {
            return Responses.errorResponse("No songs available.");
        }
        return Responses.successResponse(MessageParser.toJson(songs));
    }
    
    // خرید آهنگ
    public String purchaseSong(String username, int songId) {
        
        return Responses.successResponse("Purchase successful.");
    }
}
