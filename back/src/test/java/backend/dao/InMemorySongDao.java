package backend.dao;

import backend.model.Song;

import java.util.HashMap;
import java.util.Map;

public class InMemorySongDao extends SongDao {
    private final Map<Integer, Song> store = new HashMap<>();
    private int seq = 1;

    // موجود (نسخه با 5 پارامتر)
    public int addSongForTest(String title, String artist, double rating, double price, String coverPath) {
        Song s = new Song();
        s.setId(seq);
        s.setTitle(title);
        s.setArtist(artist);
        s.setRating(rating);
        s.setPrice(price);
        s.setFree(false);
        s.setDownloadCount(0);
        s.setCoverPath(coverPath);
        store.put(seq, s);
        return seq++;
    }

    // ✅ اضافه کن: نسخه‌ای که خودِ Song را می‌گیرد
    public int addSongForTest(Song s) {
        if (s.getId() <= 0) {
            s.setId(seq++);
        } else {
            // اگر از قبل id داشت، شمارنده را جلو ببریم که تداخل پیش نیاید
            seq = Math.max(seq, s.getId() + 1);
        }
        store.put(s.getId(), s);
        return s.getId();
    }

    @Override
    public Song getSongById(int id) {
        return store.get(id);
    }

    @Override
    public boolean incDownloadCount(int id) {
        Song s = store.get(id);
        if (s == null) return false;
        s.setDownloadCount(s.getDownloadCount() + 1);
        return true;
    }

    public void clear() {
        store.clear();
        seq = 1;
    }
}
