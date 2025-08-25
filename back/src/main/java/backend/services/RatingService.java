package backend.services;

import backend.dao.RatingDao;
import backend.dao.SongDao;
import backend.model.Rating;
import backend.model.Song;
import backend.protocol.Responses;
import backend.util.JsonUtil;

import java.util.List;

public class RatingService {

    private final RatingDao ratingDao;
    // اختیاری: برای تست/اعتبارسنجی وجود آهنگ
    private final SongDao songDao;

    /** اجرای عادی برنامه (اعتبارسنجی وجود آهنگ هم انجام می‌شود) */
    public RatingService() {
        this(new SongDao(), new RatingDao());
    }

    /** فقط با RatingDao (اگر نخواستی وجود آهنگ را چک کنی) */
    public RatingService(RatingDao ratingDao) {
        this.ratingDao = ratingDao;
        this.songDao = null;
    }

    /** تزریق کامل برای تست/DI */
    public RatingService(SongDao songDao, RatingDao ratingDao) {
        this.songDao = songDao;
        this.ratingDao = ratingDao;
    }

    /** ثبت/به‌روزرسانی امتیاز یک کاربر برای یک آهنگ */
    public String rateSong(int songId, String username, int rating) {
        // 1..5
        if (rating < 1 || rating > 5) {
            return Responses.error("INVALID_RATING");
        }

        // اگر SongDao داریم، وجود آهنگ را چک کن
        if (songDao != null) {
            Song s = songDao.getSongById(songId);
            if (s == null) return Responses.error("SONG_NOT_FOUND");
        }

        boolean ok = ratingDao.addRating(songId, username, rating); // یا upsert
        return ok ? Responses.success("RATING_ADDED")
                : Responses.error("RATING_FAILED");
    }

    /** میانگین امتیاز یک آهنگ */
    public String getAverageRating(int songId) {
        // اگر SongDao داریم، وجود آهنگ را چک کن (اختیاری)
        if (songDao != null) {
            Song s = songDao.getSongById(songId);
            if (s == null) return Responses.error("SONG_NOT_FOUND");
        }

        double avg = ratingDao.getAverageRating(songId);
        // وقتی هنوز امتیازی ثبت نشده
        if (avg <= 0.0) return Responses.error("NO_RATINGS_FOUND");

        // SUCCESS;AVERAGE_RATING;<value>
        return Responses.success("AVERAGE_RATING;" + avg);
    }

    /** لیست امتیازهای یک آهنگ (JSON) */
    public String getRatingsForSong(int songId) {
        if (songDao != null) {
            Song s = songDao.getSongById(songId);
            if (s == null) return Responses.error("SONG_NOT_FOUND");
        }

        List<Rating> ratings = ratingDao.getRatingsForSong(songId);
        if (ratings == null || ratings.isEmpty()) {
            return Responses.error("NO_RATINGS_FOUND");
        }

        // SUCCESS;RATINGS;<json-array>
        return Responses.success("RATINGS;" + JsonUtil.toJson(ratings));
    }
}
