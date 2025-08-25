package backend.dao;

import backend.model.Song;
import java.util.HashMap;
import java.util.Map;

/** DAO درون‌حافظه‌ای برای تست‌ها (بدون اتصال DB) */
public class InMemorySongDao extends SongDao {

    private final Map<Integer, Song> store = new HashMap<>();
    private int seq = 1;

    /** فقط برای تست: آهنگ می‌سازد و id برمی‌گرداند */
    public int addSongForTest(String title, String artist, double rating, double price, String coverPath) {
        Song s = new Song();     // Song شما فیلدهای عمومی دارد
        s.id = seq;
        s.title = title;
        s.artist = artist;
        s.rating = rating;
        s.price = price;
        s.isFree = false;
        s.downloadCount = 0;
        s.coverPath = coverPath;
        store.put(seq, s);
        return seq++;
    }

    @Override
    public Song getSongById(int id) {
        return store.get(id);
    }

    @Override
    public boolean incDownloadCount(int id) {
        Song s = store.get(id);
        if (s == null) return false;
        s.downloadCount++;
        return true;
    }
}
