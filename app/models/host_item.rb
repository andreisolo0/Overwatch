class HostItem < ApplicationRecord
  belongs_to :host
  belongs_to :item
  after_initialize :init
  def init
    self.threshold_high  ||= ""
    self.threshold_warning ||= ""
    self.threshold_low ||= ""
    self.alert_name_high ||= ""
    self.alert_name_warning ||= ""
    self.alert_name_low ||= ""
  end
end
