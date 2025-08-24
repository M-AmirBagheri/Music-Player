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

        // حالا دوباره تلاش می‌کنیم که همان کاربر را ثبت‌نام کنیم
        result = authService.register("testUser", "test@example.com", "password123");
        assertEquals("ERROR;USERNAME_EXISTS", result);  // این بار باید خطای "کاربر از قبل موجود است" دریافت کنیم
    }
}
