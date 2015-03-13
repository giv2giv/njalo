require 'test_helper'

class PaymentAccountsControllerTest < ActionController::TestCase
  setup do
    @payment_account = payment_accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payment_accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payment_account" do
    assert_difference('PaymentAccount.count') do
      post :create, payment_account: { user_id: @payment_account.user_id, external_account_id: @payment_account.external_account_id, processor: @payment_account.processor, requires_reauth: @payment_account.requires_reauth }
    end

    assert_redirected_to payment_account_path(assigns(:payment_account))
  end

  test "should show payment_account" do
    get :show, id: @payment_account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @payment_account
    assert_response :success
  end

  test "should update payment_account" do
    patch :update, id: @payment_account, payment_account: { user_id: @payment_account.user_id, external_account_id: @payment_account.external_account_id, processor: @payment_account.processor, requires_reauth: @payment_account.requires_reauth }
    assert_redirected_to payment_account_path(assigns(:payment_account))
  end

  test "should destroy payment_account" do
    assert_difference('PaymentAccount.count', -1) do
      delete :destroy, id: @payment_account
    end

    assert_redirected_to payment_accounts_path
  end
end
