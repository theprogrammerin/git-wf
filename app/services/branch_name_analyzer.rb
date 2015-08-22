class BranchNameAnalyzer
  include GitAuthHelper

  def initialize(repo, branch)
    @repo = repo
    @branch = branch
  end

  def analyze_and_delete
    delete! if !valid_name?
  end

  def delete!
    data = {
      state: "open"
    }
    RestClient.delete delete_url, headers
  end

  private

  def valid_name?
    is_hotfix = /hot[_\ ]{0,1}fix\/(\S*)/.match(@branch).present?
    is_bugfix = /bug[_\ ]{0,1}fix\/(\S*)/.match(@branch).present?
    is_feature = /feature\/(\S*)/.match(@branch).present?
    is_refactor = /refactor\/(\S*)/.match(@branch).present?

    is_hotfix || is_bugfix || is_feature || is_refactor
  end

  def delete_url
    "https://api.github.com/repos/#{@repo}/git/refs/heads/#{@branch}"
  end

  def get_user
    "@#{@pull_request_data[:user][:login]}"
  end
end
