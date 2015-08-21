class GitWebhooksController < ApplicationController

  def create
    if request.headers["X-Github-Event"] == "pull_request" && ["opened", "reopened"].include?(params[:git_webhook][:action])
      pull_request_number = params[:git_webhook][:number]
      pr_analyzer = PullRequestAnalyzer.new(pull_request_number)
      pr_analyzer.analyze_and_comment
    end
    render json: {
      status: true,
      params: params[:git_webhook],
      headers: request.headers["X-Github-Event"]
    }
  end
end
