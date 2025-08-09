package database;

import java.util.ArrayList;
import java.util.List;

import models.User;
import models.Song;

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

    

    public boolean purchaseSong(String username, int songId) {
        final String findUserSql = "SELECT id, credit FROM users WHERE username = ?";
        final String findSongSql = "SELECT price FROM songs WHERE id = ?";
        final String insertPurchaseSql = "INSERT INTO purchased_songs (user_id, song_id) VALUES (?, ?)";
        final String updateCreditSql = "UPDATE users SET credit = credit - ? WHERE id = ?";

        try {
            
            int userId;
            double credit;
            try (PreparedStatement userStmt = connection.prepareStatement(findUserSql)) {
                userStmt.setString(1, username);
                try (ResultSet userRs = userStmt.executeQuery()) {
                    if (!userRs.next()) return false;
                    userId = userRs.getInt("id");
                    credit = userRs.getDouble("credit");
                }
            }

            
            double price;
            try (PreparedStatement songStmt = connection.prepareStatement(findSongSql)) {
                songStmt.setInt(1, songId);
                try (ResultSet songRs = songStmt.executeQuery()) {
                    if (!songRs.next()) return false;
                    price = songRs.getDouble("price");
                }
            }

            
            if (credit < price) return false;

            
            boolean oldAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try (PreparedStatement purchaseStmt = connection.prepareStatement(insertPurchaseSql);
                 PreparedStatement updateCreditStmt = connection.prepareStatement(updateCreditSql)) {

                purchaseStmt.setInt(1, userId);
                purchaseStmt.setInt(2, songId);
                purchaseStmt.executeUpdate();

                updateCreditStmt.setDouble(1, price);
                updateCreditStmt.setInt(2, userId);
                updateCreditStmt.executeUpdate();

                connection.commit();
            } catch (SQLException txErr) {
                connection.rollback();
                throw txErr;
            } finally {
                connection.setAutoCommit(oldAutoCommit);
            }

            return true;
        } catch (SQLException e) {
            System.err.println("Error in purchaseSong(): " + e.getMessage());
            return false;
        }
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

    public List<Song> getPurchasedSongs(String username) {
        final String findUserSql = "SELECT id FROM users WHERE username = ?";
        try (PreparedStatement stmt = connection.prepareStatement(findUserSql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    return getPurchasedSongs(userId);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getPurchasedSongs(username): " + e.getMessage());
        }
        return new ArrayList<>();
    }

}
