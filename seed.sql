-- psql -f seed.sql -d hacktive_record_practice

CREATE TABLE artists(
  id SERIAL PRIMARY KEY,
  name TEXT
);

CREATE TABLE albums(
  id SERIAL PRIMARY KEY,
  name TEXT,
  artist_id INTEGER REFERENCES artists(id)
);

CREATE TABLE songs(
  id SERIAL PRIMARY KEY,
  title TEXT,
  album_id INTEGER REFERENCES albums(id)
);

INSERT INTO artists (name) VALUES
('Eminem'),
('Canibus');

INSERT INTO albums (name, artist_id) VALUES
('The Slim Shady LP', 1),
('For Whom The Beat Tolls', 2),
('2000 B.C', 2),
(' The Marshall Mathers LP', 1);

INSERT INTO songs (title, album_id) VALUES
('My Name Is', 1),
('Guilty Conscience', 1),
('Brain Damage', 1),
('One Ought Not To Think', 2),
('Mic-Nificent', 3),
('Poet Laureate Infinity V004', 2),
('Bitch Please II', 4);
