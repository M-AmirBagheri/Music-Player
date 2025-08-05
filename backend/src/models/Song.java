package models;

public class Song {
    private int id;
    private String title;
    private String artist;
    private float rating;
    private double price;
    private String coverPath;

    public Song(int id, String title, String artist, float rating, double price, String coverPath) {
        this.id = id;
        this.title = title;
        this.artist = artist;
        this.rating = rating;
        this.price = price;
        this.coverPath = coverPath;
    }

    public int getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getArtist() {
        return artist;
    }

    public float getRating() {
        return rating;
    }

    public double getPrice() {
        return price;
    }

    public String getCoverPath() {
        return coverPath;
    }

    public void setRating(float rating) {
        this.rating = rating;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public void setCoverPath(String coverPath) {
        this.coverPath = coverPath;
    }
}
