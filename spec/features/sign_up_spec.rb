require 'spec_helper'

feature "User signs up on the homepage" do

	scenario "when opening the home page" do
		visit '/'
		expect(page).to have_button("Sign up!")
	end

	scenario "when subscription completed" do
		expect(lambda { sign_up('a@a.com', 'pass1', 'pass1', 'alice1', "alice1234")}).to change(User, :count).by 1
		expect(page).to have_content("Welcome, a@a.com")
	end

	scenario "with a password that doesnt match" do 
		expect(lambda { sign_up('a@a.com', 'pass', 'wrong', 'alice', "alice123") }).to change(User, :count).by(0)
		expect(page).to have_content("Password does not match the confirmation")    
  	end

  	scenario "with an email that is already registred" do 
		expect(lambda { sign_up('a@a1.com', 'pass', 'pass', 'alice', "alice123") }).to change(User, :count).by(1)
		expect(lambda { sign_up('a@a1.com', 'pass', 'pass', 'alice', "alice123")}).to change(User, :count).by(0)
		expect(page).to have_content("This email is already taken")
	end

  end

  feature "User signs in" do

  	before(:each) do
    User.create(:email => "test@test.com", 
                :password => 'test', 
                :password_confirmation => 'test',
                :name => "Michiel Stigter",
                :username => "screen123")
  	end

  	scenario "with correct credentials" do
	    visit '/session/new'
	    expect(page).not_to have_content("Welcome, test@test.com")
	    sign_in('test@test.com', 'test')
	    expect(page).to have_content("Welcome, test@test.com")
  	end
  end

feature 'User signs out' do

	before(:each) do
	User.create(:email => "test@test.com", 
	            :password => 'test', 
	            :password_confirmation => 'test')
	end

	scenario 'while being signed in' do
	    sign_in('test@test.com', 'test')
	    click_button "Sign out"
	    expect(page).to have_content("Good bye!") # where does this message go?
	    expect(page).not_to have_content("Welcome, test@test.com")
	end

end

feature 'User requests password reset' do
	before(:each) do
    User.create(:username => "Testname",
    						:email => "test@test.com", 
                :password => 'test', 
                :password_confirmation => 'test')
  end

  scenario 'when requesting reset' do
  	visit '/session/new'
  	fill_in 'forgot_email', :with => "test@test.com"
  	expect(Messaging).to receive(:send_email).with(User.first)
  	click_button "Reset"
  	expect(page).to have_content("Password reset email sent")

  	token = User.first.password_token
  	visit "/users/reset_password/#{token}"
  	fill_in 'password', :with => "dog"
  	fill_in 'password_confirmation', :with => "dog"
  	click_button "Confirm"
  	expect(User.first.password_token).to be nil
  end
  end





	

	def sign_up(email = "alice@example.com", password = "fish", password_confirmation = "fish", name = "alice", username = "alice123")
		visit '/users/new'
		expect(page.status_code).to eq 200
		expect(page.status_code).to eq 200
		fill_in :email, :with => email
		fill_in :password, :with => password
		fill_in :password_confirmation, :with => password_confirmation
		fill_in :name, :with => name
		fill_in :username, :with => username
		click_button "Sign Up!"
	end

	def sign_in(email, password)
	    visit '/session/new'
	    fill_in 'email', :with => email
	    fill_in 'password', :with => password
	    click_button 'Sign in'
  	end



