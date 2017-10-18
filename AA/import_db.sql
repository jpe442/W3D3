DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follow;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS likes;

CREATE TABLE users (
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  id INTEGER PRIMARY KEY
);

CREATE TABLE questions (
  title VARCHAR(255) NOT NULL,
  body TEXT,
  associated_author_id INTEGER NOT NULL,
  id INTEGER PRIMARY KEY,

  FOREIGN KEY(associated_author_id) REFERENCES users(id)
);

CREATE TABLE question_follow (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  id INTEGER PRIMARY KEY,

  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  subject_question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT,
  id INTEGER PRIMARY KEY,

  FOREIGN KEY(subject_question_id) REFERENCES questions(id),
  FOREIGN KEY(parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);
