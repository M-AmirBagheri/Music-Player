package backend.model;

public class Song {
    public int id;
    public String title;
    public String artist;
    public double rating;
    public double price;
    public boolean isFree;
    public int downloadCount;
    public String coverPath;
    public String audioBase64; // این فیلد برای ذخیره داده‌های Base64

    public Song() {}
}
