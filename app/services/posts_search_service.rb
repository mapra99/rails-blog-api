# frozen_string_literal: true

class PostsSearchService
  def self.search(current_posts, query)
    posts_ids = Rails.cache.fetch("posts_search/#{query}", expires_in: 1.hour) do
      current_posts.where("title like '%#{query}%'").pluck(:id)
    end

    current_posts.where(id: posts_ids)
  end
end
