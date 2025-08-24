package backend.services;

import backend.model.Song;
import backend.dao.SongDao;
import backend.protocol.Responses;
import backend.util.Base64Util;

import java.io.PrintWriter;

public class DownloadService {

    private final SongDao songDao;

    public DownloadService() {
        this.songDao = new SongDao();
    }

    // ارسال آهنگ به صورت chunk
    public void sendSongChunks(PrintWriter out, int songId) {
        try {
            // دریافت آهنگ از دیتابیس
            Song song = songDao.getSongById(songId);
            if (song == null || song.audioBase64 == null) {
                out.println(Responses.error("SONG_NOT_FOUND"));
                return;
            }

            // تقسیم Base64 به chunkها
            String[] chunks = Base64Util.chunk(song.audioBase64, 65536);
            for (int i = 0; i < chunks.length; i++) {
                out.println("CHUNK;{\"i\":" + i + ",\"data\":\"" + chunks[i] + "\"}");
            }

            out.println("DOWNLOAD_END;{\"song_id\":" + songId + "}");
        } catch (Exception e) {
            out.println(Responses.error("SERVER_ERROR"));
        }
    }
}
