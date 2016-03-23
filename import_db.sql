DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);


DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);


DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  author_id INTEGER NOT NULL,
  body VARCHAR(255) NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (reply_id) REFERENCES replies(id),
  FOREIGN KEY (author_id) REFERENCES users(id)
);


DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Charles', 'Cho'), ('Matthew', 'Fong');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Question 1', 'Body 1', (SELECT id FROM users WHERE fname LIKE 'Charles')),
  ('Question 2', 'Body 2', (SELECT id FROM users WHERE fname LIKE 'Matthew'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES

    ((SELECT id FROM users WHERE fname LIKE 'Matthew'),
    (SELECT id FROM questions WHERE title LIKE '%1')),
    ((SELECT id FROM users WHERE fname LIKE 'Charles'),
    (SELECT id FROM questions WHERE title LIKE '%2'))
  ;

INSERT INTO
  replies (question_id, reply_id, author_id, body)
VALUES
  (1, NULL, 2, 'first reply body from Matthew'),
  (1, 1, 1, 'second reply from Charles');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1,2),
  (1,1),
  (2,2);
