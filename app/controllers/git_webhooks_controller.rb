class GitWebhooksController < ApplicationController

  def create
    if pull_request_event?
      pull_request_number = params[:git_webhook][:number]
      pr_analyzer = PullRequestAnalyzer.new(@repo, pull_request_number)
      pr_analyzer.analyze_and_comment
    elsif branch_create_event?
      branch = params[:ref]
      branch_analyzer = BranchNameAnalyzer.new(@repo, branch)
      branch.analyze_and_delete
    end
    render json: {
      status: true,
      params: params[:git_webhook],
      headers: request.headers["X-Github-Event"]
    }
  end

  private

  def pull_request_event?
    request.headers["X-Github-Event"] == "pull_request" &&
    ["opened", "reopened"].include?(params[:git_webhook][:action])
  end

  def branch_create_event?
    request.headers["X-Github-Event"] == "branch" && params[:ref_type] == "branch"
  end

end
