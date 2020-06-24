class RubyGitIssue
  require 'json'
  require 'octokit'

  attr_accessor :token, :request, :exception_data, :organization, :repo, :issue_options, :project, :column_id
  
  # options[:token] ## String => Git hub developer token
  # options[:request] ## Hash => Rails controller request data
  # options[:exception_data] ## Hash => Rails Exception 
  # options[:organization] ## String => Github Organization
  # options[:repo] ## String => Github Repo
  # options[:issue_options] ## Hash => pass github issue options
  def initialize(options)
    self.token = options[:token]
    self.request = options[:request]
    self.exception_data = options[:exception_data]
    self.organization = options[:organization]
    self.repo = options[:repo]
    self.issue_options = options[:issue_options]
    self.project = nil
    self.column_id = nil 
  end

  # github client from octokit
  def client
     Octokit::Client.new(:access_token => "#{token}")
  end
  
  # Generate Github issue 
  # column_id ## Integer => Get column id from project and its columns
  # column_id can be blank as well. Issue will not be assigned to and project column if column_id is blank
  def generate_issue(column_id=nil)
    existing_issue = client.list_issues("#{organization}/#{repo}").select{|issue| issue[:title] == issue_options[:title]}.try(:first)
    if existing_issue.nil?
      issue_data = client.create_issue("#{organization}/#{repo}", issue_options[:title][0..255], compose_body(exception_data, request), issue_options)
      add_issue_to_project(issue_data, column_id) unless column_id.nil?
    else
      client.add_comment("#{organization}/#{repo}", existing_issue.number, compose_body(exception_data, request))
    end
  end

  # Get Github project based on the organization passed while initializing client
  def get_org_projects
    unless organization.nil?
      client.org_projects(organization)
    end
  end

  # project_id ## Integer => Get project columns based on the Github project_id
  def get_projects_columns(project_id)
    unless organization.nil?
     client.project_columns(project_id)
    end
  end

  # issue_data ## Stringyied Hash
  # column_id ## Integer
  # Method will assign issue to project column on the github project board
  def add_issue_to_project(issue_data, column_id)
    payload =   {
        content_type: "Issue",
        content_id: issue_data['id']
    }
    client.create_project_card(column_id, payload)
    # url = "#{BASE_URL}/projects/columns/#{column_id}/cards"
  end

  private


  def compose_backtrace_section(e)
    return '' if e.backtrace.empty?
    out = sub_title('Backtrace')
    out << "<pre>#{e.backtrace.join("\n")}</pre>\n"
  end

  def compose_body(e, request)
    out = sub_title('Error')
    body = compose_header(e) unless e.nil?
    body << compose_request_section(e, request) unless request.nil?
    body << "\n\n"
    body << compose_backtrace_section(e) unless e.nil?
  end

  def compose_data_section(e,data )
    return '' if data.empty?
    out = sub_title('Data')
    out << "`#{PP.pp(data, '')}`\n"
  end

  def compose_header(e)
    header = e.class.to_s =~ /^[aeiou]/i ? 'An' : 'A'
    header << format(" %s occurred in %s#%s:\n\n",
                     e.class.to_s,
                     e.message, "", "")
  end

  def compose_request_section(e, request)
    return '' if request.nil?
    out = sub_title('Request')
    out << "* URL        : `#{request.url}`\n"
    out << "* HTTP Method: `#{request.method}`\n"
    out << "* IP address : `#{request.ip}`\n"
    out << "* Parameters : `#{request.parameters.inspect}`\n"
    out << "* Timestamp : `#{Time.now}`\n"
    out << "* Headers Authorization: `#{request.headers["Authorization"]}`\n"
    out << "* Headers Content-type: `#{request.headers["Content-Type"]}`\n"
    if defined?(Rails) && Rails.respond_to?(:root)
      out << "* Rails root : `#{Rails.root}`"
    end
  end

  def compose_title(e, prefix = '[Error]')
    subject = "#{prefix} "
    subject << "#{e.message}"
  end

  def sub_title(text)
    "## #{text}:\n\n"
  end
  
end