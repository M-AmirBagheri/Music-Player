package database;

import java.util.ArrayList;
import java.util.List;

import models.User;
import models.Song;
import models.Comment;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DatabaseManager {

   
    private static final String DB_URL = "jdbc:mysql://localhost:3306/music_app?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456789";

    private Connection connection;

    public DatabaseManager() {
        try {
            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("✅ Connected to MySQL database.");
        } catch (SQLException e) {
            System.err.println("❌ Database connection failed: " + e.getMessage());
        }
    }

    public Connection getConnection() {
        return connection;
    }

    public void close() {
        try {
            if (connection != null) {
                connection.close();
                System.out.println("✅ Connection closed.");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error closing connection: " + e.getMessage());
        }
    }

   

    public User getUser(String username) {
        final String sql = "SELECT * FROM users WHERE username = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getDouble("credit"),
                        rs.getString("subscription")
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getUser(): " + e.getMessage());
        }
        return null;
    }

     public boolean isUsernameTaken(String username) {
        final String sql = "SELECT 1 FROM users WHERE username = ? LIMIT 1";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            System.err.println("Error in isUsernameTaken(): " + e.getMessage());
            return true;
        }
    }

    public boolean isEmailTaken(String email) {
        final String sql = "SELECT 1 FROM users WHERE email = ? LIMIT 1";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            System.err.println("Error in isEmailTaken(): " + e.getMessage());
            return true;
        }
    }

    public boolean addUser(User user) {
        final String sql =
            "INSERT INTO users (username, email, password, credit, subscription) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPassword());
            stmt.setDouble(4, user.getCredit());
            stmt.setString(5, user.getSubscription());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in addUser(): " + e.getMessage());
            return false;
        }
    }

    public User validateLogin(String identifier, String password) {
        final String sql = "SELECT * FROM users WHERE (username = ? OR email = ?) AND password = ? LIMIT 1";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, identifier);
            stmt.setString(2, identifier);
            stmt.setString(3, password); 
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getDouble("credit"),
                        rs.getString("subscription")
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in validateLogin(): " + e.getMessage());
        }
        return null;
    }

    public boolean updateUserCredit(String username, double amount) {
        if (amount == 0) return false;
        final String sql = "UPDATE users SET credit = credit + ? WHERE username = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setDouble(1, amount);
            stmt.setString(2, username);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in updateUserCredit(username): " + e.getMessage());
            return false;
        }
    }

    public boolean deleteUser(int userId) {
        final String sql = "DELETE FROM users WHERE id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in deleteUser(): " + e.getMessage());
            return false;
        }
    }
    


    
    public List<Song> getAllSongs() {
        List<Song> songs = new ArrayList<>();
        final String sql = "SELECT * FROM songs";
        try (PreparedStatement stmt = connection.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                songs.add(new Song(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("artist"),
                    rs.getFloat("rating"),
                    rs.getDouble("price"),
                    rs.getString("cover_path")
                ));
            }
        } catch (SQLException e) {
            System.err.println("Error in getAllSongs(): " + e.getMessage());
        }
        return songs;
    }

    public boolean deleteSong(int songId) {
        final String sql = "DELETE FROM songs WHERE id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, songId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in deleteSong(): " + e.getMessage());
            return false;
        }
    }

     public boolean purchaseSong(String username, int songId) {
        final String findUserSql = "SELECT id, credit FROM users WHERE username = ?";
        final String findSongSql = "SELECT price FROM songs WHERE id = ?";
        final String insertPurchaseSql = "INSERT INTO purchased_songs (user_id, song_id) VALUES (?, ?)";
        final String updateCreditSql = "UPDATE users SET credit = credit - ? WHERE id = ?";

        try {
           
            int userId; double credit;
            try (PreparedStatement s = connection.prepareStatement(findUserSql)) {
                s.setString(1, username);
                try (ResultSet r = s.executeQuery()) {
                    if (!r.next()) return false;
                    userId = r.getInt("id");
                    credit = r.getDouble("credit");
                }
            }

           
            double price;
            try (PreparedStatement s = connection.prepareStatement(findSongSql)) {
                s.setInt(1, songId);
                try (ResultSet r = s.executeQuery()) {
                    if (!r.next()) return false;
                    price = r.getDouble("price");
                }
            }

            if (credit < price) return false;

            boolean oldAuto = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try (PreparedStatement p1 = connection.prepareStatement(insertPurchaseSql);
                 PreparedStatement p2 = connection.prepareStatement(updateCreditSql)) {

                p1.setInt(1, userId); p1.setInt(2, songId); p1.executeUpdate();
                p2.setDouble(1, price); p2.setInt(2, userId); p2.executeUpdate();

                connection.commit();
            } catch (SQLException tx) {
                connection.rollback();
                throw tx;
            } finally {
                connection.setAutoCommit(oldAuto);
            }

            return true;
        } catch (SQLException e) {
            System.err.println("Error in purchaseSong(): " + e.getMessage());
            return false;
        }
    }
    
    public List<Song> getPurchasedSongs(int userId) {
        List<Song> songs = new ArrayList<>();
        final String sql =
            "SELECT s.id, s.title, s.artist, s.rating, s.price, s.cover_path " +
            "FROM purchased_songs ps JOIN songs s ON ps.song_id = s.id " +
            "WHERE ps.user_id = ? ORDER BY ps.purchase_date DESC";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    songs.add(new Song(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getString("artist"),
                        rs.getFloat("rating"),
                        rs.getDouble("price"),
                        rs.getString("cover_path")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getPurchasedSongs(userId): " + e.getMessage());
        }
        return songs;
    }




    public boolean rateSong(int userId, int songId, int rating) {
        if (rating < 0 || rating > 5) return false;

        final String checkSql  = "SELECT id FROM ratings WHERE user_id = ? AND song_id = ?";
        final String insertSql = "INSERT INTO ratings (user_id, song_id, rating) VALUES (?, ?, ?)";
        final String updateSql = "UPDATE ratings SET rating = ? WHERE user_id = ? AND song_id = ?";

        try (PreparedStatement checkStmt = connection.prepareStatement(checkSql)) {
            checkStmt.setInt(1, userId);
            checkStmt.setInt(2, songId);

            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    try (PreparedStatement updateStmt = connection.prepareStatement(updateSql)) {
                        updateStmt.setInt(1, rating);
                        updateStmt.setInt(2, userId);
                        updateStmt.setInt(3, songId);
                        updateStmt.executeUpdate();
                    }
                } else {
                    try (PreparedStatement insertStmt = connection.prepareStatement(insertSql)) {
                        insertStmt.setInt(1, userId);
                        insertStmt.setInt(2, songId);
                        insertStmt.setInt(3, rating);
                        insertStmt.executeUpdate();
                    }
                }
            }

            return true;
        } catch (SQLException e) {
            System.err.println("Error in rateSong(): " + e.getMessage());
            return false;
        }
    }

    public boolean updateSongRating(int songId) {
        final String avgSql = "SELECT COALESCE(AVG(rating), 0) AS avg_rating FROM ratings WHERE song_id = ?";
        final String updSql = "UPDATE songs SET rating = ? WHERE id = ?";
        try (PreparedStatement a = connection.prepareStatement(avgSql)) {
            a.setInt(1, songId);
            double avg = 0;
            try (ResultSet rs = a.executeQuery()) {
                if (rs.next()) avg = rs.getDouble("avg_rating");
            }
            try (PreparedStatement u = connection.prepareStatement(updSql)) {
                u.setDouble(1, avg);
                u.setInt(2, songId);
                return u.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error in updateSongRating(): " + e.getMessage());
            return false;
        }
    }




     public boolean addComment(int userId, int songId, String text) {
        if (text == null || text.trim().isEmpty()) return false;
        final String sql = "INSERT INTO comments (song_id, user_id, text) VALUES (?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, songId);
            stmt.setInt(2, userId);
            stmt.setString(3, text.trim());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in addComment(): " + e.getMessage());
            return false;
        }
    }

    public List<Comment> getCommentsBySong(int songId, String sortBy) {
        String order = "c.created_at DESC";
        if ("most_likes".equalsIgnoreCase(sortBy))      order = "c.likes DESC, c.created_at DESC";
        else if ("most_dislikes".equalsIgnoreCase(sortBy)) order = "c.dislikes DESC, c.created_at DESC";

        final String sql =
            "SELECT c.id, c.song_id, c.user_id, u.username, c.text, c.likes, c.dislikes, c.created_at " +
            "FROM comments c JOIN users u ON c.user_id = u.id " +
            "WHERE c.song_id = ? " +
            "ORDER BY " + order;

        List<Comment> list = new ArrayList<>();
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, songId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new Comment(
                        rs.getInt("id"),
                        rs.getInt("song_id"),
                        rs.getInt("user_id"),
                        rs.getString("username"),
                        rs.getString("text"),
                        rs.getInt("likes"),
                        rs.getInt("dislikes"),
                        rs.getString("created_at")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getCommentsBySong(): " + e.getMessage());
        }
        return list;
    }

    public boolean voteComment(int commentId, int userId, boolean like) {
        String checkSql = "SELECT vote_type FROM comment_votes WHERE comment_id = ? AND user_id = ?";
        String insertSql = "INSERT INTO comment_votes (comment_id, user_id, vote_type) VALUES (?, ?, ?)";
        String updateSql = "UPDATE comment_votes SET vote_type = ? WHERE comment_id = ? AND user_id = ?";

        String updateLikeCount = like
            ? "UPDATE comments SET likes = likes + 1, dislikes = CASE WHEN dislikes > 0 AND ? = 'dislike' THEN dislikes - 1 ELSE dislikes END WHERE id = ?"
            : "UPDATE comments SET dislikes = dislikes + 1, likes = CASE WHEN likes > 0 AND ? = 'like' THEN likes - 1 ELSE likes END WHERE id = ?";

        try {
            String prevVote = null;
            try (PreparedStatement stmt = connection.prepareStatement(checkSql)) {
                stmt.setInt(1, commentId);
                stmt.setInt(2, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        prevVote = rs.getString("vote_type");
                    }
                }
            }

            if (prevVote != null) {
                if ((like && prevVote.equals("like")) || (!like && prevVote.equals("dislike"))) {
                    return false;
                }
                try (PreparedStatement stmt = connection.prepareStatement(updateSql)) {
                    stmt.setString(1, like ? "like" : "dislike");
                    stmt.setInt(2, commentId);
                    stmt.setInt(3, userId);
                    stmt.executeUpdate();
                }
            } else {
                try (PreparedStatement stmt = connection.prepareStatement(insertSql)) {
                    stmt.setInt(1, commentId);
                    stmt.setInt(2, userId);
                    stmt.setString(3, like ? "like" : "dislike");
                    stmt.executeUpdate();
                }
            }

            try (PreparedStatement stmt = connection.prepareStatement(updateLikeCount)) {
                stmt.setString(1, like ? "like" : "dislike");
                stmt.setInt(2, commentId);
                stmt.executeUpdate();
            }

            return true;

        } catch (SQLException e) {
            System.err.println("Error in voteComment(): " + e.getMessage());
            return false;
        }
    }

    public boolean likeComment(int commentId, int userId) {
        return voteComment(commentId, userId, true);
    }

    public boolean dislikeComment(int commentId, int userId) {
        return voteComment(commentId, userId, false);
    }
}
