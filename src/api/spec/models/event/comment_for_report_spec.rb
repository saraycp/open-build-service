RSpec.describe Event::CommentForReport do
  describe 'event is created with proper receiver roles' do
    let(:moderator) { create(:moderator) }
    let!(:report) { create(:report) }

    before do
      login moderator
      create(:comment, user: moderator, body: 'Arqe you sure this is spam?', commentable: report)
    end

    it 'creates event when add a comment to report' do
      expect(Event::CommentForReport.count).to eq(1)
    end

    it  { expect(Event::CommentForReport.last.moderators).to contain_exactly(moderator) }
    it  { expect(Event::CommentForReport.last.reporters).to contain_exactly(report.reporter) }
    it  { expect(Event::CommentForReport.last.commenters).to contain_exactly(moderator) }
  end
end
