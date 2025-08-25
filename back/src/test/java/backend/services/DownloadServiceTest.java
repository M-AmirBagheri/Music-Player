package backend.services;

import backend.dao.InMemorySongDao;
import backend.model.Song;
import org.junit.jupiter.api.Test;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Base64;

import static org.junit.jupiter.api.Assertions.*;

class DownloadServiceTest {

    @Test
    void sendSongChunks_ok() {
        InMemorySongDao dao = new InMemorySongDao();

        Song s = new Song();
        s.setTitle("t"); s.setArtist("a");
        s.setPrice(0.0); s.setRating(0); s.setFree(true);
        s.setCoverPath("x");
        s.setAudioBase64(Base64.getEncoder().encodeToString("hello".getBytes()));

        int id = dao.addSongForTest(s);
        DownloadService ds = new DownloadService(dao);

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw, true);

        ds.sendSongChunks(pw, id);

        String out = sw.toString();
        assertTrue(out.contains("CHUNK;"));
        assertTrue(out.contains("DOWNLOAD_END"));
    }

    @Test
    void sendSongChunks_notFound() {
        InMemorySongDao dao = new InMemorySongDao();
        DownloadService ds = new DownloadService(dao);

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw, true);

        ds.sendSongChunks(pw, 999);

        assertTrue(sw.toString().contains("ERROR;SONG_NOT_FOUND"));
    }
}
