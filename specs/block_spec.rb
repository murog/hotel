require 'pry'
require_relative 'spec_helper'
# Hotel::Block.new(begin_date, end_date, num_of_rooms, discount_rate)

describe "Block" do
  describe "initialize" do
    it "should return an instance of a block" do
      output = Hotel::Block.new(0.5, 3, [2017,10,22], [2017,10,24], 60)
      output.must_be_instance_of Hotel::Block
    end
    it "should have a date range, num of rooms and discount rate" do
      output = Hotel::Block.new(0.5, 3, [2017,10,22], [2017,10,24], 60)
      output.must_respond_to :check_in
      output.must_respond_to :check_out
      output.must_respond_to :num_of_rooms
      output.must_respond_to :discount_rate
      output.must_respond_to :rooms
    end
    it "should raise error if intitalized with more than 5 rooms" do
      proc {Hotel::Block.new(0.5, 6, [2017,10,22], [2017,10,24], 60)}.must_raise ArgumentError
    end
    it "should contain rooms in an array" do
      output = Hotel::Block.new(0.5, 3, [2017,10,22], [2017,10,24], 60)
      output.rooms.must_be_instance_of Array
      (output.rooms[0]).must_be_instance_of Hotel::Room

    end
    it "should contain reservations in an array" do
      output = Hotel::Block.new(0.5, 3, [2017,10,22], [2017,10,24], 60)
      output.reservations.must_be_instance_of Array
    end
    it "should contain reservations if there are any for block" do
      output = Hotel.find_block(75)
      output.reservations.must_be_instance_of Array
      output.reservations.length.must_equal 0
      output.add_reservations
      output.reservations[0].must_be_instance_of Hotel::Reservation

    end
    it "should only include rooms that are available for the given date range" do
      output = Hotel::Block.new(0.5, 3, [2017,10,3], [2017,10,5], 60)
      (output.rooms.include? Hotel::HOTEL_ROOMS[0]).must_equal false
    end
  end
end
