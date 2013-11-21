class BuildNotifier
  include ::Github::BuildNotifier

  attr_reader :build_id, :status

  def initialize(build_id, status)
    @build_id = build_id.to_i
    @status   = status.to_s
  end

  def build
    if build_id?
      @build ||= ::Build.find_by id: build_id
    end
  end

  def project
    build && build.project
  end

  def notify
    if build
      create_github_commit_status
      delivery_email_notifications
    end
  end

  def delivery_email_notifications
    if subscribed_emails.any?
      ::BuildsMailer.status_email(build, subscribed_emails).deliver
    end
  end

  def subscribed_emails
    project.subscriptions
           .active
           .joins(:user)
           .select("users.email AS user_email")
           .map(&:user_email)
  end

  def description
    if build
      n  = build.number
      case status
      when 'started'
        "EvroneCI build ##{n} started"
      when 'passed'
        "EvroneCI build ##{n} successed"
      when 'failed'
        "EvroneCI build ##{n} failed"
      when 'errored'
        "EvroneCI build ##{n} broken"
      end
    end
  end

  private

    def build_id?
      build_id > 0
    end

    def identity_not_found
      raise RuntimeError, "identity on project ID=#{build.project_id} is not exists"
    end
end