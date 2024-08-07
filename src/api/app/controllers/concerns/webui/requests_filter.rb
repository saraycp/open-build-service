module Webui::RequestsFilter
  extend ActiveSupport::Concern

  TEXT_SEARCH_MAX_RESULTS = 10_000

  def filter_by_text(text)
    return BsRequest.all if text.blank?

    if BsRequest.search_count(text) > TEXT_SEARCH_MAX_RESULTS
      flash[:error] = 'Your text search pattern matches too many results. Please, try again with a more restrictive search pattern.'
      return BsRequest.none
    end

    BsRequest.where(id: BsRequest.search_for_ids(text, per_page: TEXT_SEARCH_MAX_RESULTS))
  end

  def filter_by_involvement(requests, filter_involvement)
    case filter_involvement
    when 'all'
      requests.where(id: User.session.requests)
    when 'incoming'
      requests.where(id: User.session.incoming_requests)
    when 'outgoing'
      requests.where(id: User.session.outgoing_requests)
    end
  end
end
