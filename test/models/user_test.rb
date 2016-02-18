require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                    password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = ""
  	assert_not @user.valid?
  end

  test "name shoould not be too long" do
  	@user.name = "a" *51
  	assert_not @user.valid?
  end

  test "email should not be too long" do
  	@user.email = "a" *245 + "@example.de"
  	assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
  	valid_addresses = %w[user@example.de USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
  	valid_addresses.each do |valid_address|
  		@user.email = valid_address
  		assert @user.valid?, "#{valid_address.inspect} should be valid"
  	end
  end

  test "email validation should reject invalid addresses" do
  	invalid_addresses = %w[user@example,de user_at_foo.com user.name@example. foo@bar_baz.com foo@bar+baz.org]
  	invalid_addresses.each do |invalid_address|
  		@user.email = invalid_address
  		assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
  	end
  end

  test "email addresses should be unique" do
  	duplicate_user = @user.dup
  	duplicate_user.email = @user.email.upcase
  	@user.save
  	assert_not duplicate_user.valid?
  end

  test "password should be present" do
  	@user.password = @user.password_confirmation = "" * 6
  	assert_not @user.valid?
  end

  test "password should have a minimum length" do
  	@user.password = @user.password_confirmation = "a" * 5
  	assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated micropost should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    hans = users(:hans)
    lana = users(:lana)
    assert_not hans.following?(lana)
    hans.follow(lana)
    assert hans.following?(lana)
    assert lana.followers.include?(hans)
    hans.unfollow(lana)
    assert_not hans.following?(lana)
  end

  test "feed should have the right posts" do
    hans = users(:hans)
    rebekka = users(:rebekka)
    lana = users(:lana)
    #posts from followed user
    #binding.pry
    hans.microposts.each do |post_following|
      assert lana.feed.include?(post_following)
    end
    #post from self
    hans.microposts.each do |post_self|
      assert hans.feed.include?(post_self)
    end
    #posts from unfollowed user
    rebekka.microposts.each do |post_unfollowed|
      assert_not hans.feed.include?(post_unfollowed)
    end
  end
end
