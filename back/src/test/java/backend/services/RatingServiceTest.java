package backend.services;

import backend.dao.InMemoryRatingDao;
import backend.dao.InMemorySongDao;
import backend.protocol.Responses;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class RatingServiceTest {

    private InMemorySongDao songDao;
    private InMemoryRatingDao ratingDao;

    @BeforeEach
    void setup() {
        songDao = new InMemorySongDao();
        ratingDao = new InMemoryRatingDao();
    }

    @Test
    void rateSong_success_and_average() {
        int id = songDao.addSongForTest("T", "A", 0.0, 10.0, "c.jpg");
        RatingService svc = new RatingService(songDao, ratingDao);

        assertEquals("SUCCESS;RATING_ADDED", svc.rateSong(id, "ali", 5));
        assertEquals("SUCCESS;RATING_ADDED", svc.rateSong(id, "zahra", 3));

        String avg = svc.getAverageRating(id);
        assertTrue(avg.startsWith("SUCCESS;AVERAGE_RATING;"));
        // می‌تونی parsing و assert دقیق‌تر هم انجام بدی
    }

    @Test
    void rateSong_invalidRating() {
        int id = songDao.addSongForTest("T2", "A2", 0.0, 10.0, "c2.jpg");
        RatingService svc = new RatingService(songDao, ratingDao);

        assertEquals(Responses.error("INVALID_RATING"), svc.rateSong(id, "ali", 0));
        assertEquals(Responses.error("INVALID_RATING"), svc.rateSong(id, "ali", 6));
    }

    @Test
    void rateSong_songNotFound() {
        RatingService svc = new RatingService(songDao, ratingDao);
        assertEquals(Responses.error("SONG_NOT_FOUND"), svc.rateSong(9999, "ali", 4));
        assertEquals(Responses.error("SONG_NOT_FOUND"), svc.getAverageRating(9999));
        assertEquals(Responses.error("SONG_NOT_FOUND"), svc.getRatingsForSong(9999));
    }

    @Test
    void getRatings_json_list() {
        int id = songDao.addSongForTest("T3", "A3", 0.0, 10.0, "c3.jpg");
        RatingService svc = new RatingService(songDao, ratingDao);

        svc.rateSong(id, "u1", 4);
        svc.rateSong(id, "u2", 2);

        String res = svc.getRatingsForSong(id);
        assertTrue(res.startsWith("SUCCESS;RATINGS;"));
        assertTrue(res.contains("\"username\":\"u1\""));
        assertTrue(res.contains("\"rating\":4"));
    }
}
