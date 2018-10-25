require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before(:each)do
    assign(:users, [
        # build_stubbed - исключает создания объекта в базе
        FactoryBot.build_stubbed(:user, name: 'Alexey', balance: 5000),
        FactoryBot.build_stubbed(:user, name: 'Yana', balance: 1000)
    ])

    render
  end

  it 'renders player names' do
    expect(rendered).to match 'Alexey'
    expect(rendered).to match 'Yana'
  end

  it 'renders player balances' do
    expect(rendered).to match '5 000 ₽'
    expect(rendered).to match '1 000 ₽'
  end

  it 'renders player names in right order' do
    expect(rendered).to match /Alexey.*Yana/m
  end
end