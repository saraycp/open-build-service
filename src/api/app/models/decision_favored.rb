class DecisionFavored < Decision
  after_create :create_event

  def description
    'The moderator decided to favor the report'
  end

  private

  def create_event
    Event::FavoredDecision.create(event_parameters)
  end
end

# == Schema Information
#
# Table name: decisions
#
#  id           :bigint           not null, primary key
#  kind         :integer          default("cleared")
#  reason       :text(65535)      not null
#  type         :string(255)      not null, default("DecisionCleared")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  moderator_id :integer          not null, indexed
#
# Indexes
#
#  index_decisions_on_moderator_id  (moderator_id)
#
# Foreign Keys
#
#  fk_rails_...  (moderator_id => users.id)
#
