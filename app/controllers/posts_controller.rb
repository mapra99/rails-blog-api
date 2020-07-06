# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.where(published: true)
    render json: @posts, status: :ok
  end

  def show
    @post = Post.find_by_id(params[:id])

    if @post
      render json: @post, status: :ok
    else
      render json: {error: "not found"}, status: 404
    end
  end
end
