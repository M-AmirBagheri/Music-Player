package backend.model;

public class Rating {
    private int songId;
    private String username;
    private int rating;

    public Rating(int songId, String username, int rating) {
        this.songId = songId;
        this.username = username;
        this.rating = rating;
    }

    public int getSongId() {
        return songId;
    }

    public void setSongId(int songId) {
        this.songId = songId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }
}
