require 'securerandom'

class Project < ActiveRecord::Base

  include ::PublicUrl::Project

  belongs_to :user_repo, class_name: "::UserRepo", foreign_key: :user_repo_id
  belongs_to :company

  has_one :identity, through: :user_repo
  has_one :user, through: :user_repo

  has_many :builds, dependent: :destroy, class_name: "::Build" do
    def from_number(number)
      if number
        where("builds.number < ?", number)
      else
        self
      end
    end
  end

  has_many :subscriptions, dependent: :destroy, class_name: "::ProjectSubscription"
  has_many :cached_files, dependent: :destroy, inverse_of: :project

  validates :name, :http_url, :clone_url, :token, :deploy_key, :user_repo_id, presence: true
  validates :token, uniqueness: true
  validates :name, uniqueness: { scope: :company_id }

  before_validation :generate_token,      on: :create
  before_validation :generate_deploy_key, on: :create

  after_destroy :publish_destroyed
  after_create  :publish_created

  delegate :channel, to: :company, allow_nil: true

  class << self
    def deploy_key_name
      "Vexor CI (#{Rails.configuration.x.hostname.host})"
    end

    def find_by_token(token)
      find_by token: token
    end
  end

  def rebuild(branch = nil)
    branch ||= 'master'
    build = builds.where(branch: branch).finished.first
    build && build.rebuild
  end

  def build_head_commit
    if payload = payload_for_head_commit
      create_perform_build(payload).process
    end
  end

  def create_perform_build(payload)
    PerformBuild.new(
      payload.to_hash.merge("project_id" => self.id)
    )
  end

  def payload_for_head_commit
    identity.sc.commits(sc_model).last
  end

  def to_s
    name
  end

  def deploy_key_name
    self.class.deploy_key_name
  end

  def public_deploy_key
    SSHKey.new(self.deploy_key).ssh_public_key
  end

  def generate_deploy_key
    SSHKey.generate(type: "RSA", bits: 1024).tap do |key|
      self.deploy_key = key.private_key.strip
    end
  end

  def generate_token
    self.token = SecureRandom.uuid
  end

  def hook_url
    if identity
      "#{Rails.configuration.x.hostname}/callbacks/#{identity.provider}/#{token}"
    end
  end

  def public_deploy_key
    @public_deploy_key ||= SSHKey.new(deploy_key, comment: deploy_key_name).try(:ssh_public_key)
  end

  def last_builds
    builds.limit(10)
  end

  def subscribed_by?(user)
    !!subscriptions.where(user_id: user.id).pluck(:subscribe).first
  end

  def subscribe(user)
    subscription = find_or_build_subscription_for_user(user)
    subscription.update subscribe: true
  end

  def unsubscribe(user)
    subscription = find_or_build_subscription_for_user(user)
    subscription.update subscribe: false
  end

  def branches
    builds.group(:branch_label).reorder(:branch_label).pluck(:branch_label)
  end

  def new_build_from_payload(payload)
    return unless sc

    file = nil
    if f = Rails.application.config.x.force_build_configuration
      file = f
    else
      file = sc.files(sc_model).get(payload.sha, ".travis.yml")
    end

    attrs = {
      pull_request_id:  payload.pull_request_number,
      branch:           payload.branch,
      branch_label:     payload.branch_label,
      sha:              payload.sha,
      http_url:         payload.web_url,
      author:           payload.author,
      author_email:     payload.author_email,
      message:          payload.message,
      source:           file
    }

    builds.build(attrs)
  end

  def sc
    identity.try(:sc)
  end

  def sc_model
    if user_repo
      Vx::ServiceConnector::Model::Repo.new(user_repo.external_id, name)
    end
  end

  def build_payload(params)
    identity.sc.payload(sc_model, params)
  end

  def publish(event = nil)
    super(event, channel: channel)
  end

  def status_for_gitlab(sha)
    build = builds.find_by(sha: sha)
    status_map = {
      initialized: :pending,
      started:     :running,
      deploying:   :running,
      passed:      :success,
      failed:      :failed,
      errored:     :failed
    }.with_indifferent_access

    if build
      { status: status_map[build.status_name], location: build.public_url }
    end
  end

  private

    def find_or_build_subscription_for_user(user)
      subscription = subscriptions.find_by user_id: user.id
      subscription ||= subscriptions.build user: user
    end

    def publish_destroyed
      publish :destroyed
    end

    def publish_created
      publish :created
    end

end

# == Schema Information
#
# Table name: projects
#
#  name         :string(255)      not null
#  http_url     :string(255)      not null
#  clone_url    :string(255)      not null
#  description  :text
#  deploy_key   :text             not null
#  token        :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  company_id   :uuid             not null
#  id           :uuid             not null, primary key
#  user_repo_id :uuid             not null
#

