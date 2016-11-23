class AdminAuctionStatusPresenterFactory
  attr_reader :auction

  def initialize(auction:)
    @auction = auction
  end

  def create
    presenter_class.new(auction: auction)
  end

  private

  def presenter_class
    if auction.purchase_card == 'default'
      default_purchase_card_presenter
    else
      other_purchase_card_presenter
    end
  end

  def default_purchase_card_presenter
    ordered_default_pcard_presenter_classes.detect do |presenter_class|
      presenter_class.relevant?(BidStatusInformation.new(auction))
    end || C2StatusPresenter::PaymentConfirmed
  end

  def ordered_default_pcard_presenter_classes
    [
      AdminAuctionStatusPresenter::Archived,
      AdminAuctionStatusPresenter::NoBids,
      C2StatusPresenter::NotRequested,
      C2StatusPresenter::Sent,
      C2StatusPresenter::PendingApproval,
      AdminAuctionStatusPresenter::Future,
      AdminAuctionStatusPresenter::ReadyToPublish,
      AdminAuctionStatusPresenter::Available,
      AdminAuctionStatusPresenter::WorkNotStarted,
      AdminAuctionStatusPresenter::OverdueDelivery,
      AdminAuctionStatusPresenter::WorkInProgress,
      AdminAuctionStatusPresenter::MissedDelivery,
      AdminAuctionStatusPresenter::PendingAcceptance,
      AdminAuctionStatusPresenter::AcceptedPendingPaymentUrl,
      AdminAuctionStatusPresenter::DefaultPcard::Accepted,
      AdminAuctionStatusPresenter::Rejected,
      C2StatusPresenter::C2Paid
    ]
  end

  def other_purchase_card_presenter
    if auction.archived?
      puts 1
      AdminAuctionStatusPresenter::Archived
    elsif future? && auction.published?
      puts 2
      AdminAuctionStatusPresenter::Future
    elsif auction.unpublished?
      puts 3
      AdminAuctionStatusPresenter::ReadyToPublish
    elsif available?
      puts 4
      AdminAuctionStatusPresenter::Available
    elsif overdue_delivery?
      puts 5
      AdminAuctionStatusPresenter::OverdueDelivery
    elsif auction.work_in_progress?
      puts 6
      AdminAuctionStatusPresenter::WorkInProgress
    elsif auction.missed_delivery?
      puts 7
      AdminAuctionStatusPresenter::MissedDelivery
    elsif auction.pending_acceptance?
      puts 8
      AdminAuctionStatusPresenter::PendingAcceptance
    elsif auction.accepted_pending_payment_url?
      puts 9
      AdminAuctionStatusPresenter::AcceptedPendingPaymentUrl
    elsif auction.accepted? && auction.paid_at.nil?
      puts 10
      AdminAuctionStatusPresenter::OtherPcard::Accepted
    elsif auction.accepted? && auction.paid_at.present?
      puts 11
      AdminAuctionStatusPresenter::OtherPcard::Paid
    else # auction.rejected?
      puts 12
      AdminAuctionStatusPresenter::Rejected
    end
  end

  def ordered_other_pcard_classes
    [
      AdminAuctionStatusPresenter::Archived,
      AdminAuctionStatusPresenter::Future,
      AdminAuctionStatusPresenter::ReadyToPublish,
      AdminAuctionStatusPresenter::Available,
      AdminAuctionStatusPresenter::OverdueDelivery,
      AdminAuctionStatusPresenter::WorkInProgress,
      AdminAuctionStatusPresenter::MissedDelivery,
      AdminAuctionStatusPresenter::PendingAcceptance,
      AdminAuctionStatusPresenter::AcceptedPendingPaymentUrl
    ]

    AdminAuctionStatusPresenter::OtherPcard::Accepted
    AdminAuctionStatusPresenter::OtherPcard::Paid
    AdminAuctionStatusPresenter::Rejected
  end

  class BidStatusInformation
    attr_reader :auction, :bid_status

    def initialize(auction)
      @auction = auction
      @bid_status = BiddingStatus.new(auction)
    end

    delegate :archived?, :published?, :unpublished?, :pending_delivery?, :work_in_progress?,
      :pending_acceptance?, :accepted_pending_payment_url?, :missed_delivery?, :accepted?,
      :c2_paid?, :payment_confirmed?, :rejected?,
        to: :auction

    def available?
      bid_status.available?
    end

    def over_and_no_bids?
      over? && !bids?
    end

    def c2_not_requested?
      auction.c2_status == 'not_requested'
    end

    def c2_sent?
      auction.c2_status == 'sent'
    end

    def c2_pending?
      auction.c2_status == 'pending_approval'
    end

    def won?
      over? && bids?
    end

    def over?
      bid_status.over?
    end

    def bids?
      auction.bids.any?
    end

    def future?
      bid_status.future?
    end

    def pending_delivery?
      auction.pending_delivery?
    end

    def overdue_delivery?
      won? &&
        (auction.pending_delivery? || auction.work_in_progress?) &&
        auction.delivery_due_at < Time.now
    end

    def delivery_status
      auction.delivery_status.camelize
    end

    def c2_status
      auction.c2_status.camelize
    end

    def paid_at_info?
      !paid_at.nil?
    end
  end

  def available?
    bidding_status.available?
  end

  def over_and_no_bids?
    over? && !bids?
  end

  def won?
    over? && bids?
  end

  def over?
    bidding_status.over?
  end

  def bids?
    auction.bids.any?
  end

  def future?
    bidding_status.future?
  end

  def overdue_delivery?
    won? &&
      (auction.pending_delivery? || auction.work_in_progress?) &&
      auction.delivery_due_at < Time.now
  end

  def bidding_status
    @_bidding_status ||= BiddingStatus.new(auction)
  end

  def delivery_status
    auction.delivery_status.camelize
  end

  def c2_status
    auction.c2_status.camelize
  end
end
