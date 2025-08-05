CREATE DATABASE music_app;
USE music_app;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    credit DOUBLE DEFAULT 0,
    subscription ENUM('standard', 'premium') DEFAULT 'standard'
);
CREATE TABLE songs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    artist VARCHAR(100),
    rating FLOAT DEFAULT 0,
    price DOUBLE DEFAULT 0,
    cover_path TEXT 
);
