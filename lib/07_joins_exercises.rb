# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
  SELECT
    title
  FROM
    movies
  JOIN
    castings ON movies.id = castings.movie_id
  JOIN
    actors ON castings.actor_id = actors.id
  WHERE
    actors.name = 'Harrison Ford'
  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
  SELECT
    title
  FROM
    movies
  JOIN
    castings ON movies.id = castings.movie_id
  JOIN
    actors ON castings.actor_id = actors.id
  WHERE
    actors.name = 'Harrison Ford' AND castings.ord > 1
  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
  SELECT
    movies.title, name
  FROM
    actors
  JOIN
    castings ON castings.actor_id = actors.id
  JOIN
    movies ON castings.movie_id = movies.id AND movies.yr = 1962
  WHERE
    castings.ord = 1
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
  SELECT
    yr, COUNT(title)
  FROM
    movies
  JOIN
    castings ON movies.id = castings.movie_id
  JOIN
    actors ON actors.id = castings.actor_id AND actors.name = 'John Travolta'
  GROUP BY
    yr
  HAVING
    COUNT(title) > 1
  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
  SELECT
    title, actors.name
  FROM
    (
      SELECT
        title, movies.id AS j_id
      FROM
        castings
      JOIN
        actors ON castings.actor_id = actors.id
      JOIN
        movies ON castings.movie_id = movies.id
      WHERE
        actors.name = 'Julie Andrews'
    ) AS julie_movies
  JOIN
    castings ON castings.movie_id = julie_movies.j_id
  JOIN
    actors ON actors.id = castings.actor_id
  WHERE
    castings.ord = 1
  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
  SELECT
    star_actors.names
  FROM
    (
      SELECT
        actors.name AS names
      FROM
        actors
      JOIN
        castings ON castings.actor_id = actors.id
      JOIN
        movies ON castings.movie_id = movies.id
      WHERE
        castings.ord = 1
    ) AS star_actors
  -- JOIN
  --   castings ON castings.movie_id = star_movies.star_id
  -- JOIN
  --   actors ON castings.actor_id = actors.id
  GROUP BY
    star_actors.names
  HAVING
    COUNT(star_actors.names) >= 15
  ORDER BY
    star_actors.names
  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
  SELECT
    title, COUNT(actors.name)
  FROM
    (
      SELECT
        title, yr, id
      FROM
        movies
      WHERE
        yr = 1978
    ) AS seventies_movies
  JOIN
    castings ON castings.movie_id = seventies_movies.id
  JOIN
    actors ON castings.actor_id = actors.id
  GROUP BY
    title
  ORDER BY
    COUNT(actors.name) DESC, title
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
  SELECT
    actors.name
  FROM
    (
      SELECT
        movies.id as m_id
      FROM
        movies
      JOIN
        castings ON castings.movie_id = movies.id
      JOIN
        actors ON castings.actor_id = actors.id
      WHERE
        actors.name = 'Art Garfunkel'
    ) AS garfunkel_movies
  JOIN
    castings ON castings.movie_id = garfunkel_movies.m_id
  JOIN
    actors ON castings.actor_id = actors.id
  WHERE
    actors.name != 'Art Garfunkel'
  SQL
end
