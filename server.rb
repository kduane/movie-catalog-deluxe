require "sinatra"
require "pg"
require 'pry' if development? || test?
require 'sinatra/reloader' if development?

set :bind, '0.0.0.0'  # bind to all interfaces

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/actors' do
  db_connection do |conn|
    @actors = conn.exec_params(
      'SELECT name, id FROM actors ORDER BY name'
    ).to_a
  end
  binding.pry
  erb :actor_list
end

get '/actors/:id' do
  @actor_id = params[:id]
  db_connection do |conn|
    @actor_details = conn.exec_params(
      "SELECT actors.name, movies.title, cast_members.character, movies.synopsis, movies.id
      FROM actors
      JOIN cast_members
      ON actors.id = cast_members.actor_id
      JOIN movies
      ON cast_members.movie_id = movies.id
      WHERE actor_id = #{@actor_id} "
    ).to_a
  end
  binding.pry
  erb :actor_detail
end

get '/movies' do
  db_connection do |conn|
    @result = conn.exec_params(
      'SELECT movies.title, movies.year, movies.rating, genres.name, studios.name
      FROM movies
        JOIN genres
          ON movies.genre_id = genres.id
        JOIN studios
          ON movies.studio_id = studios.id
      ORDER BY name'
    ).to_a
  end
  erb :movie_list
#   binding.pry
end
