create table titles(
	id varchar,
	title varchar,
	type varchar,
	description varchar,
	release_year int,
	age_certification varchar,
	runtime int,
	genres varchar,
	production_countries varchar,
	seasons varchar,
	imdb_id varchar,
	imdb_score float,
	imdb_votes float,
	tmdb_popularity float,
	tmdb_score float);

copy titles from 'Y:\cuvette\Final evaluation project\Sql Project\titles.csv' delimiter ',' csv header;

create table credits(
	person_id int,
	id varchar,
	name varchar,
	character varchar,
	role varchar);

copy credits from 'Y:\cuvette\Final evaluation project\Sql Project\credits.csv' delimiter ',' csv header;

select * from titles;
select * from credits;

--1.What were the top 10 movies according to IMDB score?
select title,imdb_score from titles where imdb_score IS NOT NULL AND type='MOVIE' order by imdb_score desc limit 10;

--2.What were the top 10 shows according to IMDB score?
select title,imdb_score from titles where imdb_score IS NOT NULL AND type='SHOW' order by imdb_score desc limit 10;

--3.What were the bottom 10 movies according to IMDB score?
select title,imdb_score from titles where imdb_score IS NOT NULL AND type='MOVIE' order by imdb_score limit 10;

--4.What were the bottom 10 shows according to IMDB score?
select title,imdb_score from titles where imdb_score IS NOT NULL AND type='SHOW' order by imdb_score limit 10;

--5.What were the average IMDB and TMDB scores for shows and movies?
SELECT 
    type,
    AVG(imdb_score) AS avg_imdb_score,
    AVG(tmdb_score) AS avg_tmdb_score
FROM titles
WHERE imdb_score IS NOT NULL AND tmdb_score IS NOT NULL
GROUP BY type;

--6.Count of movies and shows in each decade
SELECT 
    FLOOR(release_year / 10) * 10 AS decade,  
    type,  
    COUNT(*) AS count  
FROM titles  
WHERE release_year IS NOT NULL  
GROUP BY decade, type  
ORDER BY decade ASC, type;

--7.What were the average IMDB and TMDB scores for each production country?
SELECT 
    production_countries,  
    AVG(imdb_score) AS avg_imdb_score,  
    AVG(tmdb_score) AS avg_tmdb_score  
FROM titles  
WHERE imdb_score IS NOT NULL AND tmdb_score IS NOT NULL  
GROUP BY production_countries ;

--8.What were the average IMDB and TMDB scores for each age certification for shows and movies?
SELECT 
    age_certification,  
    AVG(imdb_score) AS avg_imdb_score,  
    AVG(tmdb_score) AS avg_tmdb_score  
FROM titles  
WHERE imdb_score IS NOT NULL AND tmdb_score IS NOT NULL  
GROUP BY age_certification;

--9.What were the 5 most common age certifications for movies?
SELECT age_certification, COUNT(*) AS count
FROM titles
WHERE type = 'MOVIE' AND age_certification IS NOT NULL
GROUP BY age_certification
ORDER BY count DESC
LIMIT 5;

--10.Who were the top 20 actors that appeared the most in movies/shows?
SELECT 
    c.name AS actor_name, 
    COUNT(*) AS appearance_count
FROM credits c
JOIN titles t ON c.id = t.id
WHERE c.role = 'ACTOR'
GROUP BY c.name
ORDER BY appearance_count DESC
LIMIT 20;
	
--11.Who were the top 20 directors that directed the most movies/shows?
SELECT 
    c.name AS actor_name, 
    COUNT(*) AS appearance_count
FROM credits c
JOIN titles t ON c.id = t.id
WHERE c.role = 'DIRECTOR'
GROUP BY c.name
ORDER BY appearance_count DESC
LIMIT 20;

--12.Calculating the average runtime of movies and TV shows separately
SELECT 'MOVIE' AS Type,AVG(runtime) AS Average_Runtime
FROM titles WHERE type = 'MOVIE'
UNION ALL
SELECT 'SHOW' AS Type, AVG(runtime) AS Average_Runtime
FROM titles WHERE type = 'SHOW';

--13.Finding the titles and directors of movies released on or after 2010
select a.title,b.name as Director_name from titles as a
	join credits as b on a.id=b.id
	where a.release_year>=2010 and b.role='DIRECTOR';

--14.Which shows on Netflix have the most seasons?
select title,seasons from titles where seasons IS NOT NULL order by seasons desc limit 1;

--15.Which genres had the most movies?
select genres,count(*) as movie_count
	from(select id,trim(UNNEST(STRING_TO_ARRAY(genres, ',')))as genres
	from titles a where a.type='MOVIE' and a.genres IS NOT NULL)genre_split group by genres
	order by movie_count desc;

--16.Which genres had the most shows?
select genres,count(*) as show_count
	from(select id,trim(UNNEST(STRING_TO_ARRAY(genres, ',')))as genres
	from titles a where a.type='SHOW' and a.genres IS NOT NULL)genre_split group by genres
	order by show_count desc;

--17.Titles and Directors of movies with high IMDB scores (>7.5) and high TMDB popularity scores (>80)
select a.title,b.name as director_name from titles as a join credits as b on a.id=b.id
	where a.imdb_score>7.5 and a.tmdb_popularity>80 and 
	a.imdb_score IS NOT NULL and a.tmdb_popularity IS NOT NULL and b.role='DIRECTOR';
	
--18.What were the total number of titles for each year?
select release_year,count(*)as total_number from titles 
	group by release_year order by release_year;
	
--19.Actors who have starred in the most highly rated movies or shows
select count(a.id) as movie_count,avg(a.imdb_score) as avg_rating,b.person_id,b.name
	from titles as a join credits as b 
	on a.id=b.id 
	where a.imdb_score IS NOT NULL and a.imdb_score>=8.0  and b.role='ACTOR' group by b.person_id ,b.name
	order by movie_count desc,avg_rating desc;
	
--20.Which actors/actresses played the same character in multiple movies or TV shows?
select b.name,b.character,count(distinct a.id) as num_titles
	from titles as a join credits as b on a.id=b.id
	where b.character IS NOT NULL group by b.name,b.character having count(distinct a.id )>1
	order by num_titles desc;

--21.What were the top 3 most common genres?
select genres,count(*)as total_genres from titles group by genres order by total_genres desc limit 3;

--22.Average IMDB score for leading actors/actresses in movies or shows
select b.name,avg(a.imdb_score) as avg_imdb_score
	from titles as a join credits as b 
	on a.id=b.id 
	where a.imdb_score IS NOT NULL and a.imdb_score>=8.0 and type='MOVIE' and b.role='ACTOR' group by b.name
	order by avg_imdb_score desc;

--23.Which movies or shows had the highest number of votes?
select title,imdb_votes from titles where type='MOVIE' and imdb_votes IS NOT NULL
	 order by imdb_votes desc ;

--24.Which movies or shows had the longest runtime?
select title,runtime from titles where type='MOVIE' and runtime IS NOT NULL
	 order by runtime desc ;

--25.What were the top 5 most popular genres for movies?
select genres,count(*)as popularity from titles where type='MOVIE' and genres IS NOT NULL
	group by genres order by popularity desc limit 5 ;

--26.How many movies or shows were released each year?
select release_year,count(*)as total_number from titles where type='MOVIE'
	group by release_year order by release_year;

--27.Which actors appeared in the most genres?
select b.name,count(distinct a.genres)as genre_count from titles as a join credits as b
	on a.id=b.id where b.role='ACTOR' group by b.name order by genre_count desc;

--28.Which production countries have the highest number of movies or shows?
select production_countries ,count(*) as count from titles where type='MOVIE' group by production_countries order by count desc;

--29.Which actors have the highest average rating across all their movies/shows?
select c.name as actor_name,avg(rating.imdb_score)as avarage_rating
	from credits as c
	left join(
	select c.person_id,t.imdb_score from credits as c join titles as t on c.id=t.id where t.type='MOVIE'
	union all
	select c.person_id,t.imdb_score from credits as c join titles as t on c.id=t.id where t.type='SHOW'	
	) as rating on c.person_id=rating.person_id 
	group by c.name having count(rating.imdb_score)>0 
	order by avarage_rating desc;

--30.Which shows had the most seasons?
select title,count(seasons) as num_seasons from titles where type='SHOW' group by title order by num_seasons desc;
	
--31.Which movies had the highest box office revenue?
select title ,imdb_votes from titles where imdb_votes IS NOT NULL order by imdb_votes desc ;
	
--32.Which directors have worked on the most movies or shows?
select c.name as directors_name,count(distinct(t.type='MOVIE'))+count(distinct(t.type='SHOW')) as total 
	from titles  as t join credits as c on c.id=t.id where c.role='DIRECTOR' group by c.name 
	order by total desc;
	
--33.What are the most common keywords or phrases in movie titles?
select word,count(*) as frequncy from(
	select unnest(string_to_array(lower(title),' ')) as word from titles
)as words
	where word NOT IN('a', 'an', 'the', 'of', 'and', 'to', 'in', 'on', 'with', 'by')
	group by word order by frequncy desc;

--34.Which actors or actresses have the most frequent collaborations with the same director?
select a.person_id as actor_id,d.person_id as director_id,count(*)as collabration_count from credits a
	join credits d on a.id=d.id
	where a.role='ACTOR' and d.role='DIRECTOR' group by a.person_id,d.person_id
	order by collabration_count desc;

--35.What were the most common movie ratings (IMDB scores) for movies released in a particular decade?
select imdb_score,count(*) as frequncy from titles 
	where release_year between 2000 and 2009 and imdb_score IS NOT NULL
	group by imdb_score order by frequncy desc,imdb_score desc;

--36.Which movies or shows had the highest popularity score on TMDB?
select title,type,tmdb_popularity from titles where tmdb_popularity IS NOT NULL order by tmdb_popularity desc;

--37.How many actors or actresses have starred in both movies and TV shows?
select count(distinct c.person_id)as actor_count
from credits as c join titles as t on c.id=t.id
where c.role ='ACTOR' and t.type in('MOVIE','SHOW') group by t.type having count(distinct c.person_id)>1;


