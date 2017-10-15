--------------------------------------------------------------------------------
-- query.sql
--------------------------------------------------------------------------------
-- Statement that execute queries as required by corresponding queries
  -- may contain multiple instances of a query.
  -- last one is the most optimised one.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Query 1: For each type of publication, count the total number of publications
--          of that type between 2000- 2017. Your query should return a set of 
--          (publication-type, count) pairs.
--          For example (article, 20000), (inproceedings, 30000).....
--------------------------------------------------------------------------------
\echo Query 1
SELECT category, COUNT(*) count
FROM Publication
WHERE year BETWEEN '2000' AND '2017'
GROUP BY category;

--------------------------------------------------------------------------------
-- Query 2: Find all the conferences that have ever published more than 200 
--          papers in one year and are held in July. Note that one conference 
--          may be held every year (e.g., KDD runs many years, and each year the
--          conference has a number of papers).
--------------------------------------------------------------------------------
\echo Query 2
SELECT DISTINCT conf_name
FROM (
	SELECT SPLIT_PART(key, '/', 2) AS conf_name, year, COUNT(*) as conf_count
	FROM Publication
	WHERE mdate LIKE '%-07-%' AND SPLIT_PART(key, '/', 1) = 'conf' 
	-- Assuming mdate is in the format '2017-07-14'
	GROUP BY SPLIT_PART(key, '/', 2), year) temp
WHERE temp.conf_count > 200;

--------------------------------------------------------------------------------
-- Query 3a:  Find the publications of author = “X” (replace X with a real name
--            in your database) at year 2015 (List all the available information
--            of each publication). 
--------------------------------------------------------------------------------
\echo Query 3a
SELECT P.* -- Need to show all Publication details
FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
WHERE AP.author_id IN (
	SELECT author_id
	FROM Author
	WHERE name ILIKE '%Ursula Goltz%' --- X
	LIMIT 1 -- select just one id, in case there are multiple authors with the same name
) AND P.year = '2015';

---- POSSIBLE OPTIMISATION : USE MDATE AND CREATE FIELDS OF YEAR AND MONTH\

--------------------------------------------------------------------------------
-- Query 3b: Find the publications of author = “X” (replace X with a real name
--           in your database) at year “Y” at conference “Z” (replace Y and Z 
--           with real value so that the query will return some tuples as 
--           results.)
--------------------------------------------------------------------------------
\echo Query 3b
SELECT P.* -- Need to show all publication details
FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
WHERE AP.author_id IN (
	SELECT author_id
	FROM Author
	WHERE name ILIKE '%Peter Mowforth%' --- X
	LIMIT 1 -- select just one id, in case there are multiple authors with the same name
) AND P.year = '1990' AND SPLIT_PART(P.key, '/', 2) = 'bmvc';
--- Extract conf_name

--------------------------------------------------------------------------------
-- Query 3c: Find authors who published at least 2 papers at conference “Z” at 
--           year “Y”
--------------------------------------------------------------------------------
\echo Query 3c
SELECT A.name
FROM PublicationAuthor AP JOIN author A ON AP.author_id = A.author_id
WHERE AP.publication_id IN (
	SELECT P.publication_id
	FROM Publication P
	WHERE SPLIT_PART(P.key, '/', 2) = 'bmvc' AND year = '1990') -- Y AND Z
GROUP BY A.name
HAVING COUNT(*) > 1;


--------------------------------------------------------------------------------
-- Query 4a: Find (a) all authors who published at least 10 PVLDB papers and 
--           published at least 10 SIGMOD papers.
--------------------------------------------------------------------------------
-- Try out intersect or difference like in next section.
\echo Query 4a
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
HAVING COUNT(*) = 2;

--------------------------------------------------------------------------------
-- Query 4b: Find all authors who published at least 15 PVLDB papers but never 
--           published a KDD paper.(Note that you need to do some digging to 
--           find out how DBLP spells the name of conferences and journals).
--------------------------------------------------------------------------------
\echo Query 4b
SELECT A.name
FROM AUTHOR A
WHERE A.author_id IN(
  (
	SELECT AP.author_id
	FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
	WHERE SPLIT_PART(P.key, '/', 2) = LOWER('PVLDB')
	GROUP BY AP.author_id
	HAVING COUNT(*) >= 15)
  EXCEPT
  ( SELECT AP.author_id
	FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
	WHERE SPLIT_PART(P.key, '/', 2) = LOWER('KDD')
	GROUP BY AP.author_id)
);

--------------------------------------------------------------------------------
-- Query 5: For each 10 consecutive years starting from 1970, 
--			i.e., [ 1970, 1979 ], [ 1980, 1989 ],..., [2010, 2019], compute the 
--			total number of conference publications in DBLP in that 10 years. 
--			Hint: for this query you may want to compute a temporary table with 
--			all distinct years.
--------------------------------------------------------------------------------

\echo Query 5
SELECT substring(year from 1 for 3) as y3, COUNT(*)
FROM Publication
WHERE year BETWEEN '1970' AND '2019'
GROUP BY substring(year from 1 for 3);
-- Tried this on some sample data, and it works without having to form 
-- intermediate tables for each ten year interval

--------------------------------------------------------------------------------
-- Query 6: Find the most collaborative authors who published in a conference
--			or journal whose name contains “data” (e.g., ACM SIGKDD 
--			International Conference on Knowledge Discovery and 
--			Data Mining). That is, for each author determine its number
--			of collaborators, and then find the author with the most number
--			of collaborators. Hint: for this question you may want to compute
--			a temporary table of coauthors.
--------------------------------------------------------------------------------
-- The following gives us all the author-co author pairs
-- CREATE VIEW coauthors AS
-- SELECT X.author_id AS authorID, Y.author_id AS coauthorID
-- FROM PublicationAuthor X JOIN PublicationAuthor Y
-- ON (X.author_id != Y.author_id) and (X.publication_id = Y.publication_id)
-- GROUP BY X.author_id, Y.author_id;

-- CREATE VIEW datacoauthors AS
-- SELECT authorID, count(*) as count -- Get the IDs of authors with the maximum number of co authors
-- FROM coauthors
-- WHERE authorID IN (
-- 	SELECT AP.author_id
-- 	FROM PublicationAuthor AP JOIN Publication P
-- 	ON P.publication_id = AP.publication_id
-- 	WHERE (P.key LIKE 'journals%' OR P.key LIKE 'conf%')
-- 	AND LOWER(P.title) LIKE '%data%'
-- )
-- GROUP BY authorID;

-- SELECT authorID
-- FROM datacoauthors
-- WHERE count = (SELECT MAX(count) FROM datacoauthors);

----------------optimized query--------------------------

\echo Query 6
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


--------------------------------------------------------------------------------
-- Query 7: Data analytics and data science are very popular topics. Find the 
-- 			top 10 authors with the largest number of publications that are 
-- 			published in conferences and journals whose titles contain word 
-- 			“Data” in the last 5 years.
--------------------------------------------------------------------------------
-- SELECT A.author_id, A.name, COUNT(*)
-- FROM Author A JOIN PublicationAuthor AP ON A.author_id = AP.author_id
-- WHERE AP.publication_id IN
-- (
-- 	SELECT publication_id    
-- 	-- Get all Publication published in conferences whose titles contain the word "data"
-- 	FROM Publication
-- 	WHERE (key LIKE 'journals%' OR key LIKE 'conf%')
-- 	AND LOWER(title) LIKE '%data%'
-- 	AND year BETWEEN '2013' and '2017'
-- )
-- GROUP BY A.author_id, A.name
-- ORDER BY 3 DESC -- Order by the third column (the count)
-- LIMIT 10;

-------------optimized-------------------------
\echo Query 7

SELECT A.name, COUNT(*) AS publication_count
FROM Author A, Publication P, PublicationAuthor PA
WHERE P.publication_id=PA.publication_id AND A.author_id=PA.author_id
AND (P.key LIKE 'journals/%' OR P.key LIKE 'conf/%')
AND P.year BETWEEN '2013' AND '2017'
AND LOWER(P.title) LIKE '%data%'
GROUP BY A.author_id
ORDER BY count(*) DESC LIMIT 10;

--------------------------------------------------------------------------------
-- Query 8: List the name of the conferences such that it has ever been held in 
--			June, and the corresponding proceedings (in the year where the conf
--			was held in June) contain more than 100 publications.
--------------------------------------------------------------------------------
--------------test_version------------------------
-- SELECT SPLIT_PART(key, '/', 2) AS conf_name, year, COUNT(*) AS count
\echo Query 8
SELECT DISTINCT(SPLIT_PART(key, '/', 2)) AS conf_name
FROM Publication
WHERE mdate LIKE '%-07-%'
AND category = 'inproceedings'
AND key LIKE 'conf%'
GROUP BY SPLIT_PART(key, '/', 2), year
HAVING COUNT(*) > 100;


--------------------------------------------------------------------------------
-- Query 9a: Find authors who have published at least 1 paper every year in the
--			 last 30 years, and whose family name start with ‘H’.
--------------------------------------------------------------------------------
\echo Query 9a
SELECT A.name, AP.author_id
FROM Author A JOIN PublicationAuthor AP ON A.author_id = AP.author_id 
JOIN Publication P ON AP.publication_id = P.publication_id
WHERE P.year BETWEEN '1988' AND '2017'
AND SUBSTRING(A.name , LENGTH(A.name)-STRPOS(REVERSE(A.name),' ')+2, LENGTH(A.name)) LIKE 'H%'
GROUP BY AP.author_id, A.name
HAVING COUNT(DISTINCT P.year) = 30;

--------------------------------------------------------------------------------
-- Query 9b: Find the names and number of publications for authors who have the
-- 			 earliest publication record in DBLP.
--------------------------------------------------------------------------------
\echo Query 9b
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

--------------------------------------------------------------------------------
-- Query 10: Design a join query that is not in the above list.
--			 Return the top 5 most common first name of authors who have 
-- 			 pubished papers in the last 10 years.
--------------------------------------------------------------------------------
\echo Query 10
SELECT SPLIT_PART(A.name, ' ', 2) as firstname, COUNT(*)
FROM Author A JOIN PublicationAuthor AP ON A.author_id = AP.author_id
JOIN Publication P ON AP.publication_id = P.publication_id
WHERE P.year BETWEEN '2008' AND '2017'
GROUP BY SPLIT_PART(A.name, ' ', 2)
ORDER BY COUNT(*) DESC
LIMIT 5;
--------------------------------------------------------------------------------
