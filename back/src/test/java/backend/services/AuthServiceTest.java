package backend.services;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AuthServiceTest {

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService();  // ایجاد نمونه جدید از AuthService
    }

    @Test
    void testLoginSuccess() {
        // ثبت‌نام کاربر برای ورود
        authService.register("testUser", "test@example.com", "password123");

        // تست ورود موفق
        String result = authService.login("testUser", "password123");
        assertEquals("SUCCESS;LOGIN_OK", result);
    }

    @Test
    void testLoginFailure() {
        // تلاش برای ورود با نام کاربری و پسورد اشتباه
        String result = authService.login("nonExistentUser", "wrongPassword");
        assertEquals("ERROR;USER_NOT_FOUND", result);
    }

}
