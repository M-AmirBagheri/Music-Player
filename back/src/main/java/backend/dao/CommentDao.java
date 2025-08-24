package backend.dao;

import backend.database.DatabaseManager;
import backend.model.Comment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDao {

    private Connection connection;

    public CommentDao() {
        this.connection = DatabaseManager.getConnection();
    }

    // افزودن یک نظر جدید برای آهنگ
    public boolean addComment(int songId, String username, String commentText) {
        String sql = "INSERT INTO comments (song_id, username, comment_text) VALUES (?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, songId);
            stmt.setString(2, username);
            stmt.setString(3, commentText);
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error adding comment: " + e.getMessage());
            return false;
        }
    }

    // دریافت تمامی نظرات یک آهنگ
    public List<Comment> getCommentsForSong(int songId) {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT username, comment_text FROM comments WHERE song_id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, songId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                comments.add(new Comment(songId, rs.getString("username"), rs.getString("comment_text")));
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting comments for song: " + e.getMessage());
        }
        return comments;
    }

    // حذف یک نظر
    public boolean deleteComment(int songId, String username) {
        String sql = "DELETE FROM comments WHERE song_id = ? AND username = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, songId);
            stmt.setString(2, username);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error deleting comment: " + e.getMessage());
            return false;
        }
    }
}
