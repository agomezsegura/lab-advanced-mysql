USE publications;

SELECT * FROM authors;
SELECT * FROM sales;
SELECT * FROM titleauthor;
SELECT * FROM titles;

-- CHALLENGE 1
	-- Step 1
SELECT 
    ta.title_id,
    ta.au_id,
    t.advance * ta.royaltyper / 100 AS advance,
    t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS sales_royalty
FROM
    titleauthor AS ta
        LEFT JOIN
    titles t USING (title_id)
        LEFT JOIN
    sales s USING (title_id);
    
	-- Step 2
SELECT 
    sb.title_id,
    sb.au_id,
    SUM(sb.sales_royalty) AS total_sales_royalty
FROM
    (SELECT 
        ta.title_id,
            ta.au_id,
            t.advance * ta.royaltyper / 100 AS advance,
            t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS sales_royalty
    FROM
        titleauthor AS ta
    LEFT JOIN titles t USING (title_id)
    LEFT JOIN sales s USING (title_id)) sb
GROUP BY sb.au_id , sb.title_id;

	-- Step 3
SELECT 
    sb2.au_id,
    sb2.advance + SUM(sb2.total_sales_royalty) AS PROFIT
FROM
    (SELECT 
        sb.title_id,
            sb.au_id,
            sb.advance,
            SUM(sb.sales_royalty) AS total_sales_royalty
    FROM
        (SELECT 
        ta.title_id,
            ta.au_id,
            t.advance * ta.royaltyper / 100 AS advance,
            t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS sales_royalty
    FROM
        titleauthor AS ta
    LEFT JOIN titles t USING (title_id)
    LEFT JOIN sales s USING (title_id)) sb
    GROUP BY sb.au_id , sb.title_id) sb2
GROUP BY sb2.au_id
ORDER BY PROFIT DESC
LIMIT 3;

-- CHALLENGE 2
	-- Step 1
CREATE TEMPORARY TABLE profit_each_sale
SELECT 
    ta.title_id,
    ta.au_id,
    t.advance * ta.royaltyper / 100 AS advance,
    t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS sales_royalty
FROM
    titleauthor AS ta
        LEFT JOIN
    titles t USING (title_id)
        LEFT JOIN
    sales s USING (title_id);
    
	-- Step 2
DROP TABLE profit_one_title;
CREATE TEMPORARY TABLE profit_one_title
SELECT 
    pes.title_id,
    pes.au_id,
    pes.advance,
    SUM(pes.sales_royalty) AS total_sales_royalty
FROM profit_each_sale pes
GROUP BY pes.au_id , pes.title_id;

	-- Step 3
SELECT 
    pot.au_id,
    pot.advance + SUM(pot.total_sales_royalty) AS PROFIT
FROM profit_one_title pot
GROUP BY pot.au_id
ORDER BY PROFIT DESC
LIMIT 3;

-- CHALLENGE 3

CREATE TABLE most_profiting_authors
SELECT 
    pot.au_id,
    pot.advance + SUM(pot.total_sales_royalty) AS PROFIT
FROM profit_one_title pot
GROUP BY pot.au_id
ORDER BY PROFIT DESC;