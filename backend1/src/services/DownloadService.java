package backend.services;

import backend.dao.SongDao;
import backend.protocol.MessageParser;
import backend.protocol.Responses;
import java.sql.*;

public class DownloadService {

    private SongDao songDao;

    public DownloadService() {
        this.songDao = new SongDao();
    }

    // دانلود آهنگ به صورت قطعه‌قطعه (chunked)
    public String downloadSong(int songId) {
        // دریافت اطلاعات آهنگ
        String song = songDao.getSongById(songId);
        if (song == null) {
            return Responses.errorResponse("Song not found.");
        }

        String audioBase64 = getSongAudioBase64(songId);

        return sendChunks(audioBase64);
    }

    private String getSongAudioBase64(int songId) {
        
        return "base64_encoded_audio_data";
    }

    private String sendChunks(String audioBase64) {
        
        return Responses.successResponse("Sending audio in chunks.");
    }
}
