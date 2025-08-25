package backend.dao;

import backend.database.DatabaseManager;
import backend.model.Song;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SongDao {
    private final Connection connection;

    public SongDao() {
        this.connection = DatabaseManager.getConnection();
    }

    public boolean addSong(String title, String artist, double rating, double price, String coverPath) {
        final String sql = "INSERT INTO songs (title, artist, rating, price, cover_path) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, artist);
            ps.setDouble(3, rating);
            ps.setDouble(4, price);
            ps.setString(5, coverPath);
            return ps.executeUpdate() == 1;
        } catch (SQLException | NullPointerException e) {
            // در تست‌ها ممکنه connection نال باشه
            return false;
        }
    }

    public List<String> getAllSongs() {
        final String sql = "SELECT title, artist FROM songs";
        List<String> songs = new ArrayList<>();
        try (Statement st = connection.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                songs.add(rs.getString("title") + " by " + rs.getString("artist"));
            }
        } catch (SQLException | NullPointerException e) {
            // no-op برای سادگی تست‌ها
        }
        return songs;
    }

    public Song getSongById(int id) {
        final String sql = "SELECT id,title,artist,rating,price,is_free,download_count,cover_path,audio_base64 " +
                "FROM songs WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Song s = new Song();
                    s.setId(rs.getInt("id"));
                    s.setTitle(rs.getString("title"));
                    s.setArtist(rs.getString("artist"));
                    s.setRating(rs.getDouble("rating"));
                    s.setPrice(rs.getDouble("price"));
                    s.setFree(rs.getBoolean("is_free"));
                    s.setDownloadCount(rs.getInt("download_count"));
                    s.setCoverPath(rs.getString("cover_path"));
                    s.setAudioBase64(rs.getString("audio_base64"));
                    return s;
                }
            }
        } catch (SQLException | NullPointerException e) {
            return null;
        }
        return null;
    }

    public boolean incDownloadCount(int id) {
        final String sql = "UPDATE songs SET download_count = download_count + 1 WHERE id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        } catch (SQLException | NullPointerException e) {
            return false;
        }
    }
}
