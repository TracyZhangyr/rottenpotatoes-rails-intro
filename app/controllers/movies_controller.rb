class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    @all_ratings = Movie.all_ratings

    if not session[:ratings] or not session[:sort]
      @ratings_to_show = Hash[@all_ratings.map{|x| [x, "1"]}]
      if not session[:ratings]
        session[:ratings] = @ratings_to_show
      elsif not session[:sort]
        session[:sort] = nil
      end
      redirect_to movies_path(:sort => nil, :ratings => @ratings_to_show) and return
    end

    if not params[:ratings] or not params[:sort]
      if params[:ratings]
        ratings = params[:ratings]
      else 
        ratings = session[:ratings]
      end
      if params[:sort]
        sorting = params[:sort]
      else
        sorting = session[:sort]
      end
      redirect_to movies_path(:sort => sorting, :ratings => ratings) and return 
    end 

    @ratings_to_show = params[:ratings].nil? ? [] : params[:ratings].keys
    @ratings_hash = Hash[@ratings_to_show.map{|x| [x, "1"]}] 

    if params.has_key?(:sort)
      if params[:sort] == 'title'
        @title_header = 'hilite bg-warning'
        @movies = Movie.with_ratings(@ratings_to_show).order(:title)
      elsif params[:sort] == 'release_date'
        @release_date_header = 'hilite bg-warning'
        @movies = Movie.with_ratings(@ratings_to_show).order(:release_date)
      end
    end

    session[:ratings] = params[:ratings]
    session[:sort] = params[:sort]
  
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end