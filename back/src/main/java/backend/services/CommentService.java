package backend.services;

import backend.dao.CommentDao;
import backend.protocol.Responses;
import backend.model.Comment;

import java.util.List;

public class CommentService {

    private final CommentDao commentDao;

    public CommentService() {
        this.commentDao = new CommentDao();
    }

    // افزودن نظر جدید
    public String addComment(int songId, String username, String commentText) {
        boolean success = commentDao.addComment(songId, username, commentText);
        if (success) {
            return Responses.success("COMMENT_ADDED");
        } else {
            return Responses.error("COMMENT_FAILED");
        }
    }

    // دریافت نظرات برای یک آهنگ
    public String getCommentsForSong(int songId) {
        List<Comment> comments = commentDao.getComments(songId);
        if (comments.isEmpty()) {
            return Responses.error("NO_COMMENTS_FOUND");
        }

        StringBuilder sb = new StringBuilder("COMMENTS_LIST;");
        for (Comment comment : comments) {
            sb.append(comment.getUsername()).append(":").append(comment.getCommentText()).append(";");
        }

        return sb.toString();
    }
}
