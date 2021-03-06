class BranchNameAnalyzer
  include GitAuthHelper

  def initialize(repo, branch, owner)
    @repo = repo
    @branch = branch
    @owner = owner
  end

  def analyze_and_delete
    if !valid_name? and !ignored_branch?
      delete!
      notify_user
    end
  end

  def delete!
    data = {
      state: "open"
    }
    RestClient.delete delete_url, headers
  end

  def notify_user
    data = {
      body: "#{get_user} You missed out the naming convention, hence thy branch (#{@branch}) was deleted"
    }
    RestClient.post notification_url, data.to_json, headers
  end

  private

  def ignored_branch?
    ["develop", "master"].include? @branch
  end

  def valid_name?
    is_hotfix = /hot[_\ ]{0,1}fix\/(\S*)/.match(@branch).present?
    is_bugfix = /bug[_\ ]{0,1}fix\/(\S*)/.match(@branch).present?
    is_feature = /feature\/(\S*)/.match(@branch).present?
    is_refactor = /refactor\/(\S*)/.match(@branch).present?
    is_enhancement = /enhancement\/(\S*)/.match(@branch).present?

    is_hotfix || is_bugfix || is_feature || is_refactor || is_enhancement
  end

  def delete_url
    "https://api.github.com/repos/#{@repo}/git/refs/heads/#{@branch}"
  end

  def notification_url
    issue_number = NotificationIssueFinder.new(@repo).find_or_create(:wrong_branch_name)
    "https://api.github.com/repos/#{@repo}/issues/#{issue_number}/comments"
  end

  def get_user
    "@#{@owner}"
  end
end
