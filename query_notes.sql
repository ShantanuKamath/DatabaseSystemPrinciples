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
SELECT X.aid AS authorID, Y.aid AS coauthorID
FROM PublicationAuthor X, Y
WHERE (X.aid != Y.aid) and (X.pubkey = Y.pubkey);


SELECT id, name  -- Get the names and IDs of authors with the maximum number of co authors
FROM authors
WHERE id IN
(
  SELECT authorID -- Get the IDs of authors with the maximum number of co authors
  FROM coauthors
  GROUP BY authorID
  HAVING COUNT(*) =
    (
      SELECT MAX(y.num_coauthors) -- Get the maximum number of coauthors
      (
        SELECT COUNT(*) AS num_coauthors
        FROM coauthors
        GROUP BY authorID
      ) y
     )
  );



  -- 7

  SELECT id, name, COUNT(*)
  FROM author A JOIN PublicationAuthor AP ON A.id = AP.aid
  GROUP BY A.id
  WHERE AP.pubid IN
  (
    SELECT pubid    -- Get all Publication published in conferences whose titles contain the word "data"
    FROM Publication
    WHERE conf_name LIKE %Data%
   )
  ORDER BY 3 DESC -- Order by the third column (the count)
  LIMIT 10;



  -- 8


  SELECT conf_name
  FROM Publication
  WHERE mdate LIKE %-07-%
  GROUP BY conf_name, mdate
  HAVING COUNT(*) > 100


 -- 9 (a)

 SELECT A.name
 FROM Author A JOIN PublicationAuthor AP ON A.id = AP.aid JOIN Publication P ON AP.pubid = P.pubid
 WHERE P.Year BETWEEN '1987' AND '2017'
 GROUP BY AP.aid
 HAVING COUNT(DISTINCT Year) = 30;

 -- 9 (b)

 SELECT name, COUNT(*)
 FROM authors A JOIN PublicationAuthor AP ON A.id = AP.aid
 WHERE (name LIKE 'H%') -- Assuming name is in the format 'Khare Simran'
   AND AP.aid IN (
        -- Get the authors of Publication with the earliest Publication date
        SELECT AP.aid
        FROM PublicationAuthor AP JOIN Publication P ON AP.pubid = P.pubid
        WHERE mdate = (SELECT MIN(mdate) FROM Publication)
        )
 GROUP BY AP.aid
