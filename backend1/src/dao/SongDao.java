package backend.dao;

import backend.database.DatabaseManager;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SongDao {
    private Connection connection;

    public SongDao() {
        this.connection = DatabaseManager.getConnection();
    }

    // افزودن آهنگ به دیتابیس
    public void addSong(String title, String artist, double rating, double price, String coverPath) {
        String sql = "INSERT INTO songs (title, artist, rating, price, cover_path) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, title);
            stmt.setString(2, artist);
            stmt.setDouble(3, rating);
            stmt.setDouble(4, price);
            stmt.setString(5, coverPath);
            stmt.executeUpdate();
            System.out.println("✅ Song added to database.");
        } catch (SQLException e) {
            System.err.println("❌ Failed to add song: " + e.getMessage());
        }
    }

    // گرفتن لیست آهنگ‌ها
    public List<String> getAllSongs() {
        List<String> songs = new ArrayList<>();
        String sql = "SELECT * FROM songs";
        try (Statement stmt = connection.createStatement()) {
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                songs.add(rs.getString("title") + " by " + rs.getString("artist"));
            }
        } catch (SQLException e) {
            System.err.println("❌ Failed to get songs: " + e.getMessage());
        }
        return songs;
    }
}
