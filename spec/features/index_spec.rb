require_relative '../spec_helper'

describe '/' do
  it 'displays a friendly message' do
    visit '/'

    expect(page).to have_text 'Welcome to Stethoscope'
  end
end
