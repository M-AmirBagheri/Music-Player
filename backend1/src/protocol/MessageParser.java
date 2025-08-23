package backend.protocol;

import com.google.gson.Gson;

public class MessageParser {

    private static final Gson gson = new Gson();

    // تجزیه پیام به دستور و payload
    public static Command parseCommand(String message) {
        String command = message.split(";")[0];
        return Command.valueOf(command);
    }

    // تجزیه JSON به شیء
    public static <T> T parseJson(String json, Class<T> classOfT) {
        return gson.fromJson(json, classOfT);
    }

    // ساخت پیام به صورت string
    public static String toJson(Object obj) {
        return gson.toJson(obj);
    }
}
