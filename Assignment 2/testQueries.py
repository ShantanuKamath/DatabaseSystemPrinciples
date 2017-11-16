def main():

	query_list = []

	query_list.append("""SELECT category, COUNT(*) count
	FROM Publication
	WHERE year BETWEEN '2000' AND '2017'
	GROUP BY category;""")

	query_list.append("""SELECT DISTINCT conf_name
	FROM (
		SELECT conf_name, year, COUNT(*) as conf_count
		FROM Publication
		WHERE mdate LIKE '%-07-%' AND parent_type = 'conf'
		-- Assuming mdate is in the format '2017-07-14'
		GROUP BY conf_name, year) temp
	WHERE temp.conf_count > 200;""")

	query_list.append("""SELECT P.* -- Need to show all Publication details
	FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
	WHERE AP.author_id IN (
		SELECT author_id
		FROM Author
		WHERE name ILIKE '%Ursula Goltz%' --- X
		LIMIT 1 -- select just one id, in case there are multiple authors with the same name
	) AND P.year = '2015';""")

	query_list.append("""SELECT P.* -- Need to show all publication details
	FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
	WHERE AP.author_id IN (
		SELECT author_id
		FROM Author
		WHERE name ILIKE '%Peter Mowforth%' --- X
		LIMIT 1 -- select just one id, in case there are multiple authors with the same name
	) AND P.year = '1990' AND conf_name = 'bmvc';""")

	query_list.append("""SELECT A.name
	FROM PublicationAuthor AP JOIN author A ON AP.author_id = A.author_id
	WHERE AP.publication_id IN (
		SELECT P.publication_id
		FROM Publication P
		WHERE conf_name = 'bmvc' AND year = '1990') -- Y AND Z
	GROUP BY A.name
	HAVING COUNT(*) > 1;""")

	query_list.append("""SELECT name, A.author_id
	FROM Author A JOIN
	(
		SELECT AP.author_id, conf_name, COUNT(*)
		FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
		WHERE conf_name IN (LOWER('pvldb'), LOWER('SIGMOD'))
		GROUP BY AP.author_id, conf_name
		HAVING COUNT(*) >= 10
	) x
	ON A.author_id = x.author_id
	GROUP BY name, A.author_id
	HAVING COUNT(*) = 2;""")

	query_list.append("""SELECT A.name
	FROM AUTHOR A
	WHERE A.author_id IN(
	  (
		SELECT AP.author_id
		FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
		WHERE conf_name = LOWER('PVLDB')
		GROUP BY AP.author_id
		HAVING COUNT(*) >= 15)
	  EXCEPT
	  ( SELECT AP.author_id
		FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
		WHERE conf_name = LOWER('KDD')
		GROUP BY AP.author_id)
	);""")
	query_list.append("""SELECT substring(year from 1 for 3) as y3, COUNT(*)
	FROM Publication
	WHERE year BETWEEN '1970' AND '2019'
	GROUP BY substring(year from 1 for 3);""")

	query_list.append("""SELECT q1.name AS author, q2.collaborators_count
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
		WHERE (P.parent_type = 'journals' OR P.parent_type = 'conf')
		AND LOWER(P.title) LIKE '%data%'
	)
	ORDER BY collaborators_count DESC LIMIT 10;""")

	query_list.append("""SELECT A.name, COUNT(*) AS publication_count
	FROM Author A, Publication P, PublicationAuthor PA
	WHERE P.publication_id=PA.publication_id AND A.author_id=PA.author_id
	AND (P.parent_type = 'journals' OR P.parent_type = 'conf')
	AND P.year BETWEEN '2013' AND '2017'
	AND LOWER(P.title) LIKE '%data%'
	GROUP BY A.author_id
	ORDER BY count(*) DESC LIMIT 10;""")

	query_list.append("""SELECT DISTINCT conf_name
	FROM Publication
	WHERE mdate LIKE '%-07-%'
	AND category = 'inproceedings'
	AND parent_type = 'conf'
	GROUP BY conf_name, year
	HAVING COUNT(*) > 100;""")

	query_list.append("""SELECT A.name, AP.author_id
	FROM Author A JOIN PublicationAuthor AP ON A.author_id = AP.author_id
	JOIN Publication P ON AP.publication_id = P.publication_id
	WHERE P.year BETWEEN '1988' AND '2017'
	AND SUBSTRING(A.name , LENGTH(A.name)-STRPOS(REVERSE(A.name),' ')+2, LENGTH(A.name)) LIKE 'H%'
	GROUP BY AP.author_id, A.name
	HAVING COUNT(DISTINCT P.year) = 30;""")

	query_list.append("""SELECT A.author_id, A.name, COUNT(*)
	FROM Author A JOIN PublicationAuthor AP
	ON A.author_id = AP.author_id
	WHERE A.author_id IN (
		-- Get the authors of Publication with the earliest Publication date
		SELECT DISTINCT AP.author_id
		FROM PublicationAuthor AP JOIN Publication P ON AP.publication_id = P.publication_id
		WHERE P.year = (SELECT MIN(year) FROM Publication)
		)
	GROUP BY A.author_id , A.name;""")

	query_list.append("""SELECT SPLIT_PART(A.name, ' ', 1) as firstname, COUNT(*)
	FROM Author A JOIN PublicationAuthor AP ON A.author_id = AP.author_id
	JOIN Publication P ON AP.publication_id = P.publication_id
	WHERE P.year BETWEEN '2016' AND '2017'
	GROUP BY SPLIT_PART(A.name, ' ', 1)
	ORDER BY COUNT(*) DESC
	LIMIT 5;""")

	return query_list
	
if __name__ == "__main__":
    print(main())