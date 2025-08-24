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
    void testRegister() {
        String result = authService.register("testUser", "test@example.com", "password123");
        assertEquals("SUCCESS;REGISTER_OK", result);  // فرض بر این است که پاسخ ثبت‌نام موفق باشد
    }

    @Test
    void testLoginSuccess() {
        // ثبت‌نام کاربر
        authService.register("testUser", "test@example.com", "password123");

        // تست ورود موفق
        String result = authService.login("testUser", "password123");
        assertEquals("SUCCESS;LOGIN_OK", result);
    }

    @Test
    void testLoginFailure() {
        // ورود با نام کاربری یا پسورد اشتباه
        String result = authService.login("nonExistentUser", "wrongPassword");
        assertEquals("ERROR;USER_NOT_FOUND", result);
    }
}
