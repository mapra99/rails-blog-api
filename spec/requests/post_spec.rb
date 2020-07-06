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
    let!(:post) { create(:post) }

    it 'should return content of one post' do
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).to eq(post.id)
      expect(response).to have_http_status(200)
    end

    it 'should return 404 if the post doesnt exist' do
      get "/posts/0"
      payload = JSON.parse(response.body)
      expect(response).to have_http_status(404)
    end
  end

  describe 'POST /posts' do
    let!(:user) { create(:user) }

    it 'should create a post' do
      req_payload = {
        post: {
          title: Faker::Lorem.sentence,
          content: Faker::Lorem.paragraph,
          published: false,
          user_id: user.id
        }
      }

      post "/posts", params: req_payload
      resp_payload = JSON.parse(response.body)
      expect(resp_payload).not_to be_empty
      expect(resp_payload['id']).not_to be_nil
      expect(response).to have_http_status(:created)
    end

    it 'should return an error on invalid post' do
      req_payload = {
        post: {
          content: Faker::Lorem.paragraph,
          published: false,
          user_id: user.id
        }
      }

      post "/posts", params: req_payload
      resp_payload = JSON.parse(response.body)
      expect(resp_payload).not_to be_empty
      expect(resp_payload['error']).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /posts/{id}' do
    let!(:article) { create(:post) }

    it 'should edit a post' do
      new_post_attributes = {
        title: Faker::Lorem.sentence,
        content: Faker::Lorem.paragraph,
        published: false
      }

      req_payload = {
        post: new_post_attributes
      }

      put "/posts/#{article.id}", params: req_payload
      resp_payload = JSON.parse(response.body)
      expect(resp_payload).not_to be_empty
      expect(resp_payload['id']).to eq(article.id)
      expect(response).to have_http_status(200)
    end

    it 'should return an error on invalid post' do
      new_post_attributes = {
        title: nil,
        content: nil,
        published: false
      }

      req_payload = {
        post: new_post_attributes
      }

      put "/posts/#{article.id}", params: req_payload
      resp_payload = JSON.parse(response.body)
      expect(resp_payload).not_to be_empty
      expect(resp_payload['error']).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
