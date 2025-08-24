package backend.dao;

import backend.database.DatabaseManager;
import backend.model.Song;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SongDao {
    private final Connection connection = DatabaseManager.getConnection();

    public void addSong(String title, String artist, double rating, double price, String coverPath) {
        String sql = "INSERT INTO songs (title, artist, rating, price, cover_path) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, title);
            stmt.setString(2, artist);
            stmt.setDouble(3, rating);
            stmt.setDouble(4, price);
            stmt.setString(5, coverPath);
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public List<String> getAllSongs() {
        List<String> songs = new ArrayList<>();
        String sql = "SELECT title, artist FROM songs";
        try (Statement st = connection.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) songs.add(rs.getString(1) + " by " + rs.getString(2));
        } catch (SQLException e) { e.printStackTrace(); }
        return songs;
    }

    public Song getSongById(int id) {
        String sql = "SELECT id,title,artist,rating,price,is_free,download_count,cover_path,audio_base64 FROM songs WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Song s = new Song();
                    s.id = rs.getInt("id");
                    s.title = rs.getString("title");
                    s.artist = rs.getString("artist");
                    s.rating = rs.getDouble("rating");
                    s.price = rs.getDouble("price");
                    s.isFree = rs.getBoolean("is_free");
                    s.downloadCount = rs.getInt("download_count");
                    s.coverPath = rs.getString("cover_path");
                    s.audioBase64 = rs.getString("audio_base64"); // اگر TEXT/LONGTEXT
                    return s;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean incDownloadCount(int id) {
        String sql = "UPDATE songs SET download_count=download_count+1 WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
