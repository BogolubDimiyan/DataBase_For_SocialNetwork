create database SocNet

use SocNet
go

-- Создание таблицы Users
CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) UNIQUE NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    birthdate DATE,
    gender NVARCHAR(10),
    profile_picture NVARCHAR(255),
    bio NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Создание таблицы Posts
CREATE TABLE Posts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    content NVARCHAR(MAX),
    image_url NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Создание таблицы Comments
CREATE TABLE Comments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT REFERENCES Posts(id) ON DELETE NO ACTION,
    user_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    content NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Создание таблицы Likes
CREATE TABLE Likes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT REFERENCES Posts(id) ON DELETE NO ACTION,
    user_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    created_at DATETIME DEFAULT GETDATE(),
    UNIQUE (post_id, user_id)
);

-- Создание таблицы Friends
CREATE TABLE Friends (
    id INT IDENTITY(1,1) PRIMARY KEY,
    requester_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    receiver_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    status NVARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    UNIQUE (requester_id, receiver_id)
);

-- Создание таблицы Groups
CREATE TABLE Groups (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    created_by INT REFERENCES Users(id) ON DELETE NO ACTION,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Создание таблицы GroupMembers
CREATE TABLE GroupMembers (
    id INT IDENTITY(1,1) PRIMARY KEY,
    group_id INT REFERENCES Groups(id) ON DELETE NO ACTION,
    user_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    role NVARCHAR(20) DEFAULT 'member' CHECK (role IN ('member', 'admin')),
    joined_at DATETIME DEFAULT GETDATE(),
    UNIQUE (group_id, user_id)
);

-- Создание таблицы Events
CREATE TABLE Events (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    location NVARCHAR(255),
    start_time DATETIME,
    end_time DATETIME,
    created_by INT REFERENCES Users(id) ON DELETE NO ACTION,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Создание таблицы EventAttendees
CREATE TABLE EventAttendees (
    id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT REFERENCES Events(id) ON DELETE NO ACTION,
    user_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    status NVARCHAR(20) DEFAULT 'going' CHECK (status IN ('going', 'maybe', 'not going')),
    joined_at DATETIME DEFAULT GETDATE(),
    UNIQUE (event_id, user_id)
);

-- Создание таблицы Messages
CREATE TABLE Messages (
    id INT IDENTITY(1,1) PRIMARY KEY,
    sender_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    receiver_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    content NVARCHAR(MAX),
    read_status BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);

-- Создание таблицы Notifications
CREATE TABLE Notifications (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    message NVARCHAR(MAX),
    type NVARCHAR(50),
    is_read BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);

-- Создание таблицы Tags
CREATE TABLE Tags (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) UNIQUE NOT NULL
);

-- Создание таблицы PostTags
CREATE TABLE PostTags (
    id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT REFERENCES Posts(id) ON DELETE NO ACTION,
    tag_id INT REFERENCES Tags(id) ON DELETE NO ACTION,
    UNIQUE (post_id, tag_id)
);

-- Создание таблицы PrivacySettings
CREATE TABLE PrivacySettings (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT UNIQUE REFERENCES Users(id) ON DELETE NO ACTION,
    profile_visibility NVARCHAR(20) DEFAULT 'public' CHECK (profile_visibility IN ('public', 'friends', 'private')),
    post_visibility NVARCHAR(20) DEFAULT 'public' CHECK (post_visibility IN ('public', 'friends', 'private')),
    friend_requests NVARCHAR(20) DEFAULT 'everyone' CHECK (friend_requests IN ('everyone', 'friends_of_friends', 'none')),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Создание таблицы BlockedUsers
CREATE TABLE BlockedUsers (
    id INT IDENTITY(1,1) PRIMARY KEY,
    blocker_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    blocked_id INT REFERENCES Users(id) ON DELETE NO ACTION,
    created_at DATETIME DEFAULT GETDATE(),
    UNIQUE (blocker_id, blocked_id)
);

INSERT INTO Users (username, email, password_hash, first_name, last_name, birthdate, gender, profile_picture, bio)
VALUES 
('john_doe', 'john.doe@example.com', 'hashed_password_1', 'John', 'Doe', '1990-05-15', 'male', 'https://example.com/john_doe.jpg', 'Hello, I am John!'),
('jane_smith', 'jane.smith@example.com', 'hashed_password_2', 'Jane', 'Smith', '1992-08-22', 'female', 'https://example.com/jane_smith.jpg', 'Hi there!'),
('alex_brown', 'alex.brown@example.com', 'hashed_password_3', 'Alex', 'Brown', '1985-11-10', 'other', 'https://example.com/alex_brown.jpg', 'Just another user.');

INSERT INTO Posts ([user_id], content, image_url)
VALUES 
(1, 'First post by John!', 'https://example.com/post1.jpg'),
(2, 'Jane is here!', 'https://example.com/post2.jpg'),
(3, 'Alex says hello!', NULL);

INSERT INTO Comments (post_id, [user_id], content)
VALUES 
(1, 2, 'Nice post, John!'),
(1, 3, 'Welcome to the platform!'),
(2, 1, 'Great to see you, Jane!');

INSERT INTO Likes (post_id, [user_id])
VALUES 
(1, 2),
(1, 3),
(2, 1);

INSERT INTO Friends (requester_id, receiver_id, [status])
VALUES 
(1, 2, 'accepted'),
(1, 3, 'pending'),
(2, 3, 'accepted');

INSERT INTO Groups ([name], [description], created_by)
VALUES 
('Tech Enthusiasts', 'A group for tech lovers', 1),
('Nature Lovers', 'For those who love nature', 2);

INSERT INTO GroupMembers (group_id, [user_id], [role])
VALUES 
(1, 1, 'admin'),
(1, 2, 'member'),
(2, 2, 'admin'),
(2, 3, 'member');

INSERT INTO [Events] ([name], [description], [location], start_time, end_time, created_by)
VALUES 
('Tech Meetup', 'A meetup for tech enthusiasts', 'San Francisco', 2023-12-15, 2023-12-15, 1),
('Nature Walk', 'A walk in the park', 'Central Park', 2023-11-20 , 2023-11-20, 2);

INSERT INTO EventAttendees (event_id, [user_id], [status])
VALUES 
(1, 1, 'going'),
(1, 2, 'going'),
(2, 2, 'going'),
(2, 3, 'maybe');

INSERT INTO [Messages] (sender_id, receiver_id, content)
VALUES 
(1, 2, 'Hey Jane, how are you?'),
(2, 1, 'Hi John, I am good, thanks!'),
(3, 1, 'John, can we be friends?');

INSERT INTO Notifications ([user_id], [message], [type])
VALUES 
(1, 'Jane liked your post', 'like'),
(2, 'John commented on your post', 'comment'),
(3, 'You have a new friend request from John', 'friend_request');

INSERT INTO Tags ([name])
VALUES 
('tech'),
('nature'),
('friends');

INSERT INTO PostTags (post_id, tag_id)
VALUES 
(1, 1),
(2, 2),
(3, 3);

INSERT INTO PrivacySettings ([user_id], profile_visibility, post_visibility, friend_requests)
VALUES 
(1, 'public', 'friends', 'everyone'),
(2, 'friends', 'public', 'friends_of_friends'),
(3, 'private', 'private', 'none');

INSERT INTO BlockedUsers (blocker_id, blocked_id)
VALUES 
(1, 3),
(2, 3);