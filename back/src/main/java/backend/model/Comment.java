package backend.model;

public class Comment {
    private int songId;
    private String username;
    private String commentText;

    // سازنده
    public Comment(int songId, String username, String commentText) {
        this.songId = songId;
        this.username = username;
        this.commentText = commentText;
    }

    // گتر و ستر برای songId
    public int getSongId() {
        return songId;
    }

    public void setSongId(int songId) {
        this.songId = songId;
    }

    // گتر و ستر برای username
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    // گتر و ستر برای commentText
    public String getCommentText() {
        return commentText;
    }

    public void setCommentText(String commentText) {
        this.commentText = commentText;
    }
}
