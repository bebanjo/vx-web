class PerformBuild

  attr_reader :payload, :project_id

  def initialize(params)
    @payload    = Vx::ServiceConnector::Model::Payload.from_hash(params)
    @project_id = params["project_id"]
  end

  def project
    @project ||= ::Project.lock(true).find_by(id: project_id)
  end

  def build
    @build ||= project.new_build_from_payload(payload)
    @build
  end

  def process
    transaction do
      guard do
        (
          build                               &&
          build.save                          &&
          build.create_regular_jobs           &&
          build.create_deploy_jobs            &&
          build.jobs.any?                     &&
          build.publish_perform_job_messages  &&
          build.subscribe_author
        ).or_rollback_transaction
        build
      end
    end
  end

  private

    def guard
      if project && !payload.ignore?
        yield
      end
    end

    def transaction
      Build.transaction { yield }
    end

end
