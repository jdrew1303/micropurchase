class UpdateUser < Struct.new(:params, :current_user)
  attr_reader :status

  def save
    update_user
    update_auctions
    update_sam
    user.save
  end

  def errors
    user.errors.full_messages.to_sentence
  end

  def user
    @_user ||= current_user
  end

  private

  def update_user
    user.assign_attributes(user_params)
  end

  def update_sam
    reckoner = SamAccountReckoner.new(user)
    reckoner.set_default_sam_status
    reckoner.delay.set!
  end

  def update_auctions
    if added_payment_information?
      AuctionQuery.new.accepted_pending_payment_url_with_bid_from_user(user.id).each do |auction|
        if user_payment_info_needed_for?(auction)
          accept(auction)
        end
      end
    end
  end

  def added_payment_information?
    user.payment_url_changed? &&
      user.payment_url_was == '' &&
      user.valid?
  end

  def user_payment_info_needed_for?(auction)
    auction.accepted_pending_payment_url? && winning_bidder_for(auction) == user
  end

  def winning_bidder_for(auction)
    WinningBid.new(auction).find.bidder
  end

  def accept(auction)
    AcceptAuction.new(
      auction: auction,
      payment_url: user.payment_url
    ).perform
    auction.save
  end

  def user_params
    params
      .require(:user)
      .permit(:name, :duns_number, :email, :payment_url)
  end
end
