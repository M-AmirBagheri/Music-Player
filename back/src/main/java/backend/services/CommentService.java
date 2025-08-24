package backend.services;

import backend.dao.CommentDao;
import backend.protocol.Responses;
import backend.protocol.payloads.CommentReq;

public class CommentService {

    private final CommentDao commentDao;

    public CommentService() {
        this.commentDao = new CommentDao();
    }

    // ارسال نظر جدید
    public String addComment(int songId, String username, String commentText) {
        // افزودن نظر به دیتابیس
        boolean success = commentDao.addComment(songId, username, commentText);
        if (success) {
            return Responses.success("COMMENT_ADDED");
        } else {
            return Responses.error("COMMENT_FAILED");
        }
    }

    // دریافت نظرات یک آهنگ
    public String getComments(int songId) {
        String comments = commentDao.getComments(songId);
        if (comments == null || comments.isEmpty()) {
            return Responses.error("NO_COMMENTS_FOUND");
        }
        return Responses.success("COMMENTS_LIST;"+comments);
    }
}
