package backend.services;

import backend.dao.CommentDao;
import backend.protocol.Responses;

public class CommentService {

    private CommentDao commentDao;

    public CommentService() {
        this.commentDao = new CommentDao();
    }

    // ارسال نظر جدید
    public String addComment(int songId, String username, String commentText) {
        // افزودن نظر به دیتابیس
        commentDao.addComment(songId, username, commentText);
        return Responses.successResponse("Comment added.");
    }

    // دریافت نظرات یک آهنگ
    public String getComments(int songId) {
        // دریافت نظرات
        String comments = commentDao.getComments(songId);
        if (comments == null) {
            return Responses.errorResponse("No comments found.");
        }
        return Responses.successResponse(comments);
    }
}
