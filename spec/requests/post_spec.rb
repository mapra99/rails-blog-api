# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'GET /posts' do
    before { get '/posts' }

    it 'should return OK' do
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
    end

    describe 'Search' do
      let!(:post1) { create(:post, title: 'Hola Mundo', published: true) }
      let!(:post2) { create(:post, title: 'Hola Rails', published: true) }
      let!(:post3) { create(:post, title: 'Curso Rails', published: true) }

      it 'should filter posts by title' do
        get '/posts?search=Hola'
        payload = JSON.parse(response.body)
        expect(payload.size).to eq(2)
        expect(payload.pluck('id').sort).to eq([post1, post2].pluck(:id).sort)
        expect(response).to have_http_status(200)
      end
    end

    describe 'with data in the DB' do
      let!(:posts) { create_list(:post, 100) }
      before { get '/posts' }

      it 'should return all the published posts' do
        payload = JSON.parse(response.body)
        published_posts = posts.select(&:published)
        expect(payload.size).to eq(published_posts.size)
        expect(response).to have_http_status(200)
      end

      it "shouldn't return any unpublished post" do
        payload = JSON.parse(response.body)
        unpublished_post_ids = posts.reject(&:published).pluck(:id)

        payload.pluck('id').each do |published_post_id|
          expect(unpublished_post_ids).not_to include(published_post_id)
        end

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /posts/{id}' do
    let!(:post) { create(:post, published: true) }

    it 'should return content of one post' do
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['id']).to eq(post.id)
      expect(payload['title']).to eq(post.title)
      expect(payload['content']).to eq(post.content)
      expect(payload['published']).to eq(post.published)
      expect(payload['author']['name']).to eq(post.user.name)
      expect(payload['author']['email']).to eq(post.user.email)
      expect(payload['author']['id']).to eq(post.user.id)
      expect(response).to have_http_status(200)
    end

    it 'should return 404 if the post doesnt exist' do
      get '/posts/0'
      payload = JSON.parse(response.body)
      expect(response).to have_http_status(404)
    end
  end
end
