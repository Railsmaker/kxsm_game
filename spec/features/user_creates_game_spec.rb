require 'rails_helper'

RSpec.feature 'USER creates game', type: :feature do
  let(:user){FactoryBot.create :user}

  let!(:questions) do
    (0..14).to_a.map do |i|
      FactoryBot.create(
         :question, level: i,
         text: "Когда была куликовская битва год #{i}?",
         answer1: '1380', answer2: '1381', answer3: '1382', answer4: '1383'
      )
    end
  end

  # visit - 'посетить URL'
  # click_on - 'кликнуть на ссылку'
  # fill_in, with - 'заполнить поля форм данными'
  # expect(page).to - 'проверить результат какая страница вернулась'
  # save_and_open_page - 'создаст визуализацию одной страницы'
  # =============================================================================
  # Для авторизации пользователей, прописать строку в файле: spec/rails_helper.rb
  # config.include Warden::Test::Helpers, type: :feature

  before(:each) do
    login_as user
  end

  scenario 'success' do
    # посетить главную страницу
    visit '/'
    # нажать на кнопку с надписью новая игра
    click_link 'Новая игра'

    expect(page).to have_content('Когда была куликовская битва год 0?')
    expect(page).to have_content('1380')
    expect(page).to have_content('1381')
    expect(page).to have_content('1382')
    expect(page).to have_content('1383')

    save_and_open_page
  end
end