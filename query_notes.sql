-- 1
SELECT type, COUNT(*)
FROM PUBLICATIONS
WHERE YEAR BETWEEN '2000' AND '2017' -- Decide whether year will be a string or integer;


-- 2
SELECT conf_name
FROM (
  SELECT conference_name, year, COUNT(*) as conf_count
  FROM publications
  WHERE mdate LIKE '%-07-%' -- Assuming mdate is in the format '2017-07-14'
  GROUP BY year )
WHERE conf_count > 200;


-- 3 (a)

SELECT title
FROM author_pub_relation AP JOIN publication P ON AP.pid = P.id
WHERE author.id = (
  SELECT author_id 
  FROM authors
  WHERE author_name = 'X'
  LIMIT 1;  -- select just one id, in case there are multiple authors with the same name
) AND P.year = '2015'

  

-- 3 (b)

SELECT title
FROM author_pub_relation AP JOIN publication P ON AP.pid = P.id
WHERE author.id = (
  SELECT author_id 
  FROM authors
  WHERE author_name = 'X'
  LIMIT 1;  -- select just one id, in case there are multiple authors with the same name
) AND P.year = 'Y' AND P.conf_name = 'Z'


-- 3(c)

SELECT author_name 
FROM author_pub_relation AP JOIN author A ON AP.aid = A.id 
WHERE AP.pid IN ( 
                SELECT P.id 
                FROM publications 
                WHERE conf_name = 'Z' AND year = 'Y') ;
                
               
-- 4 (a)
-- Try out intersect or difference
SELECT author_name, A.id 
FROM author A JOIN 
(
  SELECT AP.aid as aid, P.conf_name, COUNT(*)
  FROM author_pub_relation AP JOIN publication P ON AP.pid = P.id
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
    FROM author_pub_relation AP JOIN PUBLICATIONS P ON AP.pubid = P.id
    WHERE P.conf_name = 'PVLDB'
    GROUP BY author_id
    HAVING COUNT(*) >= 10 )
  EXCEPT 
  ( SELECT author_id, COUNT(*)
    FROM author_pub_relation AP JOIN PUBLICATIONS P ON AP.pubid = P.id
    WHERE P.conf_name = 'PVLDB'
    GROUP BY author_id
    HAVING COUNT(*) >= 10 )
);


-- 5


SELECT YEAR/10, COUNT(*)
FROM publications
WHERE (YEAR BETWEEN 1970 AND 2019) AND (conf_ name = 'DBLP')
GROUP BY YEAR/10;

-- Tried this on some sample data, and it works without having to form intermediate tables for each ten year interval



-- 6 


-- The following gives us all the author-co author pairs
CREATE VIEW coauthors AS
SELECT X.aid AS authorID, Y.aid AS coauthorID
FROM author_pub_relation X, Y
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




