package backend.services;

import backend.dao.UserDao;
import backend.protocol.Responses;
import backend.protocol.MessageParser;
import backend.database.DatabaseManager;
import java.sql.*;

public class AuthService {

    private UserDao userDao;

    public AuthService() {
        this.userDao = new UserDao();
    }

    // ثبت‌نام کاربر جدید
    public String registerUser(String username, String password, String email) {
        if (userDao.usernameExists(username)) {
            return Responses.errorResponse("Username already exists.");
        }

        if (userDao.emailExists(email)) {
            return Responses.errorResponse("Email already exists.");
        }

        // ثبت اطلاعات در دیتابیس
        userDao.addUser(username, password, email);
        return Responses.successResponse("Registration successful.");
    }

    // ورود کاربر
    public String loginUser(String usernameOrEmail, String password) {
        if (!userDao.usernameExists(usernameOrEmail) && !userDao.emailExists(usernameOrEmail)) {
            return Responses.errorResponse("User not found.");
        }

        if (!userDao.verifyPassword(usernameOrEmail, password)) {
            return Responses.errorResponse("Incorrect password.");
        }

        return Responses.successResponse("Login successful.");
    }
}
