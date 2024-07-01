# Methods to fetch information from a Github webhook payload
class WorkflowRunGiteaPayload
  extend ActiveSupport::Concern

  private

  def gitea_commit_sha
    return payload.dig(:pull_request, :head, :sha) if gitea_pull_request?
    return payload[:after] if gitea_push_event?

    payload.dig(:head_commit, :id) if gitea_tag_push_event?
  end

  def gitea_source_repository_full_name
    return payload.dig(:pull_request, :head, :repo, :full_name) if gitea_pull_request?

    payload.dig(:repository, :full_name) if gitea_push_event? || gitea_tag_push_event?
  end

  def gitea_target_repository_full_name
    return payload.dig(:pull_request, :base, :repo, :full_name) if gitea_pull_request?

    payload.dig(:repository, :full_name) if gitea_push_event? || gitea_tag_push_event?
  end

  def gitea_target_branch
    return payload.dig(:pull_request, :base, :ref) if gitea_pull_request?
    return payload.fetch(:ref, '').sub('refs/heads/', '') if gitea_push_event?

    payload.dig(:head_commit, :id) if gitea_tag_push_event?
  end

  def gitea_api_endpoint
    repositoy_url = payload.dig(:repository, :clone_url)
    return unless repositoy_url

    url = URI.parse(repositoy_url)
    "#{url.scheme}://#{url.host}"
  end

  def gitea_push_event?
    scm_vendor == 'gitea' && payload[:event] == 'push' && payload.fetch(:ref, '').start_with?('refs/heads/')
  end

  def gitea_tag_push_event?
    scm_vendor == 'gitea' && payload[:event] == 'push' && payload.fetch(:ref, '').starts_with?('refs/tags/')
  end

  def gitea_pull_request?
    scm_vendor == 'gitea' && payload[:event] == 'pull_request'
  end
end
