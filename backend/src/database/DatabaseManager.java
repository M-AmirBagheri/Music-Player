package database;

import java.sql.*;

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

}
