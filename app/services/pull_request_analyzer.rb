class PullRequestAnalyzer

  def initialize(pull_request_number)
    @pull_request_number = pull_request_number
    @base_pull_url = "https://api.github.com/repos/theprogrammerin/git-wf/pulls/#{@pull_request_number}"

    @base_issue_url = "https://api.github.com/repos/theprogrammerin/git-wf/issues/#{@pull_request_number}"
  end

  def analyze_and_comment
    get_from_git
    close_pr = false
    base_comment = "#{get_user} I think you missed out to add "
    missed = []

    missed << "change log" if !change_log_present?
    missed << "flow affected" if !flow_affected_present?

    if missed.count == 0
      comment = "#{get_user} you can pass!"
    else
      comment = "#{base_comment}#{missed.to_sentence} and hence this PR shall not pass! Open it when you are prepared."
      close_pr = true
    end

    if is_pull_request_opened?
      add_comment(comment) if comment.present?
      close_pull_request if close_pr
    end

  end

  def get_from_git
    response = RestClient.get pull_request_url
    @pull_request_data = JSON.parse(response, symbolize_names: true)
  end

  def add_comment(comment)
    data = {
      body: comment
    }
    RestClient.post comments_url, data.to_json, headers
  end

  def open_pull_request
    data = {
      state: "open"
    }
    RestClient.patch pull_request_url, data.to_json, headers
  end

  def close_pull_request
    data = {
      state: "closed"
    }
    RestClient.patch pull_request_url, data.to_json, headers
  end

  private

  def change_log_present?
    pull_request_body.include?("changelog") ||
    pull_request_body.include?("change log") ||
    pull_request_body.include?("change_log")
  end

  def flow_affected_present?
    pull_request_body.include?("flow") &&
    pull_request_body.include?("affected")
  end

  def pull_request_body
    @pull_request_data[:body].downcase
  end

  def is_pull_request_opened?
    @pull_request_data[:state] == "open"
  end

  def get_user
    "@#{@pull_request_data[:user][:login]}"
  end

  def pull_request_url
    "#{@base_pull_url}"
  end

  def comments_url
    "#{@base_issue_url}/comments"
  end

  def headers
    {
      content_type: :json,
      authorization: "token #{Rails.application.config.github.token}"
    }
  end

end
