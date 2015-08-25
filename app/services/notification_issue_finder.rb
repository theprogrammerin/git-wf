class NotificationIssueFinder
  include GitAuthHelper

  def initialize(repo)
    @repo = repo
    self
  end

  def find_or_create(keyword)
    @keyword = keyword
    issue_number = nil
    hash_map_issues.each do |k, v|
      if v.include? get_title
        issue_number = k
      end
    end
    issue_number = create_issue if issue_number.nil?
    issue_number
  end

  def create_issue
    issue_data = {
      title: get_title,
      body: get_body
    }
    resp = RestClient.post issues_url, issue_data.to_json, headers
    data = JSON.parse(resp, symbolize_names: true)
    data[:number]
  end

  def hash_map_issues
    fetch_all_issues.inject({}) do |hash, row|
      hash[row[:number]] = row[:title]
      hash
    end
  end

  def fetch_all_issues
    response = RestClient.get issues_url, headers
    JSON.parse(response, symbolize_names: true)
  end

  private

  def get_title
    Rails.application.config.notifications[:title][@keyword]
  end

  def get_body
    Rails.application.config.notifications[:body][@keyword]
  end


  def issues_url
    "https://api.github.com/repos/#{@repo}/issues"
  end

end
