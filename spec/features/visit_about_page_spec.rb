require 'spec_helper'

feature 'User wants to learn more about Layabout' do

  scenario 'User visits about page' do
    visit about_path
    page.should have_text "About"
    page.should have_text "film_snob"
  end

end
