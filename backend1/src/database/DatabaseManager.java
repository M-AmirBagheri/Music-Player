package backend.database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.io.FileInputStream;
import java.io.IOException;

public class DatabaseManager {
    private static Connection connection;

    static {
        try {
            // بارگذاری تنظیمات از app.properties
            Properties properties = new Properties();
            properties.load(new FileInputStream("app.properties"));
            
            String dbUrl = properties.getProperty("DB_URL");
            String dbUser = properties.getProperty("DB_USER");
            String dbPassword = properties.getProperty("DB_PASSWORD");

            // اتصال به دیتابیس
            connection = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
            System.out.println("✅ Connected to MySQL database.");
        } catch (SQLException | IOException e) {
            System.err.println("❌ Database connection failed: " + e.getMessage());
        }
    }

    public static Connection getConnection() {
        return connection;
    }

    public static void close() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("✅ Connection closed.");
            }
        } catch (SQLException e) {
            System.err.println("❌ Failed to close connection: " + e.getMessage());
        }
    }
}
