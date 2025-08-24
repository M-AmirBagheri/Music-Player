package backend.protocol;

public class Responses {
    public static String ok(String msg) { return "OK;" + msg; }
    public static String error(String code) { return "ERROR;" + code; }
}
