require 'rails_helper'

describe C2StatusPresenter::ApprovalNotRequested do
  describe '#status' do
    it 'returns the status for approval not requested' do
      auction = create(:auction)
      presenter = C2StatusPresenter::ApprovalNotRequested.new(auction: auction)

      expect(presenter.status)
        .to eq(I18n.t('statuses.c2_presenter.approval_not_requested.status'))
    end
  end

  describe '#body' do
    it 'returns the body for approval not requested' do
      auction = create(:auction)
      presenter = C2StatusPresenter::ApprovalNotRequested.new(auction: auction)

      expect(presenter.body)
        .to eq(I18n.t('statuses.c2_presenter.approval_not_requested.body',
                      link: presenter.link))
    end
  end

  describe '#header' do
    it 'returns the header for approval not requested' do
      auction = create(:auction)
      presenter = C2StatusPresenter::ApprovalNotRequested.new(auction: auction)

      expect(presenter.header)
        .to eq(I18n.t('statuses.c2_presenter.approval_not_requested.header'))
    end
  end
end
