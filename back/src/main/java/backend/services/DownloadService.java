package backend.services;

import backend.dao.SongDao;
import backend.model.Song;
import backend.protocol.Responses;

import java.io.PrintWriter;

public class DownloadService {
    private final SongDao songDao;

    public DownloadService() {
        this(new SongDao());
    }

    // برای تست‌ها
    public DownloadService(SongDao songDao) {
        this.songDao = songDao;
    }

    public void sendSongChunks(PrintWriter out, int songId) {
        Song song = songDao.getSongById(songId);
        if (song == null || song.getAudioBase64() == null) {
            out.println(Responses.error("SONG_NOT_FOUND"));
            out.flush(); // ⬅️ مهم
            return;
        }

        // ⬅️ پروتکل: از «;» استفاده کن نه «,» و در پایان flush کن
        out.println("CHUNK;" + song.getAudioBase64());
        out.println("DOWNLOAD_END");
        out.flush(); // ⬅️ مهم

        // اختیاری: شمارنده دانلود را بالا ببر
        songDao.incDownloadCount(songId);
    }
}
