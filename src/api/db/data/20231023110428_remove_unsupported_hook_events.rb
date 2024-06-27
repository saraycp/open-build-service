# frozen_string_literal: true

class RemoveUnsupportedHookEvents < ActiveRecord::Migration[7.0]
  def up
    allowed_events = [*WorkflowRun::ALLOWED_GITHUB_EVENTS, *WorkflowRun::ALLOWED_GITLAB_EVENTS, *WorkflowRun::ALLOWED_GITEA_EVENTS].uniq
    WorkflowRun.where.not(hook_event: allowed_events).destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
