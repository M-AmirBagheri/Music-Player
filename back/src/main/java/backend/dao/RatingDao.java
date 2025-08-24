package backend.dao;

import backend.database.DatabaseManager;
import backend.model.Rating;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RatingDao {

    private Connection connection;

    public RatingDao() {
        this.connection = DatabaseManager.getConnection();
    }

    // افزودن امتیاز برای آهنگ
    public boolean addRating(int songId, String username, int rating) {
        String sql = "INSERT INTO ratings (song_id, username, rating) VALUES (?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, songId);
            stmt.setString(2, username);
            stmt.setInt(3, rating);
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error adding rating: " + e.getMessage());
            return false;
        }
    }

    // دریافت میانگین امتیاز یک آهنگ
    public double getAverageRating(int songId) {
        String sql = "SELECT AVG(rating) FROM ratings WHERE song_id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, songId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting average rating: " + e.getMessage());
        }
        return 0.0;
    }

    // دریافت تمامی امتیازهای یک آهنگ
    public List<Rating> getRatingsForSong(int songId) {
        List<Rating> ratings = new ArrayList<>();
        String sql = "SELECT username, rating FROM ratings WHERE song_id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, songId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                ratings.add(new Rating(songId, rs.getString("username"), rs.getInt("rating")));
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting ratings for song: " + e.getMessage());
        }
        return ratings;
    }
}
