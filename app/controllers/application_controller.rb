class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  before_filter :check_listners, except: [:status]
  before_filter :set_repo, except: [:status]

  def status
    render json: {
      status: "ok"
    }
  end

  private

  def check_listners
    event_supported = request.headers["X-Github-Event"].present? &&
      Rails.application.config.github.events.include?(request.headers["X-Github-Event"])

    repo_supported = params[:repository].present? &&
      params[:repository][:name].present? &&
      Rails.application.config.github.repos.include?(params[:repository][:name])

    user_supported = params[:repository].present? &&
      params[:repository][:owner].present? &&
      params[:repository][:owner][:login].present? &&
      Rails.application.config.github.username.include?(params[:repository][:owner][:login])

    if event_supported && user_supported && repo_supported
      return true
    else
      render json: {
        status: "not handled"
      }
      return false
    end
  end

  def set_repo
    @repo = params[:repository][:full_name]
  end

end
