public class PurchasedSong {
    private int id;
    private int userId;
    private int songId;
    private String purchaseDate;

    public PurchasedSong(int id, int userId, int songId, String purchaseDate) {
        this.id = id;
        this.userId = userId;
        this.songId = songId;
        this.purchaseDate = purchaseDate;
    }

    public int getId() {
        return id;
    }

    public int getUserId() {
        return userId;
    }

    public int getSongId() {
        return songId;
    }

    public String getPurchaseDate() {
        return purchaseDate;
    }

    public void setPurchaseDate(String purchaseDate) {
        this.purchaseDate = purchaseDate;
    }
}
