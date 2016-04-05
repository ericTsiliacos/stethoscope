describe '/' do
  it 'displays a friendly message' do
    Capybara.page.visit '/'

    expect(Capybara.page).to have_text 'Welcome to Stethoscope'
  end
end
