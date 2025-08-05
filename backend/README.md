# 🎧 Music Player - Backend

This is the **Java backend module** for the HICH Music Player app. It provides database management, user authentication, song purchases, ratings, comments, and socket-based communication with the Flutter frontend.

---

## 📦 Technologies Used

- **Java 17**
- **MySQL** for relational data
- **JDBC** for database connection
- **Socket Programming** for communication with the Flutter client
- **Gradle** as the build system

---

## 📁 Folder Structure

```plaintext
backend/
├── README.md               → You’re here!
├── build.gradle            → Gradle build file
├── logs/                   → Server logs
├── sql/                    → MySQL schema file(s)
│   └── create_music_app.sql
├── src/
│   ├── models/             → User.java, Song.java, Comment.java, etc.
│   ├── database/           → DatabaseManager.java (JDBC connection)
│   ├── server/             → MusicServer.java, ClientHandler.java
│   ├── services/           → Business logic classes (e.g., UserService.java)
│   └── utils/              → Tools like password hashing
└── test/                   → Optional JUnit or manual test classes
