package database;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DatabaseManager {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/music_app";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456789";

    private Connection connection;

    public DatabaseManager() {
        try {
            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("Connected to MySQL database.");
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
        }
    }

    public Connection getConnection() {
        return connection;
    }

    public void close() {
        try {
            if (connection != null) {
                connection.close();
                System.out.println("Connection closed.");
            }
        } catch (SQLException e) {
            System.err.println("Error closing connection: " + e.getMessage());
        }
    }

    public User getUser(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
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
        } catch (SQLException e) {
            System.err.println("Error in getUser(): " + e.getMessage());
        }
        return null;
    }

    public boolean addUser(User user) {
        String sql = "INSERT INTO users (username, email, password, credit, subscription) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPassword());
            stmt.setDouble(4, user.getCredit());
            stmt.setString(5, user.getSubscription());
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error in addUser(): " + e.getMessage());
            return false;
        }
    }

    public List<Song> getAllSongs() {
        List<Song> songs = new ArrayList<>();
        String sql = "SELECT * FROM songs";
        try (PreparedStatement stmt = connection.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Song song = new Song(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("artist"),
                    rs.getFloat("rating"),
                    rs.getDouble("price"),
                    rs.getString("cover_path")
                );
                songs.add(song);
            }
        } catch (SQLException e) {
            System.err.println("Error in getAllSongs(): " + e.getMessage());
        }
        return songs;
    }

    public boolean purchaseSong(String username, int songId) {
    String findUserSql = "SELECT id, credit FROM users WHERE username = ?";
    String findSongSql = "SELECT price FROM songs WHERE id = ?";
    String insertPurchaseSql = "INSERT INTO purchased_songs (user_id, song_id) VALUES (?, ?)";
    String updateCreditSql = "UPDATE users SET credit = credit - ? WHERE id = ?";

    try {
      
        PreparedStatement userStmt = connection.prepareStatement(findUserSql);
        userStmt.setString(1, username);
        ResultSet userRs = userStmt.executeQuery();

        if (!userRs.next()) return false;
        int userId = userRs.getInt("id");
        double credit = userRs.getDouble("credit");

      
        PreparedStatement songStmt = connection.prepareStatement(findSongSql);
        songStmt.setInt(1, songId);
        ResultSet songRs = songStmt.executeQuery();

        if (!songRs.next()) return false;
        double price = songRs.getDouble("price");

       
        if (credit < price) return false;

       
        PreparedStatement purchaseStmt = connection.prepareStatement(insertPurchaseSql);
        purchaseStmt.setInt(1, userId);
        purchaseStmt.setInt(2, songId);
        purchaseStmt.executeUpdate();

       
        PreparedStatement updateCreditStmt = connection.prepareStatement(updateCreditSql);
        updateCreditStmt.setDouble(1, price);
        updateCreditStmt.setInt(2, userId);
        updateCreditStmt.executeUpdate();

        return true;
    } catch (SQLException e) {
        System.err.println("Error in purchaseSong(): " + e.getMessage());
        return false;
    }
}

}
