require 'test_helper'

class DonorsControllerTest < ActionController::TestCase
  setup do
    @donor = donors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:donors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create donor" do
    assert_difference('Donor.count') do
      post :create, donor: { accepted_terms: @donor.accepted_terms, accepted_terms_on: @donor.accepted_terms_on, address: @donor.address, city: @donor.city, name: @donor.name, phone_number: @donor.phone_number, state: @donor.state, type_donor: @donor.type_donor, zip: @donor.zip }
    end

    assert_redirected_to donor_path(assigns(:donor))
  end

  test "should show donor" do
    get :show, id: @donor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @donor
    assert_response :success
  end

  test "should update donor" do
    patch :update, id: @donor, donor: { accepted_terms: @donor.accepted_terms, accepted_terms_on: @donor.accepted_terms_on, address: @donor.address, city: @donor.city, name: @donor.name, phone_number: @donor.phone_number, state: @donor.state, type_donor: @donor.type_donor, zip: @donor.zip }
    assert_redirected_to donor_path(assigns(:donor))
  end

  test "should destroy donor" do
    assert_difference('Donor.count', -1) do
      delete :destroy, id: @donor
    end

    assert_redirected_to donors_path
  end
end
