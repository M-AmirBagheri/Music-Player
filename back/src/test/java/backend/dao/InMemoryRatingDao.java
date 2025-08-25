package backend.dao;

import backend.model.Rating;

import java.util.*;

public class InMemoryRatingDao extends RatingDao {
    // songId -> (username -> rating)
    private final Map<Integer, Map<String, Integer>> store = new HashMap<>();

    @Override
    public boolean addRating(int songId, String username, int rating) {
        store.computeIfAbsent(songId, k -> new HashMap<>()).put(username, rating);
        return true;
    }

    @Override
    public double getAverageRating(int songId) {
        Map<String, Integer> m = store.get(songId);
        if (m == null || m.isEmpty()) return 0.0;
        int sum = 0;
        for (int v : m.values()) sum += v;
        return sum * 1.0 / m.size();
    }

    @Override
    public List<Rating> getRatingsForSong(int songId) {
        Map<String, Integer> m = store.get(songId);
        if (m == null) return Collections.emptyList();
        List<Rating> list = new ArrayList<>();
        for (var e : m.entrySet()) {
            list.add(new Rating(songId, e.getKey(), e.getValue()));
        }
        return list;
    }
}
