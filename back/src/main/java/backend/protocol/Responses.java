package backend.protocol;

public class Responses {

    public static String success(String message) {
        return "SUCCESS;" + message;
    }

    public static String error(String error) {
        return "ERROR;" + error;
    }

    // خطاهای استاندارد
    public static String badRequest() {
        return error("BAD_REQUEST");
    }

    public static String userNotFound() {
        return error("USER_NOT_FOUND");
    }

    public static String serverError() {
        return error("SERVER_ERROR");
    }
}
