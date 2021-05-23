require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with valid email/invalid password" do
    get login_path #visit login path
    assert_template 'sessions/new' #verify new sessions rendered properly
    post login_path, params: { session: { email: @user.email, password: "" } } #with invalid hash
    assert_not is_logged_in?
    assert_template 'sessions/new' #verify form gets re-rendered
    assert_not flash.empty? #and the flash message is not empty
    get root_path #visit another page
    assert flash.empty? #verify that the flash message doesn't appear on new page
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email,
    password: 'password'
    } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0 #expects zero links matching the given pattern
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
