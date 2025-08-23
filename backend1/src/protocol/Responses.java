package backend.protocol;

public class Responses {

    // ساخت پاسخ‌های عمومی
    public static String successResponse(String message) {
        return "SUCCESS;" + message;
    }

    public static String errorResponse(String error) {
        return "ERROR;" + error;
    }
}
