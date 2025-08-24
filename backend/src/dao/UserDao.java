package backend.src.dao;

import backend.src.database.DatabaseManager;
import java.sql.*;

public class UserDao {

    private Connection connection;

    public UserDao() {
        this.connection = DatabaseManager.getConnection();
    }

    // بررسی اینکه نام‌کاربری وجود دارد یا نه
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error checking username: " + e.getMessage());
        }
        return false;
    }

    // بررسی اینکه ایمیل وجود دارد یا نه
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error checking email: " + e.getMessage());
        }
        return false;
    }

    // اضافه کردن کاربر جدید
    public void addUser(String username, String password, String email) {
        String sql = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setString(2, password); // در اینجا باید هش پسورد استفاده کنید
            stmt.setString(3, email);
            stmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("❌ Error adding user: " + e.getMessage());
        }
    }

    // تایید پسورد کاربر
    public boolean verifyPassword(String usernameOrEmail, String password) {
        String sql = "SELECT password FROM users WHERE username = ? OR email = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, usernameOrEmail);
            stmt.setString(2, usernameOrEmail);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                // در اینجا باید از BCrypt برای تایید پسورد استفاده کنید
                return rs.getString("password").equals(password);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error verifying password: " + e.getMessage());
        }
        return false;
    }
}
