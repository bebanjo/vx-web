class BuildSerializer < ActiveModel::Serializer
  include GavatarHelper

  attributes :id, :project_id, :number, :status, :started_at, :finished_at,
             :sha, :branch, :author, :author_email, :message, :http_url,
             :author_avatar, :short_message, :finished, :created_at

  def status
    object.status_name
  end

  def branch
    object.branch_label || object.branch
  end

  def author_avatar
    gavatar_url(author_email, size: 38)
  end

  def short_message
    message.lines.first
  end

  def finished
    object.finished?
  end
end
