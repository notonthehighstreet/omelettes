require 'spec_helper'

describe "the bulk backend" do
  before :each do
    Omelettes::Backend::Bulk::Table.process_limit = 3
    @bulk = Omelettes::Backend::Bulk.new
  end
  
  it "should persist an object without importing" do
    @user = User.new
    @user.id = 1
    
    User.should_not_receive(:import)
    @bulk.persist(User.new, { "first_name" => "Test" })
  end
  
  it "should persist the values when completing a table" do
    @user = User.new
    @user.id = 1
    
    @bulk.persist(@user, { "first_name" => "Test" })
    
    User.should_receive(:import).with(["first_name", "id"], [["Test", 1]])
    @bulk.complete(User)
  end
  
  it "should persist the values when the process limit is met" do
    @user_1 = User.new { |u| u.id = 1 }
    @user_2 = User.new { |u| u.id = 2 }
    @user_3 = User.new { |u| u.id = 3 }
    
    @bulk.persist(@user_1, { "first_name" => "Test 1" })
    @bulk.persist(@user_2, { "first_name" => "Test 2" })
    
    User.should_receive(:import).with(
      ["first_name", "id"],
      [["Test 1", 1], ["Test 2", 2], ["Test 3", 3]]
    )
    
    @bulk.persist(@user_3, { "first_name" => "Test 3" })
  end
  
  it "should import objects with different column sets separately" do
    @user_1 = User.new { |u| u.id = 1 }
    @user_2 = User.new { |u| u.id = 2 }
    
    @bulk.persist(@user_1, { "first_name" => "Test 1" })
    @bulk.persist(@user_2, { "last_name" => "Test 2" })
    
    User.should_receive(:import).with(["first_name", "id"], [["Test 1", 1]]).once
    User.should_receive(:import).with(["id", "last_name"], [[2, "Test 2"]]).once
    
    @bulk.complete(User)
  end
end
