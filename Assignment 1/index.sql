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
 Q3b:
 -- Without any indexes: Time: 1580.799 ms
 -- Tried indexing using the following index
 CREATE INDEX PubConfnameIndex ON Publication(conf_name);
 -- According to the query plan the psql optimizer found the primary key of the publication table(publication_id)
 -- to be more suitable during the execution due to the join clause

--  QUERY PLAN
-- ----------------------------------------------------------------------------------------------
-- Nested Loop  (cost=188.00..189794.50 rows=1 width=169)
-- ->  Hash Semi Join  (cost=187.57..189768.57 rows=52 width=4)
-- Hash Cond: (ap.author_id = author.author_id)
-- ->  Seq Scan on publicationauthor ap  (cost=0.00..160392.62 rows=11119162 width=8)
-- ->  Hash  (cost=187.56..187.56 rows=1 width=4)
-- ->  Limit  (cost=0.00..187.55 rows=1 width=4)
-- ->  Seq Scan on author  (cost=0.00..37322.88 rows=199 width=4)
-- Filter: (name ~~* '%Peter Mowforth%'::text)
-- ->  Index Scan using publication_pkey on publication p  (cost=0.43..0.49 rows=1 width=169)
-- Index Cond: (publication_id = ap.publication_id)
-- Filter: ((year = '1990'::text) AND (conf_name = 'bmvc'::text))

Q3c:
 -- Without any indexes: Time: 1752.829 ms
 -- With year: Time: 1210.786 ms
 -- With conf_name: Time: 1152.320 ms
 -- With year, conf_name: Time: 1161.550 ms



-- QUERY PLAN
-- ----------------------------------------------------------------------------------------------------------------------
-- GroupAggregate  (cost=189727.48..189727.59 rows=6 width=15)
-- Group Key: a.name
-- Filter: (count(*) > 1)
-- ->  Sort  (cost=189727.48..189727.50 rows=6 width=15)
-- Sort Key: a.name
-- ->  Nested Loop  (cost=144.58..189727.41 rows=6 width=15)
-- ->  Hash Semi Join  (cost=144.15..189724.64 rows=6 width=4)
-- Hash Cond: (ap.publication_id = p.publication_id)
-- ->  Seq Scan on publicationauthor ap  (cost=0.00..160392.62 rows=11119162 width=8)
-- ->  Hash  (cost=144.14..144.14 rows=1 width=4)
-- ->  Bitmap Heap Scan on publication p  (cost=140.12..144.14 rows=1 width=4)
-- Recheck Cond: ((conf_name = 'bmvc'::text) AND (year = '1990'::text))
-- ->  BitmapAnd  (cost=140.12..140.12 rows=1 width=0)
-- ->  Bitmap Index Scan on pubconfnameindex  (cost=0.00..18.25 rows=776 width=0)
-- Index Cond: (conf_name = 'bmvc'::text)
-- ->  Bitmap Index Scan on pubyearindex  (cost=0.00..121.62 rows=6559 width=0)
-- Index Cond: (year = '1990'::text)
-- ->  Index Scan using author_pkey on author a  (cost=0.43..0.45 rows=1 width=19)
-- Index Cond: (author_id = ap.author_id)


Q4a:
-- Without any indexes: Time: 2327.277 ms
-- With author id anf conf_name = Time: 1629.400 ms

QUERY PLAN
------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=225528.30..295791.99 rows=20422 width=19)
Group Key: a.author_id
Filter: (count(*) = 2)
->  Merge Join  (cost=225528.30..295485.66 rows=20422 width=19)
Merge Cond: (ap.author_id = a.author_id)
->  GroupAggregate  (cost=225527.87..225936.31 rows=20422 width=17)
Group Key: ap.author_id, p.conf_name
Filter: (count(*) >= 10)
->  Sort  (cost=225527.87..225578.93 rows=20422 width=9)
Sort Key: ap.author_id, p.conf_name
->  Hash Join  (cost=21772.18..224065.88 rows=20422 width=9)
Hash Cond: (ap.publication_id = p.publication_id)
->  Seq Scan on publicationauthor ap  (cost=0.00..160392.62 rows=11119162 width=8)
->  Hash  (cost=21684.47..21684.47 rows=7017 width=9)
->  Bitmap Heap Scan on publication p  (cost=135.23..21684.47 rows=7017 width=9)
Recheck Cond: (conf_name = ANY ('{pvldb,sigmod}'::text[]))
->  Bitmap Index Scan on pubconfnameindex  (cost=0.00..133.48 rows=7017 width=0)
Index Cond: (conf_name = ANY ('{pvldb,sigmod}'::text[]))
->  Index Scan using author_pkey on author a  (cost=0.43..64118.08 rows=1988710 width=19)

Q4b:
-- Without any indexes: Time: 3488.864 ms
-- with conf Time: 2470.448 ms
QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------
Nested Loop  (cost=205153.04..429345.82 rows=994355 width=15)
->  Subquery Scan on "ANY_subquery"  (cost=205152.62..410435.07 rows=2258 width=4)
->  HashSetOp Except  (cost=205152.62..410412.49 rows=2258 width=8)
->  Append  (cost=205152.62..410401.20 rows=4516 width=8)
->  Subquery Scan on "*SELECT* 1"  (cost=205152.62..205214.71 rows=2258 width=8)
->  GroupAggregate  (cost=205152.62..205192.13 rows=2258 width=4)
Group Key: ap.author_id
Filter: (count(*) >= 15)
->  Sort  (cost=205152.62..205158.26 rows=2258 width=4)
Sort Key: ap.author_id
->  Hash Join  (cost=2914.78..205026.84 rows=2258 width=4)
Hash Cond: (ap.publication_id = p.publication_id)
->  Seq Scan on publicationauthor ap  (cost=0.00..160392.62 rows=11119162 width=8)
->  Hash  (cost=2905.08..2905.08 rows=776 width=4)
->  Bitmap Heap Scan on publication p  (cost=18.44..2905.08 rows=776 width=4)
Recheck Cond: (conf_name = 'pvldb'::text)
->  Bitmap Index Scan on conf  (cost=0.00..18.25 rows=776 width=0)
   Index Cond: (conf_name = 'pvldb'::text)
->  Subquery Scan on "*SELECT* 2"  (cost=205152.62..205186.49 rows=2258 width=8)
->  Group  (cost=205152.62..205163.91 rows=2258 width=4)
Group Key: ap_1.author_id
->  Sort  (cost=205152.62..205158.26 rows=2258 width=4)
Sort Key: ap_1.author_id
->  Hash Join  (cost=2914.78..205026.84 rows=2258 width=4)
Hash Cond: (ap_1.publication_id = p_1.publication_id)
->  Seq Scan on publicationauthor ap_1  (cost=0.00..160392.62 rows=11119162 width=8)
->  Hash  (cost=2905.08..2905.08 rows=776 width=4)
->  Bitmap Heap Scan on publication p_1  (cost=18.44..2905.08 rows=776 width=4)
Recheck Cond: (conf_name = 'kdd'::text)
->  Bitmap Index Scan on conf  (cost=0.00..18.25 rows=776 width=0)
   Index Cond: (conf_name = 'kdd'::text)
->  Index Scan using author_pkey on author a  (cost=0.43..8.37 rows=1 width=19)
Index Cond: (author_id = "ANY_subquery".author_id)
Q5:
-- Without any indexes: Time: 7256.297 ms
-- with tried substring create indexes - Made no difference
CREATE INDEX PubSubYearIndex ON Publication(substring(year, 1, 3))

QUERY PLAN
-----------------------------------------------------------------------------
HashAggregate  (cost=175738.08..175738.93 rows=68 width=40)
Group Key: "substring"(year, 1, 3)
->  Seq Scan on publication  (cost=0.00..156702.14 rows=3807189 width=32)
Filter: ((year >= '1970'::text) AND (year <= '2019'::text))
Q6:
-- Without any indexes: Time: 65296.033 ms
QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Limit  (cost=27579842.08..27579842.11 rows=10 width=23)
->  Sort  (cost=27579842.08..27579859.78 rows=7078 width=23)
Sort Key: q2.collaborators_count DESC
->  Hash Join  (cost=26689420.81..27579689.13 rows=7078 width=23)
Hash Cond: (q2.author_id = author.author_id)
->  Subquery Scan on q2  (cost=26278099.46..27165030.38 rows=212964 width=12)
->  GroupAggregate  (cost=26278099.46..27162900.74 rows=212964 width=12)
Group Key: pa1.author_id
->  Sort  (cost=26278099.46..26572323.34 rows=117689552 width=8)
Sort Key: pa1.author_id
->  Merge Join  (cost=3531486.87..5674460.66 rows=117689552 width=8)
Merge Cond: (pa1.publication_id = pa2.publication_id)
Join Filter: (pa1.author_id <> pa2.author_id)
->  Sort  (cost=1765743.43..1793541.34 rows=11119162 width=8)
Sort Key: pa1.publication_id
->  Seq Scan on publicationauthor pa1  (cost=0.00..160392.62 rows=11119162 width=8)
->  Materialize  (cost=1765743.43..1821339.24 rows=11119162 width=8)
->  Sort  (cost=1765743.43..1793541.34 rows=11119162 width=8)
Sort Key: pa2.publication_id
->  Seq Scan on publicationauthor pa2  (cost=0.00..160392.62 rows=11119162 width=8)
->  Hash  (cost=410107.12..410107.12 rows=66099 width=23)
->  Hash Semi Join  (cost=370147.82..410107.12 rows=66099 width=23)
Hash Cond: (author.author_id = ap.author_id)
->  Seq Scan on author  (cost=0.00..32351.10 rows=1988710 width=19)
->  Hash  (cost=369321.59..369321.59 rows=66099 width=4)
->  Hash Join  (cost=166571.12..369321.59 rows=66099 width=4)
Hash Cond: (ap.publication_id = p.publication_id)
->  Seq Scan on publicationauthor ap  (cost=0.00..160392.62 rows=11119162 width=8)
->  Hash  (cost=166287.22..166287.22 rows=22712 width=4)
->  Seq Scan on publication p  (cost=0.00..166287.22 rows=22712 width=4)
Filter: (((parent_type = 'journals'::text) OR (parent_type = 'conf'::text)) AND (lower(title) ~~ '%data%'::text))
Q7:
-- Without any indexes: Time: 8804.659 ms
-- With parent tyoe no diff.
-- With year Time: 8808.159 ms


QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Limit  (cost=360790.60..360790.62 rows=10 width=27)
->  Sort  (cost=360790.60..360843.64 rows=21216 width=27)
Sort Key: (count(*)) DESC
->  GroupAggregate  (cost=359960.85..360332.13 rows=21216 width=27)
Group Key: a.author_id
->  Sort  (cost=359960.85..360013.89 rows=21216 width=19)
Sort Key: a.author_id
->  Nested Loop  (cost=146344.92..358436.17 rows=21216 width=19)
->  Hash Join  (cost=146344.49..348646.13 rows=21216 width=4)
Hash Cond: (pa.publication_id = p.publication_id)
->  Seq Scan on publicationauthor pa  (cost=0.00..160392.62 rows=11119162 width=8)
->  Hash  (cost=146253.37..146253.37 rows=7290 width=4)
->  Bitmap Heap Scan on publication p  (cost=25721.14..146253.37 rows=7290 width=4)
Recheck Cond: ((year >= '2013'::text) AND (year <= '2017'::text))
Filter: (((parent_type = 'journals'::text) OR (parent_type = 'conf'::text)) AND (lower(title) ~~ '%data%'::text))
->  Bitmap Index Scan on year  (cost=0.00..25719.32 rows=1226289 width=0)
Index Cond: ((year >= '2013'::text) AND (year <= '2017'::text))
->  Index Scan using author_pkey on author a  (cost=0.43..0.45 rows=1 width=19)
Index Cond: (author_id = pa.author_id)
Q8:
-- Without any indexes: Time: 827.198 ms
-- Tried conf, year, parent type and category
-- Used categroy Time: 696.109

QUERY PLAN
---------------------------------------------------------------------------------------------
HashAggregate  (cost=127276.90..127613.31 rows=33641 width=10)
Group Key: conf_name
->  HashAggregate  (cost=126856.39..127192.80 rows=33641 width=10)
Group Key: conf_name, year
Filter: (count(*) > 100)
->  Index Scan using cat on publication  (cost=0.43..126586.19 rows=36026 width=10)
Index Cond: (category = 'inproceedings'::text)
Filter: ((mdate ~~ '%-07-%'::text) AND (parent_type = 'conf'::text))

Q9a:
-- Without any indexes: Time: 9380.156 ms
-- Tried year and author name no difference
-- used only existing publication primary key
QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=306830.40..307903.30 rows=53645 width=19)
Group Key: ap.author_id, a.name
Filter: (count(DISTINCT p.year) = 30)
->  Sort  (cost=306830.40..306964.51 rows=53645 width=24)
Sort Key: ap.author_id, a.name
->  Nested Loop  (cost=72250.03..302616.27 rows=53645 width=24)
->  Hash Join  (cost=72249.60..274895.06 rows=55598 width=23)
Hash Cond: (ap.author_id = a.author_id)
->  Seq Scan on publicationauthor ap  (cost=0.00..160392.62 rows=11119162 width=8)
->  Hash  (cost=72125.30..72125.30 rows=9944 width=19)
->  Seq Scan on author a  (cost=0.00..72125.30 rows=9944 width=19)
Filter: ("substring"(name, ((length(name) - strpos(reverse(name), ' '::text)) + 2), length(name)) ~~ 'H%'::text)
->  Index Scan using publication_pkey on publication p  (cost=0.43..0.49 rows=1 width=9)
Index Cond: (publication_id = ap.publication_id)
Filter: ((year >= '1988'::text) AND (year <= '2017'::text))

Q9b:
-- Without any indexes: Time: 8160.867 ms
-- Tried year worked :  Time: 4519.729 ms
GroupAggregate  (cost=784984.99..800984.21 rows=914241 width=27)
  Group Key: a.author_id
  ->  Sort  (cost=784984.99..787270.59 rows=914241 width=19)
        Sort Key: a.author_id
        ->  Hash Join  (cost=376654.62..675715.51 rows=914241 width=19)
              Hash Cond: (ap.author_id = a.author_id)
              ->  Seq Scan on publicationauthor ap  (cost=0.00..160392.62 rows=11119162 width=4)
              ->  Hash  (cost=373651.67..373651.67 rows=163516 width=23)
                    ->  Hash Semi Join  (cost=310316.09..373651.67 rows=163516 width=23)
                          Hash Cond: (a.author_id = ap_1.author_id)
                          ->  Seq Scan on author a  (cost=0.00..32351.10 rows=1988710 width=19)
                          ->  Hash  (cost=307633.14..307633.14 rows=163516 width=4)
                                ->  Unique  (cost=305180.40..305997.98 rows=163516 width=4)
                                      InitPlan 2 (returns $1)
                                        ->  Result  (cost=0.55..0.56 rows=1 width=32)
                                              InitPlan 1 (returns $0)
                                                ->  Limit  (cost=0.43..0.55 rows=1 width=5)
                                                      ->  Index Only Scan using year on publication  (cost=0.43..467969.26 rows=3820611 width=5)
                                                            Index Cond: (year IS NOT NULL)
                                      ->  Sort  (cost=305179.84..305588.63 rows=163516 width=4)
                                            Sort Key: ap_1.author_id
                                            ->  Hash Join  (cost=85058.97..288783.61 rows=163516 width=4)
                                                  Hash Cond: (ap_1.publication_id = p.publication_id)
                                                  ->  Seq Scan on publicationauthor ap_1  (cost=0.00..160392.62 rows=11119162 width=8)
                                                  ->  Hash  (cost=84356.66..84356.66 rows=56185 width=4)
                                                        ->  Bitmap Heap Scan on publication p  (cost=1055.86..84356.66 rows=56185 width=4)
                                                              Recheck Cond: (year = $1)
                                                              ->  Bitmap Index Scan on year  (cost=0.00..1041.82 rows=56185 width=0)
                                                                    Index Cond: (year = $1)
Q10:
-- Without any indexes: Time: 24511.822 ms
-- With year :  20040.772 ms

QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------
Limit  (cost=774034.65..774034.67 rows=5 width=40)
->  Sort  (cost=774034.65..777301.83 rows=1306872 width=40)
Sort Key: (count(*)) DESC
->  GroupAggregate  (cost=726190.54..752327.98 rows=1306872 width=40)
Group Key: (split_part(a.name, ' '::text, 1))
->  Sort  (cost=726190.54..729457.72 rows=1306872 width=32)
Sort Key: (split_part(a.name, ' '::text, 1))
->  Hash Join  (cost=182373.00..530889.46 rows=1306872 width=32)
Hash Cond: (ap.author_id = a.author_id)
->  Hash Join  (cost=113510.03..417293.23 rows=1306872 width=4)
Hash Cond: (ap.publication_id = p.publication_id)
->  Seq Scan on publicationauthor ap  (cost=0.00..160392.62 rows=11119162 width=8)
->  Hash  (cost=106141.92..106141.92 rows=449049 width=4)
->  Bitmap Heap Scan on publication p  (cost=9531.18..106141.92 rows=449049 width=4)
Recheck Cond: ((year >= '2016'::text) AND (year <= '2017'::text))
->  Bitmap Index Scan on year  (cost=0.00..9418.92 rows=449049 width=0)
Index Cond: ((year >= '2016'::text) AND (year <= '2017'::text))
->  Hash  (cost=32351.10..32351.10 rows=1988710 width=19)
