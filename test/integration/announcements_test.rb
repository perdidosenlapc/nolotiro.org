# frozen_string_literal: true
require 'test_helper'
require 'integration/concerns/authentication'

class AnnouncementsTest < ActionDispatch::IntegrationTest
  include Authentication

  before do
    @active_announcement = create(:announcement, message: 'Blocking released!',
                                                 starts_at: 1.hour.ago,
                                                 ends_at: 1.hour.from_now)
  end

  it 'displays no announcements for anonymous visitors' do
    visit root_path

    refute_content @active_announcement.message
  end

  it 'displays active announcements' do
    login_as create(:user, woeid: nil)
    visit root_path

    assert_content @active_announcement.message
  end

  it 'properly dismisses announcements' do
    login_as create(:user, woeid: nil)
    visit root_path
    click_link '×'

    refute_content @active_announcement.message
  end

  it 'displays a single announcement at a time' do
    @active_announcement2 = create(:announcement, message: 'Magic released',
                                                  starts_at: 1.hour.ago,
                                                  ends_at: 1.minute.from_now)
    login_as create(:user, woeid: nil)
    visit root_path
    assert_content @active_announcement2.message
    refute_content @active_announcement.message

    click_link '×'
    assert_content @active_announcement.message
    refute_content @active_announcement2.message
  end
end
