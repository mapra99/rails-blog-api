module Secured
  def authenticate_user!
    token_regex = /^Bearer (\w+)$/
    headers = request.headers

    if headers['Authorization']&.match?(token_regex)
      token = headers['Authorization'].match(token_regex)[1]
      Current.user = User.find_by_auth_token(token)
      return if Current.user.present?
    end

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
