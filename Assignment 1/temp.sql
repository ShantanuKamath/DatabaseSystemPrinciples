DROP TABLE IF EXISTS PublicationTemp;
CREATE TABLE PublicationTemp (
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

INSERT INTO PublicationTemp
SELECT * FROM Publication
LIMIT 1910306;

DROP TABLE IF EXISTS PublicationAuthorTemp;
CREATE TABLE PublicationAuthorTemp (
	publication_id INT NOT NULL,
	author_id INT NOT NULL
);

INSERT INTO PublicationAuthorTemp
SELECT PA.publication_id, PA.author_id
FROM PublicationAuthor PA JOIN PublicationTemp PT
ON PA.publication_id = PT.publication_id;

DROP TABLE IF EXISTS AuthorTemp;
CREATE TABLE AuthorTemp (
	author_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL
);

INSERT INTO AuthorTemp(name)
SELECT DISTINCT A.name
FROM Author A JOIN PublicationAuthorTemp PAT
ON A.author_id = PAT.author_id;
