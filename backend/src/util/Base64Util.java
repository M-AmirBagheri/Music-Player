package backend.src.util;

public class Base64Util {
    public static String[] chunk(String base64, int chunkSize) {
        int len = base64.length();
        int n = (len + chunkSize - 1) / chunkSize;
        String[] parts = new String[n];
        for (int i = 0, off = 0; i < n; i++, off += chunkSize) {
            parts[i] = base64.substring(off, Math.min(off + chunkSize, len));
        }
        return parts;
    }
}
