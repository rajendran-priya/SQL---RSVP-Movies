USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Adding this index to improve the performance since we are using these two tables extensively.

create index idx_rating on ratings(avg_rating, median_rating);
create index idx_movie on movie(id, title, year);

-- Segment 1:
-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT TABLE_NAME,
       TABLE_ROWS
FROM   INFORMATION_SCHEMA.tables
WHERE  TABLE_SCHEMA = 'imdb';

-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT
	SUM(
		CASE WHEN id IS NULL THEN
			1
		ELSE
			0
		END) AS n_ID,
	SUM(
		CASE WHEN title IS NULL THEN
			1
		ELSE
			0
		END) AS n_Title,
	SUM(
		CASE WHEN year IS NULL THEN
			1
		ELSE
			0
		END) AS n_Year,
	SUM(
		CASE WHEN date_published IS NULL THEN
			1
		ELSE
			0
		END) AS n_Date_published,
	SUM(
		CASE WHEN duration IS NULL THEN
			1
		ELSE
			0
		END) AS n_Duration,
	SUM(
		CASE WHEN country IS NULL THEN
			1
		ELSE
			0
		END) AS n_Country,
	SUM(
		CASE WHEN worlwide_gross_income IS NULL THEN
			1
		ELSE
			0
		END) AS n_WWgross,
	SUM(
		CASE WHEN languages IS NULL THEN
			1
		ELSE
			0
		END) AS n_Languages,
	SUM(
		CASE WHEN production_company IS NULL THEN
			1
		ELSE
			0
		END) AS n_production_company
FROM
	movie;

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

SELECT
	year,
	count(id) AS number_of_movies
FROM
	movie
GROUP BY
	year
ORDER BY
	year;

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT
	MONTH(date_published) AS Month_num,
	count(id) AS number_of_movies
FROM
	movie
GROUP BY
	MONTH(date_published)
ORDER BY
	MONTH(date_published);


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

WITH MOVIE_COUNT
AS
  (
           SELECT   COUNTRY,
                    COUNT(ID) AS NO_OF_MOVIES
           FROM     MOVIE
           WHERE    COUNTRY REGEXP 'USA'
           OR       COUNTRY REGEXP 'India'
           AND      YEAR=2019
           GROUP BY COUNTRY )
  SELECT SUM(NO_OF_MOVIES) AS TOTAL_MOVIES
  FROM   MOVIE_COUNT;


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT GENRE
FROM   genre G
ORDER  BY G.GENRE;

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT
	g.genre,
	count(m.id) AS genre_wise_movies_produced
FROM
	movie m
	INNER JOIN genre g ON m.id = g.movie_id
GROUP BY
	g.genre
ORDER BY
	count(m.id)
	DESC
LIMIT 1;

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

SELECT COUNT(*) AS no_movies_single_genre
FROM   (SELECT COUNT(GENRE) AS genre_count,
               MOVIE_ID
        FROM   genre
        GROUP  BY MOVIE_ID
        HAVING COUNT(GENRE) = 1) AS SINGLE_GENRE_MOVIES; 

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT G.GENRE,
       ROUND(AVG(M.DURATION), 2) AS 'average_duration'
FROM   genre G
       JOIN movie M
         ON G.MOVIE_ID = M.ID
GROUP  BY G.GENRE
ORDER  BY AVG(M.DURATION) DESC; 

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH genre_ranking AS (
	SELECT
		g.genre,
		count(m.id) AS num_of_movies,
		RANK() OVER (ORDER BY count(m.id)
			DESC) AS genre_rank
	FROM
		genre g
		INNER JOIN movie m ON m.id = g.movie_id
	GROUP BY
		g.genre
)
SELECT
	genre,
	num_of_movies,
	genre_rank
FROM
	genre_ranking
WHERE
	genre = 'Thriller';

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT MIN(AVG_RATING)    AS min_avg_rating,
       MAX(AVG_RATING)    AS max_avg_rating,
       MIN(TOTAL_VOTES)   AS min_total_votes,
       MAX(TOTAL_VOTES)   AS max_total_votes,
       MIN(MEDIAN_RATING) AS min_median_rating,
       MAX(MEDIAN_RATING) AS max_median_rating
FROM   ratings; 

    
/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH rank_movie AS 
(
SELECT m.title,
       r.avg_rating,
       DENSE_RANK()OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM ratings r
INNER JOIN movie m
ON m.id=r.movie_id
)
SELECT *
FROM rank_movie
WHERE movie_rank<=10;

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT
	median_rating,
	count(movie_id)
FROM
	ratings
GROUP BY
	median_rating
ORDER BY
	count(movie_id)
	DESC;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH PRODUCTION_COMPANY_RANK
     AS (SELECT PRODUCTION_COMPANY,
                Count(ID)                    AS movie_count,
                RANK()
                  OVER(
                    ORDER BY Count(ID) DESC) AS prod_company_rank
         FROM   movie M
                INNER JOIN ratings R
                        ON M.ID = R.MOVIE_ID
         WHERE  AVG_RATING > 8
                AND PRODUCTION_COMPANY IS NOT NULL
         GROUP  BY PRODUCTION_COMPANY)
SELECT *
FROM   PRODUCTION_COMPANY_RANK
WHERE  PROD_COMPANY_RANK = 1; 

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT G.GENRE     AS 'genre',
       COUNT(M.ID) AS 'movie_count'
FROM   genre G
       INNER JOIN movie M
               ON G.MOVIE_ID = M.ID
       INNER JOIN ratings R
               ON M.ID = R.MOVIE_ID
WHERE  MONTH(M.DATE_PUBLISHED) = 3
       AND YEAR = 2017
       AND M.COUNTRY LIKE '%USA%'
       AND R.TOTAL_VOTES > 1000
GROUP  BY G.GENRE
ORDER  BY COUNT(M.ID) DESC;

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT
	m.title,
	r.avg_rating,
	g.genre
FROM
	movie m
	INNER JOIN genre g ON m.id = g.movie_id
	INNER JOIN ratings r ON m.id = r.movie_id
WHERE
	m.title LIKE 'The%'
	AND r.avg_rating > 8
ORDER BY
	r.avg_rating DESC;

-- 
-- (Median rating) -- no useful insights
-- 
SELECT
	m.title,
	r.median_rating,
	g.genre
FROM
	movie m
	INNER JOIN genre g ON m.id = g.movie_id
	INNER JOIN ratings r ON m.id = r.movie_id
WHERE
	m.title LIKE 'The%'
	AND r.median_rating > 8
ORDER BY
	r.median_rating DESC;
-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT COUNT(M.ID) AS no_movies
FROM   movie M
       INNER JOIN ratings R
               ON R.MOVIE_ID = M.ID
WHERE  AVG_RATING = 8
       AND DATE_PUBLISHED BETWEEN '2018-04-01' AND '2019-04-01';

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

WITH MOVIE_ITALIAN_GERMAN_LIST
     AS (SELECT *,
                ( CASE
	                 WHEN (LANGUAGES LIKE '%German%'
                         AND LANGUAGES LIKE '%Italian%') THEN 'Both'
                    WHEN LANGUAGES LIKE '%German%' THEN 'German'
                    WHEN LANGUAGES LIKE '%Italian%' THEN 'Italian'
                    ELSE 'None'
                  END ) AS 'german_italian'
         FROM   movie)
SELECT GERMAN_ITALIAN,
       Sum(R.TOTAL_VOTES)
FROM   MOVIE_ITALIAN_GERMAN_LIST M
       INNER JOIN ratings R
               ON M.ID = R.MOVIE_ID
WHERE  M.GERMAN_ITALIAN IN ( 'German', 'Italian')
GROUP  BY GERMAN_ITALIAN;

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT
	SUM(
		CASE WHEN name IS NULL THEN
			1
		ELSE
			0
		END) AS name_nulls,
	SUM(
		CASE WHEN height IS NULL THEN
			1
		ELSE
			0
		END) AS height_nulls,
	SUM(
		CASE WHEN date_of_birth IS NULL THEN
			1
		ELSE
			0
		END) AS date_of_birth_nulls,
	SUM(
		CASE WHEN known_for_movies IS NULL THEN
			1
		ELSE
			0
		END) AS known_for_movies_nulls
FROM
	names;

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH TOP_GENRE
     AS (SELECT Count(MOVIE_ID)                    AS movie_count_genre,
                GENRE,
                RANK()
                  OVER(
                    ORDER BY Count(MOVIE_ID) DESC) AS rank_genre
         FROM   genre G
                INNER JOIN ratings R USING (MOVIE_ID)
         WHERE  AVG_RATING > 8
         GROUP  BY GENRE),
     TOP_DIRECTOR
     AS (SELECT N.NAME                               AS director_name,
                Count(G.MOVIE_ID)                    AS movie_count,
                DENSE_RANK()
                  OVER(
                    ORDER BY Count(G.MOVIE_ID) DESC) AS rank_directors
         FROM   names N
                INNER JOIN director_mapping DM
                        ON DM.NAME_ID = N.ID
                INNER JOIN movie M
                        ON DM.MOVIE_ID = M.ID
                INNER JOIN ratings R
                        ON M.ID = R.MOVIE_ID
                INNER JOIN genre G
                        ON G.MOVIE_ID = M.ID
         WHERE  G.GENRE IN (SELECT GENRE
                            FROM   TOP_GENRE
                            WHERE  RANK_GENRE <= 3)
                AND R.AVG_RATING > 8
         GROUP  BY N.NAME)
SELECT DIRECTOR_NAME,
       MOVIE_COUNT,
       RANK_DIRECTORS
FROM   TOP_DIRECTOR
WHERE  RANK_DIRECTORS <= 3; 
/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT N.NAME                 AS 'actor_name',
       COUNT(R.MEDIAN_RATING) AS 'movie_count'
FROM   names N
       INNER JOIN role_mapping RM
               ON N.ID = RM.NAME_ID
       INNER JOIN movie M
               ON RM.MOVIE_ID = M.ID
       INNER JOIN ratings R
               ON M.ID = R.MOVIE_ID
WHERE  RM.CATEGORY = 'actor'
       AND R.MEDIAN_RATING >= 8
GROUP  BY N.NAME
ORDER  BY MOVIE_COUNT DESC
LIMIT  2;

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT
	m.production_company,
	sum(r.total_votes) AS vote_count,
	Rank() OVER (ORDER BY Sum(r.total_votes)
		DESC) AS prod_comp_rank
FROM
	movie m
	INNER JOIN ratings r ON m.id = r.movie_id
WHERE
	m.production_company IS NOT NULL
GROUP BY
	m.production_company
LIMIT 3;


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT     N.NAME,
           COUNT(M.ID)                                                                                      AS TOTAL_MOVIES ,
           SUM(TOTAL_VOTES)                                                                                 AS TOTAL_VOTES,
           ROUND(SUM((TOTAL_VOTES*R.AVG_RATING))/SUM(TOTAL_VOTES),2)                                        AS ACTOR_AVG_RATING,
           RANK()OVER(ORDER BY SUM((TOTAL_VOTES*R.AVG_RATING))/SUM(TOTAL_VOTES) DESC,SUM(TOTAL_VOTES) DESC) AS ACTOR_RANK
FROM       MOVIE M
INNER JOIN RATINGS R
ON         R.MOVIE_ID=M.ID
INNER JOIN ROLE_MAPPING RM
ON         M.ID=RM.MOVIE_ID
INNER JOIN NAMES N
ON         N.ID=RM.NAME_ID
WHERE      COUNTRY REGEXP 'India'
AND        RM.CATEGORY='actor'
GROUP BY   N.NAME
HAVING     COUNT(M.ID)>=5;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH ACTRESS_RANK
AS
  (
             SELECT     N.NAME,
                        SUM(R.TOTAL_VOTES)                                            AS 'total_votes',
                        COUNT(M.ID)                                                   AS 'movie_count',
                        ROUND(SUM(R.TOTAL_VOTES * R.AVG_RATING)/SUM(R.TOTAL_VOTES),2) AS 'actress_avg_rating'
             FROM       NAMES N
             INNER JOIN ROLE_MAPPING RM
             ON         N.ID = RM.NAME_ID
             INNER JOIN MOVIE M
             ON         RM.MOVIE_ID = M.ID
             INNER JOIN RATINGS R
             ON         M.ID = R.MOVIE_ID
             WHERE      M.LANGUAGES LIKE '%Hindi%'
             AND        RM.CATEGORY ='actress'
             AND        M.COUNTRY LIKE '%India%'
             GROUP BY   NAME)
  SELECT   *,
           RANK() OVER (ORDER BY ACTRESS_AVG_RATING DESC, TOTAL_VOTES DESC) AS 'actress_rank'
  FROM     ACTRESS_RANK
  WHERE    MOVIE_COUNT >= 3
  ORDER BY ACTRESS_AVG_RATING DESC,
           TOTAL_VOTES DESC
  LIMIT    5;
 
/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
WITH CATEGORY_MOVIE
     AS (SELECT M.TITLE,
                CASE
                  WHEN R.AVG_RATING > 8 THEN 'Superhit movies'
                  WHEN R.AVG_RATING BETWEEN 7 AND 8 THEN 'Hit movies'
                  WHEN R.AVG_RATING BETWEEN 5 AND 7 THEN 'One-time-watch movies'
                  ELSE 'Flop movies'
                END AS movie_category
         FROM   ratings R
                INNER JOIN genre G
                        ON G.MOVIE_ID = R.MOVIE_ID
                INNER JOIN movie M
                        ON M.ID = R.MOVIE_ID
         WHERE  G.GENRE = 'thriller'
         ORDER  BY MOVIE_CATEGORY)
SELECT MOVIE_CATEGORY,
       Count(MOVIE_CATEGORY) AS category_count
FROM   CATEGORY_MOVIE
GROUP  BY MOVIE_CATEGORY; 

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT     G.GENRE,
           ROUND(AVG(M.DURATION),2)             AS AVG_DURATION,
           SUM(ROUND(AVG(M.DURATION),2))OVER W1 AS RUNNING_TOTAL_DURATION,
           AVG(ROUND(AVG(M.DURATION),2))OVER W2 AS MOVING_AVG_DURATION
FROM       MOVIE M
INNER JOIN GENRE G
ON         G.MOVIE_ID=M.ID
GROUP BY   G.GENRE WINDOW W1 AS (ORDER BY G.GENRE ROWS UNBOUNDED PRECEDING),
           W2                AS (ORDER BY G.GENRE ROWS 6 PRECEDING)
ORDER BY   G.GENRE;

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH genre_rank as
(
SELECT g.genre,
       COUNT(m.id) AS movie_count,
       RANK () OVER(ORDER BY COUNT(g.movie_id) DESC) AS rank_genre
FROM genre g
INNER JOIN movie m
ON m.id=g.movie_id
GROUP BY g.genre
),
total_income AS(
SELECT
     id,
     CASE 
           WHEN worlwide_gross_income REGEXP '^INR' 
           THEN ROUND(CAST(SUBSTR(worlwide_gross_income, 5) AS DECIMAL) / 80 )
           ELSE ROUND(CAST(SUBSTR(worlwide_gross_income, 3) AS DECIMAL) )
       END AS TOTAL_INCOME
FROM movie
),
rank_movie as
(
SELECT 
	   gr.genre,
       m.year,
       m.title AS movie_name,
       worlwide_gross_income,
       t.TOTAL_INCOME AS income_total,
       DENSE_RANK() OVER(PARTITION BY m.year ORDER BY t.TOTAL_INCOME DESC) AS movie_rank
FROM genre g
INNER JOIN genre_rank gr
ON g.genre=gr.genre
INNER JOIN movie m
ON m.id=g.movie_id
INNER JOIN total_income t
ON t.id=m.id
WHERE rank_genre<=3
)
SELECT *
FROM rank_movie
WHERE movie_rank<=5;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH PROD_COMPANY_RANK
AS
  (
             SELECT     PRODUCTION_COMPANY,
                        COUNT(ID)                                 AS MOVIE_COUNT,
                        DENSE_RANK()OVER(ORDER BY COUNT(ID) DESC) AS PROD_COMP_RANK
             FROM       MOVIE M
             INNER JOIN RATINGS R
             ON         M.ID=R.MOVIE_ID
             WHERE      M.LANGUAGES REGEXP ','
             AND        R.MEDIAN_RATING>=8
             AND        M.PRODUCTION_COMPANY IS NOT NULL
             GROUP BY   PRODUCTION_COMPANY )
  SELECT *
  FROM   PROD_COMPANY_RANK
  WHERE  PROD_COMP_RANK<=2;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH ACTRESS_BY_SUPERHIT_MOVIES
AS
  (
             SELECT     N.NAME             AS 'actress_name',
                        SUM(R.TOTAL_VOTES) AS 'total_votes',
                        COUNT(M.ID)        AS 'movie_count',
                        AVG(R.AVG_RATING)  AS 'actress_avg_rating',
                        ROUND(SUM(R.TOTAL_VOTES * R.AVG_RATING)/SUM(R.TOTAL_VOTES),2) AS 'actress_weighted_avg_rating'
             FROM       NAMES N
             INNER JOIN ROLE_MAPPING RM
             ON         N.ID = RM.NAME_ID
             INNER JOIN MOVIE M
             ON         RM.MOVIE_ID = M.ID
             INNER JOIN RATINGS R
             ON         M.ID = R.MOVIE_ID
             INNER JOIN GENRE G
             ON         M.ID = G.MOVIE_ID
             WHERE      RM.CATEGORY ='actress'
             AND        G.GENRE = 'Drama'
             GROUP BY   N.NAME)
  SELECT   *,
           ROW_NUMBER() OVER (ORDER BY MOVIE_COUNT DESC, ACTRESS_WEIGHTED_AVG_RATING DESC) AS 'actress_rank'
  FROM     ACTRESS_BY_SUPERHIT_MOVIES
  HAVING   ACTRESS_AVG_RATING > 8
  LIMIT    3;

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH movie_release_date AS (
	SELECT
		d.name_id,
		n.name,
		d.movie_id,
		m.date_published,
		LEAD(date_published,1) OVER (PARTITION BY d.name_id ORDER BY date_published, d.movie_id) AS next_release_date
	FROM
		names n 
		JOIN director_mapping d ON d.name_id = n.id
		JOIN movie m ON m.id = d.movie_id
),
date_difference AS (
SELECT
	*,
	DATEDIFF(next_release_date, date_published) AS date_differ
FROM
	movie_release_date
),
avg_inter_days AS (
SELECT
	name_id,
	AVG(date_differ) AS avg_dates_btw_movie
FROM
	date_difference
GROUP BY
	name_id
),
avg_date_and_director_rank AS (
SELECT
	d.name_id AS director_id,
	name AS director_name,
	COUNT(d.movie_id) AS number_of_movies,
	ROUND(avg_dates_btw_movie) AS avg_inter_movie_days,
	ROUND(AVG(r.avg_rating),2) AS avg_rating,
	SUM(r.total_votes) AS total_votes,
	MIN(r.avg_rating) AS min_rating,
	MAX(r.avg_rating) AS max_rating,
	SUM(m.duration) AS total_duration,
	RANK() OVER (ORDER BY COUNT(d.movie_id)DESC) AS director_rank
FROM
	names AS n
	JOIN director_mapping d ON n.id = d.name_id
	JOIN ratings r ON d.movie_id = r.movie_id
	JOIN movie m ON m.id = r.movie_id
	JOIN avg_inter_days a ON a.name_id = d.name_id
GROUP BY
	d.name_id
)
SELECT
	*
FROM
	avg_date_and_director_rank
LIMIT 9;





