package backend.services;

import backend.dao.RatingDao;
import backend.protocol.Responses;
import backend.model.Rating;

import java.util.List;


public class RatingService {

    private final RatingDao ratingDao;

    public RatingService() {
        this.ratingDao = new RatingDao();
    }

    // متد برای افزودن امتیاز به آهنگ
    public String rateSong(int songId, String username, int rating) {
        if (rating < 0 || rating > 5) {
            return Responses.error("INVALID_RATING");
        }

        // بررسی و افزودن امتیاز برای آهنگ
        boolean success = ratingDao.addRating(songId, username, rating);
        if (success) {
            return Responses.success("RATING_ADDED");
        } else {
            return Responses.error("RATING_FAILED");
        }
    }

    // متد برای دریافت میانگین امتیاز یک آهنگ
    public String getAverageRating(int songId) {
        double averageRating = ratingDao.getAverageRating(songId);
        if (averageRating == 0.0) {
            return Responses.error("NO_RATINGS_FOUND");
        }
        return Responses.success("AVERAGE_RATING;" + averageRating);
    }

    // متد برای دریافت لیست امتیازها برای یک آهنگ
    public String getRatingsForSong(int songId) {
        List<Rating> ratings = ratingDao.getRatingsForSong(songId);
        if (ratings.isEmpty()) {
            return Responses.error("NO_RATINGS_FOUND");
        }

        StringBuilder sb = new StringBuilder("RATINGS_LIST;");
        for (Rating rating : ratings) {
            sb.append(rating.getUsername()).append(":").append(rating.getRating()).append(";");
        }

        return sb.toString();
    }
}
