class NotificationMarkButtonComponent < ApplicationComponent
  def initialize(notification, selected_filter, page = nil, show_more = nil)
    super

    @notification = notification
    @selected_filter = selected_filter
    @page = page
    @show_more = show_more
  end

  private

  def title
    @notification.unread? ? 'Mark as "Read"' : 'Mark as "Unread"'
  end

  def icon
    @notification.unread? ? 'fa-check' : 'fa-undo'
  end

  def update_path
    my_notifications_path(notification_ids: [@notification.id], kind: @selected_filter[:kind],
                          state: @selected_filter[:state],
                          button: @notification.unread? ? 'read' : 'unread',
                          project: @selected_filter[:project], group: @selected_filter[:group],
                          page: @page, show_more: @show_more)
  end
end
