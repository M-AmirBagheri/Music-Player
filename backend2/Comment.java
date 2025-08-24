public class Comment {
    private int id;
    private int userId;
    private int songId;
    private String text;
    private int likeCount;
    private int dislikeCount;
    private String createdAt;

    public Comment(int id, int userId, int songId, String text, int likeCount, int dislikeCount, String createdAt) {
        this.id = id;
        this.userId = userId;
        this.songId = songId;
        this.text = text;
        this.likeCount = likeCount;
        this.dislikeCount = dislikeCount;
        this.createdAt = createdAt;
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

    public String getText() {
        return text;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public int getDislikeCount() {
        return dislikeCount;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setText(String text) {
        this.text = text;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }

    public void setDislikeCount(int dislikeCount) {
        this.dislikeCount = dislikeCount;
    }
}
