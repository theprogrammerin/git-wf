module GitAuthHelper

  def headers
    {
      content_type: :json,
      authorization: "token #{Rails.application.config.github.token}"
    }
  end
end
