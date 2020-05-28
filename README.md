# RubyGitIssue

Dependent on `octokit` gem which helps to call Github APIs.

Using this module `RubyGitIssue` we can create GitHub issues while rails throw an exception

It can tag, assign to members, assign to organization project, and also set the issue on board as well.

Things you may want to cover:

## Installation

  - Install via Rubygems

    `gem install ruby_git_issue`

   OR

  - Add to you Gemfile

    `gem 'ruby_git_issue'`

  - Access the library in Ruby
    `require 'ruby_git_issue'`

## Usage

   Before using the gem, we need to get the repository's *ADMIN* `token`. With this only we can have access to the features of the gem

   Repository Users can also create an issue with this gem but, usage will be limited to issue creation only

  To get the token goto [Developer Settings](https://github.com/settings/apps) >  [Personal Access token](https://github.com/settings/tokens) > Generate new token


        options = { token: "above_mentioned", repo: "on_which_repo_you_want_issu", organization: "organization", exception_data: e, request: request}
        client = RubyGitIssue.new(options)
        client.issue_options = { title: "Exception[#{Rails.env}]": e.message, labels: ["BUG", "Enhancement"], assignees: ['github_repo_username_1', 'github_repo_username_2'] }

#### Generate issue on repo
  `generate_issue` method will generate the issue for you on GitHub

  `client.generate_issue`

#### OR

#### Generate issue on (organization) project

  `generate_issue(git_column)` method will generate the issue for you and assign to a project board as well

   To get the `git_column` we need to follow below process

   `projects = client.get_org_projects`

   find the id of the project from above call

   There will be columns and cards on the project

   With project's id get project's columns

   `get_projects_columns(project_id)`

   find the id of the column from the above call and

   `client.generate_issue(git_column)`

### Setup middelware on exception_notification

 * Install gem '[exception_notification](https://github.com/smartinez87/exception_notification)'

 * Setup middelware

   * Add file to `lib/exception_notifier/github_notifier.rb`

            require 'action_dispatch'
            module ExceptionNotifier
              class GithubNotifier < BaseNotifier

                class MissingController
                  def method_missing(*args, &block)
                  end
                end

                def initialize(options)
                  @default_options = options
                end

                def call(exception, options={})
                  unless options[:env].nil?
                    request = ActionDispatch::Request.new(options[:env])
                    git_options = @default_options.merge!({exception_data: exception, request: request})
                    client = RubyGitIssue.new(git_options)
                    client.issue_options = { title: "#{@default_options[:prefix]}: #{exception.message}",
                                                labels: @default_options[:labels],
                                                assignees: @default_options[:assignees] }
                    client.generate_issue(@default_options[:column_id])
                  end
                end
              end
            end

    * Add middelware to envrionment file on rails project

            Rails.application.config.middleware.use ExceptionNotification::Rack,
            github: {
                prefix: 'Exception [Development]: ',
                repo: ENV['GIT_REPO'],
                token: ENV['GIT_TOKEN'],
                organization: ENV['GIT_ORG'],
                labels: ["BUG"],
                assignees: [ENV['GIT_ASSIGNEES']],
                column_id: ENV['GIT_COLUMN']
            }
