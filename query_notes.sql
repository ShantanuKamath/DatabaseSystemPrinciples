-- 1
SELECT type, COUNT(*)
FROM PUBLICATIONS
WHERE YEAR BETWEEN '2000' AND '2017' -- Decide whether year will be a string or integer;


-- 2
SELECT conf_name
FROM (
  SELECT conference_name, year, COUNT(*) as conf_count
  FROM publications
  WHERE mdate LIKE %%-7-%%%% 
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
GROUP BY YEAR/10
WHERE (YEAR BETWEEN 1970 AND 2019) AND conf_ name = 'DBLP'


-- 6 











