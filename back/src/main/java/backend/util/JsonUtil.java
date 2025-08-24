package backend.util;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class JsonUtil {
    private static final Gson G = new GsonBuilder().disableHtmlEscaping().create();
    public static String toJson(Object o) { return G.toJson(o); }
    public static <T> T fromJson(String s, Class<T> c) { return G.fromJson(s, c); }
}
