Q1:

-- Without any index: Time: 6147.494 ms

---Time: 6046.094 ms
CREATE INDEX PubCategoryIndex ON Publication(category);

-- Time: 6259.863 ms
CREATE INDEX PubYearIndex ON Publication(year);

-- If the SELECT returns more than approximately 5-10% of all rows in the table, a sequential scan is much faster than an index scan.
-- QUERY PLAN
-- -----------------------------------------------------------------------------------------
-- HashAggregate  (cost=99267.56..99267.60 rows=4 width=19)
-- Group Key: category
-- ->  Bitmap Heap Scan on publication  (cost=3192.77..98516.17 rows=150277 width=11)
-- Recheck Cond: ((year >= '2000'::text) AND (year <= '2001'::text))
-- ->  Bitmap Index Scan on pubyearindex  (cost=0.00..3155.20 rows=150277 width=0)
-- Index Cond: ((year >= '2000'::text) AND (year <= '2001'::text))
Q2:
-- Without any indexes: Time: 1739.136 ms
-- Due to the same reasoning as above no attribute was found to be sutiable for being used as an index

Q3a:
-- Without any indexes: Time: 2155.030 ms
-- Tried indexing using the following index
CREATE INDEX PubYearIndex ON Publication(year);
-- According to the query plan the psql optimizer found the primary key of the publication table(publication_id)
-- to be more suitable during the execution due to the join clause

-- QUERY PLAN
----------------------------------------------------------------------------------------------
-- Nested Loop  (cost=188.00..189794.37 rows=4 width=169)
-- ->  Hash Semi Join  (cost=187.57..189768.57 rows=52 width=4)
-- Hash Cond: (ap.author_id = author.author_id)
-- ->  Seq Scan on publicationauthor ap  (cost=0.00..160392.62 rows=11119162 width=8)
-- ->  Hash  (cost=187.56..187.56 rows=1 width=4)
-- ->  Limit  (cost=0.00..187.55 rows=1 width=4)
-- ->  Seq Scan on author  (cost=0.00..37322.88 rows=199 width=4)
-- Filter: (name ~~* '%Ursula Goltz%'::text)
-- ->  Index Scan using publication_pkey on publication p  (cost=0.43..0.49 rows=1 width=169)
-- Index Cond: (publication_id = ap.publication_id)
-- Filter: (year = '2015'::text)
