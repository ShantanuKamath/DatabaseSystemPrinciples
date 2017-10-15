-------------------1------------------------
SELECT SUM(cunt)
FROM(
SELECT category, COUNT(*) cunt
FROM Publication
WHERE year BETWEEN '2000' AND '2017'
GROUP BY category
) temp;
-------------------2------------------------
SELECT DISTINCT conf
FROM (
    SELECT SPLIT_PART(key, '/', 2) AS conf, year, COUNT(*) as conf_count
    FROM Publication
    WHERE mdate LIKE '%-07-%' AND SPLIT_PART(key, '/', 1) = 'conf' -- Assuming mdate is in the format '2017-07-14'
    GROUP BY SPLIT_PART(key, '/', 2), year) temp
WHERE temp.conf_count > 200;

-------------------3a------------------------
SELECT P.title -- Need to show all Publication details
FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
WHERE AP.author_id IN (
  SELECT author_id
  FROM Author
  WHERE name ILIKE '%Sheila Brady%' --- X
  LIMIT 1 -- select just one id, in case there are multiple authors with the same name
) AND P.year = '2015';

---- POSSIBLE OPTIMISATION : USE MDATE AND CREATE FIELDS OF YEAR AND MONTH\


-- 3 (b)

SELECT * -- Need to show all publication details
FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
WHERE AP.author_id IN (
  SELECT author_id
  FROM Author
  WHERE name ILIKE '%Langley%' --- X
  LIMIT 1 -- select just one id, in case there are multiple authors with the same name
) AND P.year = '1990' AND SPLIT_PART(P.key, '/', 2) = 'bmvc'

--- Extract conf_name
-- 3(c)

SELECT A.name
FROM PublicationAuthor AP JOIN author A ON AP.author_id = A.author_id
WHERE AP.publication_id IN (
                SELECT P.publication_id
                FROM Publication P
                WHERE SPLIT_PART(P.key, '/', 2) = 'bmvc' AND year = '1990') -- Y AND Z
GROUP BY A.name
HAVING COUNT(*) > 1;


-- 4 (a)
-- Try out intersect or difference
SELECT name, A.author_id
FROM Author A JOIN
(
  SELECT AP.author_id, SPLIT_PART(P.key, '/', 2) conf_name, COUNT(*)
  FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
  WHERE SPLIT_PART(P.key, '/', 2) IN (LOWER('pvldb'), LOWER('SIGMOD'))
  GROUP BY AP.author_id, SPLIT_PART(P.key, '/', 2)
  HAVING COUNT(*) >= 10
) x
ON A.author_id = x.author_id
GROUP BY name, A.author_id
HAVING COUNT(*) = 2

-- 4 (b)
SELECT A.name
FROM AUTHOR A
WHERE A.author_id IN
(
  (
    SELECT AP.author_id
    FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
    WHERE SPLIT_PART(P.key, '/', 2) = LOWER('PVLDB')
    GROUP BY AP.author_id
    HAVING COUNT(*) >= 15 )
  EXCEPT
  ( SELECT AP.author_id
    FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
    WHERE SPLIT_PART(P.key, '/', 2) = LOWER('KDD')
    GROUP BY AP.author_id)
);

-- 5


SELECT 	substring(year from 1 for 3) as y3, COUNT(*)
FROM Publication
WHERE year BETWEEN '1970' AND '2019'
GROUP BY substring(year from 1 for 3);

-- Tried this on some sample data, and it works without having to form intermediate tables for each ten year interval
-- 6

-- The following gives us all the author-co author pairs
CREATE VIEW coauthors AS
SELECT X.author_id AS authorID, Y.author_id AS coauthorID
FROM PublicationAuthor X JOIN PublicationAuthor Y
ON (X.author_id != Y.author_id) and (X.publication_id = Y.publication_id)
GROUP BY X.author_id, Y.author_id;

CREATE VIEW datacoauthors AS
SELECT authorID, count(*) as count -- Get the IDs of authors with the maximum number of co authors
FROM coauthors
WHERE authorID IN (
    SELECT AP.author_id
    FROM PublicationAuthor AP JOIN Publication P
    ON P.publication_id = AP.publication_id
    WHERE (P.key LIKE 'journals%' OR P.key LIKE 'conf%')
    AND LOWER(P.title) LIKE '%data%'
)
GROUP BY authorID;

SELECT authorID
FROM datacoauthors
WHERE count = (SELECT MAX(count) FROM datacoauthors);
----------------optimized query--------------------------
SELECT q1.name AS author, q2.collaborators_count
FROM (SELECT * FROM Author) as q1, (
	SELECT PA1.author_id AS author_id,COUNT(DISTINCT PA2.author_id) AS collaborators_count
	FROM PublicationAuthor PA1, PublicationAuthor PA2
	WHERE PA1.author_id!=PA2.author_id AND PA1.publication_id=PA2.publication_id
	GROUP BY PA1.author_id) as q2
WHERE q1.author_id=q2.author_id
AND q1.author_id IN (
    SELECT AP.author_id
    FROM PublicationAuthor AP JOIN Publication P
    ON P.publication_id = AP.publication_id
    WHERE (P.key LIKE 'journals%' OR P.key LIKE 'conf%')
    AND LOWER(P.title) LIKE '%data%'
)
ORDER BY collaborators_count DESC LIMIT 10;


  -- 7

SELECT A.author_id, A.name, COUNT(*)
FROM Author A JOIN PublicationAuthor AP ON A.author_id = AP.author_id
WHERE AP.publication_id IN
(
    SELECT publication_id    -- Get all Publication published in conferences whose titles contain the word "data"
    FROM Publication
    WHERE (key LIKE 'journals%' OR key LIKE 'conf%')
    AND LOWER(title) LIKE '%data%'
    AND year BETWEEN '2013' and '2017'
)
GROUP BY A.author_id, A.name
ORDER BY 3 DESC -- Order by the third column (the count)
LIMIT 10;

-------------optimized-------------------------
SELECT A.name, COUNT(*) AS publication_count
FROM Author A, Publication P, PublicationAuthor PA
WHERE P.publication_id=PA.publication_id AND A.author_id=PA.author_id
AND (P.key LIKE 'journals/%' OR P.key LIKE 'conf/%')
AND P.year BETWEEN '2013' AND '2017'
AND LOWER(P.title) LIKE '%data%'
GROUP BY A.author_id
ORDER BY count(*) DESC LIMIT 10;

-- 8
--------------test_version------------------------

-- SELECT SPLIT_PART(key, '/', 2) AS conf_name, year, COUNT(*) AS count
SELECT DISTINCT(SPLIT_PART(key, '/', 2)) AS conf_name
FROM Publication
WHERE mdate LIKE '%-07-%'
AND category = 'inproceedings'
AND key LIKE 'conf%'
GROUP BY SPLIT_PART(key, '/', 2), year
HAVING COUNT(*) > 100


-- 9 (a)

SELECT A.name, AP.author_id
FROM Author A JOIN PublicationAuthor AP ON A.author_id = AP.author_id JOIN Publication P ON AP.publication_id = P.publication_id
WHERE P.year BETWEEN '1988' AND '2017'
AND SUBSTRING(A.name , LENGTH(A.name) -  STRPOS(REVERSE(A.name),' ') + 2  , LENGTH(A.name)) LIKE 'H%'
GROUP BY AP.author_id, A.name
HAVING COUNT(DISTINCT P.year) = 30;

-- 9 (b)

SELECT A.author_id, A.name, COUNT(*)
FROM Author A JOIN PublicationAuthor AP
ON A.author_id = AP.author_id
WHERE A.author_id IN (
    -- Get the authors of Publication with the earliest Publication date
    SELECT DISTINCT AP.author_id
    FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
    WHERE P.year = (SELECT MIN(year) FROM Publication)
    )
GROUP BY A.author_id , A.name;


----- 10------ Return the top 5 most common first name of authors who have pubished papers in the last 10 years
SELECT SPLIT_PART(A.name, ' ', 2) as firstname, COUNT(*)
FROM Author A JOIN PublicationAuthor AP ON A.author_id = AP.author_id
JOIN Publication P ON AP.publication_id = P.publication_id
WHERE P.year BETWEEN '2008' AND '2017'
GROUP BY SPLIT_PART(A.name, ' ', 2)
ORDER BY COUNT(*) DESC
LIMIT 5;
