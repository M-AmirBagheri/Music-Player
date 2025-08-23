package backend.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class Config {
    private static final Properties P = new Properties();
    static {
        try { P.load(new FileInputStream("app.properties")); }
        catch (IOException e) { throw new RuntimeException("Cannot load app.properties", e); }
    }
    public static String get(String k) { return P.getProperty(k); }
    public static int getInt(String k, int def) {
        try { return Integer.parseInt(P.getProperty(k, Integer.toString(def))); }
        catch (Exception e) { return def; }
    }
}
