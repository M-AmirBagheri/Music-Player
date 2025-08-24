package backend.src.protocol;

import backend.util.JsonUtil;

public class MessageParser {
    public static String[] split(String raw) {
        int k = raw.indexOf(';');
        if (k < 0) return new String[]{ raw, "" };
        return new String[]{ raw.substring(0, k), raw.substring(k + 1) };
    }
    public static <T> T parse(String payload, Class<T> type) {
        return JsonUtil.fromJson(payload == null ? "" : payload, type);
    }
}
