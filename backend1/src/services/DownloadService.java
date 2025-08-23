package backend.services;

import backend.dao.SongDao;
import backend.models.Song;
import backend.util.Base64Util;
import backend.util.Config;

import java.io.PrintWriter;

public class DownloadService {
    private final SongDao songDao = new SongDao();

    public void sendSongChunks(PrintWriter out, int songId) {
        Song s = songDao.getSongById(songId);
        if (s == null || s.audioBase64 == null) {
            out.println("ERROR;SONG_NOT_FOUND");
            return;
        }
        int size = Config.getInt("CHUNK_SIZE", 65536);
        String[] parts = Base64Util.chunk(s.audioBase64, size);
        for (int i = 0; i < parts.length; i++) {
            out.println("CHUNK;{\"i\":" + i + ",\"total\":" + parts.length + ",\"data\":\"" + parts[i] + "\"}");
        }
        songDao.incDownloadCount(songId);
        out.println("DOWNLOAD_END;{\"song_id\":" + songId + "}");
    }
}
