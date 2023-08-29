class CatalogService 

  def self.get_catalog

    movies = MovieService.get_movies_by_descending_creation
    seasons = SeasonService.get_seasons_desc_episodes_asc
    catalog = movies + seasons

  end
  
  def self.get_catalog_ordered

    movies = MovieService.get_movies_by_descending_creation
    seasons = SeasonService.get_seasons_desc_episodes_asc
    catalog = (movies + seasons).sort_by(&:created_at).reverse

  end

end