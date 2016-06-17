require 'test_helper'
require 'support/web_mocking'

class LinksForAvailableAdsTest < ActionDispatch::IntegrationTest
  include WebMocking

  before { @ad = FactoryGirl.create(:ad, status: 1, comments_enabled: true) }

  it 'shows message link in listings' do
    mocking_yahoo_woeid_info(@ad.woeid_code) do
      visit ads_woeid_path(id: @ad.woeid_code,
                           type: 'give',
                           status: 'available')

      assert page.has_content?('Envía un mensaje privado al anunciante')
    end
  end

  it 'shows message link in ads' do
    mocking_yahoo_woeid_info(@ad.woeid_code) do
      visit ad_path(@ad)

      assert page.has_content?('Envía un mensaje privado al anunciante')
    end
  end

  it 'shows comment form in ads' do
    mocking_yahoo_woeid_info(@ad.woeid_code) do
      visit ad_path(@ad)

      assert page.has_content?('accede para escribir un comentario')
    end
  end
end