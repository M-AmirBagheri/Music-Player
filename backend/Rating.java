public class Rating {
    private int id;
    private int userId;
    private int songId;
    private int rating;

    public Rating(int id, int userId, int songId, int rating) {
        this.id = id;
        this.userId = userId;
        this.songId = songId;
        this.rating = rating;
    }

    public int getId() {
        return id;
    }

    public int getUserId() {
        return userId;
    }

    public int getSongId() {
        return songId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }
}
