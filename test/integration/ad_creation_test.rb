require 'test_helper'
require 'integration/concerns/authentication'
require 'support/web_mocking'

class AdCreationTest < ActionDispatch::IntegrationTest
  include WebMocking
  include Authentication

  before do
    @user = FactoryGirl.create(:user)
    login_as @user
  end

  it 'can have pictures of 5 megabytes or less' do
    with_file_of_size(5.megabytes) do |path|
      mocking_yahoo_woeid_info(@user.woeid) do
        submit_ad_form(path)

        page.assert_no_text('Imagen debe estar entre 0 Bytes y 5 MB')
      end
    end
  end

  it 'cannot have pictures bigger than 5 megabytes' do
    with_file_of_size(6.megabytes) do |path|
      mocking_yahoo_woeid_info(@user.woeid) do
        submit_ad_form(path)

        page.assert_text('Imagen debe estar entre 0 Bytes y 5 MB')
      end
    end
  end

  private

  def submit_ad_form(file_path)
    visit new_ad_path
    attach_file :image, file_path
    fill_in 'Título de tu anuncio:', with: 'File'
    fill_in 'Cuerpo del anuncio', with: 'My gift is a file full of equis'
    click_button 'Enviar'
  end

  def with_file_of_size(size)
    Tempfile.create('foo') do |f|
      (size / 2**20).times { f.write('x' * 2**20) }
      f.close

      yield(f.path)
    end
  end
end