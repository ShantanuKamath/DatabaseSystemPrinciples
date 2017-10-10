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
  SELECT author_id -- select just one id, in case there are multiple authors with the same name
  FROM authors
  WHERE author_name = 'X'
  )
LIMIT 1;
  
