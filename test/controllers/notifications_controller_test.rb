# frozen_string_literal: true
require 'test_helper'

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    stub_notifications_request
    @user = users(:andrew)
  end

  test 'will render the home page if not authenticated' do
    get '/'
    assert_response :success
    assert_template 'pages/home'
  end

  test 'renders the index page if authenticated' do
    sign_in_as(@user)

    get '/'
    assert_response :success
    assert_template 'notifications/index'
  end

  test 'renders the starred page' do
    sign_in_as(@user)

    get '/?starred=true'
    assert_response :success
    assert_template 'notifications/index'
  end

  test 'renders the archive page' do
    sign_in_as(@user)

    get '/?archive=true'
    assert_response :success
    assert_template 'notifications/index'
  end

  test 'shows only 20 notifications per page' do
    sign_in_as(@user)
    25.times.each { create(:notification, user: @user, archived: false) }

    get '/'
    assert_equal assigns(:notifications).length, 20
  end

  test 'toggles starred on a notification' do
    notification = create(:notification, user: @user, starred: false)

    sign_in_as(@user)

    get "/notifications/#{notification.id}/star"
    assert_response :ok

    assert notification.reload.starred?
  end

  test 'syncs users notifications' do
    sign_in_as(@user)

    post "/notifications/sync"
    assert_response :redirect
  end
end
