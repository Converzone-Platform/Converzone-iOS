DROP TABLE speakers;
DROP TABLE leangs;
DROP TABLE blocks;
DROP TABLE reflections;
DROP TABLE members;
DROP TABLE groups;
DROP TABLE friends;
DROP TABLE users;
DROP TABLE country;
DROP TABLE message;

CREATE TABLE users (
    userID int not null,
    password varchar(25) not null,
    firstname varchar(50) not null,
    lastname varchar(50) not null,
    link_to_profile_image
    gender varchar(1) not null,
    firstjoin date not null,
    birthday date not null,
    email varchar(50) not null,
    interests varchar(500) not null,
    status varchar(500) not null,
    countryID int,
    blocked_by_the_system varchar(1) not null,
    primary key (userID),
    FOREIGN KEY(countryID) REFERENCES country(countryID)
);

CREATE TABLE country (
    countryID int not null,
    cname varchar(50) not null,
    primary key (countryID)
);

CREATE TABLE blocks (
    blockerID int not null,
    blockedUserID int not null,
    primary key (blockerID,blockedUserID),
    FOREIGN KEY(blockerID) REFERENCES users(userID),
    FOREIGN KEY(blockedUserID) REFERENCES users(userID)
);

CREATE TABLE reflections (
    sendID int not null,
    receiveID int not null,
    Text varchar(500),
    timesent date,
    primary key (sendID,reciveID),
    FOREIGN KEY(sendID) REFERENCES users(userID),
    FOREIGN KEY(receiveID) REFERENCES users(userID)
);

CREATE TABLE groups (
    groupID int not null,
    time_made date not null,
    creatorID int not null,
    membercount int,
    is_groupchat varchar(1),
    primary key (groupID),
    FOREIGN KEY(creatorID) REFERENCES users(userID)
);

CREATE TABLE members (
    memberID int not null,
    groupID int not null,
    isAdmin varchar(1),
    primary key (memberID,groupID),
    FOREIGN KEY(memberID) REFERENCES users(userID),
    FOREIGN KEY(groupID) REFERENCES groups(groupID)
);

CREATE TABLE message (
    userID int not null,
    groupID int not null,
    text varchar(999),
    time_sent date ,
    primary key (userID,groupID,timesend),
    FOREIGN KEY(userID) REFERENCES users(userID),
    FOREIGN KEY(groupID) REFERENCES groups(groupID)
);

CREATE TABLE friends (
    useroneID int not null,
    usertwoID int not null,
    primary key (useroneID,usertwoID),
    FOREIGN KEY(useroneID) REFERENCES users(userID),
    FOREIGN KEY(usertwoID) REFERENCES users(userID)
);

CREATE TABLE language (
    languageID int not null,
    name varchar(50) ,
    primary key (leangID)
);

CREATE TABLE speakers (
    userID int not null,
    leangID int not null,
    speaking varchar(1),
    primary key (userID,leangID),
    FOREIGN KEY(userID) REFERENCES users(userID),
    FOREIGN KEY(leangID) REFERENCES leangs(leangID)
);
