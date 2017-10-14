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

SELECT A.name, COUNT(*)
FROM PublicationAuthor AP JOIN author A ON AP.author_id = A.author_id
WHERE AP.publication_id IN (
                SELECT P.publication_id
                FROM Publication P
                WHERE SPLIT_PART(P.key, '/', 2) = 'bmvc' AND year = '1990')
GROUP BY A.name
HAVING COUNT(*) > 1;


-- 4 (a)
-- Try out intersect or difference
SELECT author_name, A.id
FROM author A JOIN
(
  SELECT AP.aid as aid, P.conf_name, COUNT(*)
  FROM PublicationAuthor AP JOIN publication P ON AP.pid = P.id
  WHERE conf_name IN ['PVLDB', 'SIGMOD']
  GROUP BY author.id, P.conf_name
  HAVING COUNT(*) >= 10
) x
ON A.id = aid
GROUP BY x.aid, A.id
WHERE COUNT(*) == 2


-- 4 (b)
SELECT A.author_name
FROM AUTHOR A
WHERE A.id IN
(
  (
    SELECT author_id, COUNT(*)
    FROM PublicationAuthor AP JOIN Publication P ON AP.pubid = P.id
    WHERE P.conf_name = 'PVLDB'
    GROUP BY author_id
    HAVING COUNT(*) >= 10 )
  EXCEPT
  ( SELECT author_id, COUNT(*)
    FROM PublicationAuthor AP JOIN Publication P ON AP.pubid = P.id
    WHERE P.conf_name = 'PVLDB'
    GROUP BY author_id
    HAVING COUNT(*) >= 10 )
);


-- 5


SELECT YEAR/10, COUNT(*)
FROM Publication
WHERE (YEAR BETWEEN 1970 AND 2019) AND (conf_ name = 'DBLP')
GROUP BY YEAR/10;

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
