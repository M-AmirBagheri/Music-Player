// src/main/java/backend/services/DownloadService.java
package backend.services;

import backend.dao.SongDao;
import backend.model.Song;
import backend.protocol.Responses;

import java.io.PrintWriter;

public class DownloadService {
    private final SongDao songDao;

    public DownloadService() {
        this.songDao = new SongDao();
    }
    // برای تست
    public DownloadService(SongDao songDao) {
        this.songDao = songDao;
    }

    public void sendSongChunks(PrintWriter out, int songId) {
        Song song = songDao.getSongById(songId);
        if (song == null || song.getAudioBase64() == null) {
            out.println(Responses.error("SONG_NOT_FOUND"));
            return;
        }
        // نمونهٔ ساده: کل فایل را در یک CHUNK می‌فرستیم
        out.println("CHUNK;" + song.getAudioBase64());
        out.println("DOWNLOAD_END");
    }
}
