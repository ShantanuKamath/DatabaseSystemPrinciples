------------------------------------------------------------------------------
-- create.sql
------------------------------------------------------------------------------
-- To create required tables:
	-- in accordance with the data XML files and ER Diagram schema.
	-- populate the tables with the data according to correct schema.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
\timing on
-- path to the csv file
\set csv_filepath /Users/priyanshusingh/Documents/CZ4031/
------------------------------------------------------------------------------


------------------------------------------------------------------------------
\echo Initiate table creation statements...
------------------------------------------------------------------------------
\echo Table PublicationCSV......
------------------------------------------------------------------------------
DROP TABLE IF EXISTS PublicationCSV;
CREATE TABLE PublicationCSV (
	category TEXT NOT NULL,
	key TEXT NOT NULL,
	mdate TEXT NOT NULL,
	publtype TEXT,
	reviewid TEXT,
	rating TEXT,
	title TEXT,
	booktitle TEXT,
	pages TEXT,
	year TEXT,
	address TEXT,
	journal TEXT,
	volume TEXT,
	number TEXT,
	month TEXT,
	publisher_id INT,
	school TEXT,
	chapter INT
);

DROP TABLE IF EXISTS Publication;

CREATE TABLE Publication (
	publication_id SERIAL PRIMARY KEY,
	category TEXT NOT NULL,
	key TEXT NOT NULL,
	conf_name TEXT NOT NULL,
	parent_type TEXT NOT NULL,
	mdate TEXT NOT NULL,
	title TEXT,
	year TEXT,
	journal TEXT,
	month TEXT
);


------------------------------------------------------------------------------
\echo Table Author......
------------------------------------------------------------------------------

DROP TABLE IF EXISTS Author;
CREATE TABLE Author (
	author_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL
);

------------------------------------------------------------------------------
\echo Table PublicationAuthor......
------------------------------------------------------------------------------

DROP TABLE IF EXISTS PublicationAuthor;
CREATE TABLE PublicationAuthor (
	publication_id INT NOT NULL,
	author_id INT NOT NULL
);


------------------------------------------------------------------------------
\echo Finished table creation statements...
------------------------------------------------------------------------------

------------------------------------------------------------------------------
\set path_to_publication_csv '\'' :csv_filepath publication.csv '\''
------------------------------------------------------------------------------

------------------------------------------------------------------------------
\echo Populating PublicationCSV Table...
-- Populate PublicationCSV table using publication.csv.
------------------------------------------------------------------------------
COPY PublicationCSV(category, key, mdate, publtype, reviewid, rating, title,
				 booktitle, pages, year, address, journal, volume, number,
				 month, school, chapter) FROM :path_to_publication_csv CSV;
------------------------------------------------------------------------------

\echo Populating Publication Table...
-- Extract the relevent columns from the PublicationCSV table

INSERT INTO Publication (category, key, conf_name, parent_type, mdate, title, year, journal, month)
SELECT category, key, SPLIT_PART(key, '/', 2) AS conf_name, SPLIT_PART(key, '/', 1) AS parent_type,
	   mdate, title, year, journal, month
FROM PublicationCSV;


------------------------------------------------------------------------------
\set path_to_author_csv '\'' :csv_filepath author.csv '\''
\echo ____Populating author information.
------------------------------------------------------------------------------
-- Load author.csv.
DROP TABLE IF EXISTS AuthorCSV;
CREATE TEMP TABLE AuthorCSV (
	publication_key TEXT NOT NULL,
	author_name TEXT NOT NULL
);
COPY AuthorCSV FROM :path_to_author_csv CSV;

-- Populate Author table. Assumption: author names are unique.
DELETE FROM Author;
INSERT INTO Author(name)
SELECT DISTINCT author_name FROM AuthorCSV;

-- Populate PublicationAuthor table.
DELETE FROM PublicationAuthor;
INSERT INTO PublicationAuthor
SELECT DISTINCT pub.publication_id, a.author_id
FROM Author a
JOIN AuthorCSV acsv ON a.name = acsv.author_name
JOIN Publication pub ON pub.key = acsv.publication_key;
DROP TABLE AuthorCSV;

------------------------------------------------------------------------------
\echo Done......
------------------------------------------------------------------------------
