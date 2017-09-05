require_relative 'spec_helper'

describe "reservation" do
  describe "initialize" do
    it "should be an instance of reservation" do
      input = Hotel::Reservation.new(1, [2017,10,22], [2017,10,24])
      input.must_be_instance_of Hotel::Reservation
    end
    it "should have a room number, check_in date and check_out date" do
      input = Hotel::Reservation.new(1, [2017,10,22], [2017,10,24])
      input.must_respond_to :room_number
      input.must_respond_to :check_in
      input.must_respond_to :check_out
    end
    it "should have a unique ID" do
      reserve_1 = Hotel::Reservation.new(1, [2017,10,22], [2017,10,24])
      reserve_1.must_respond_to :id

      reserve_2 = Hotel::Reservation.new(1, [2017,10,22], [2017,10,24])
      reserve_2.must_respond_to :id
      (reserve_1.id).must_be :!=, reserve_2.id

    end
    it "should have an instance of a room" do
      input = Hotel::Reservation.new(1, [2017,10,22], [2017,10,24])
      input.must_respond_to :room
      (input.room).must_be_instance_of Hotel::Room
    end
    it "should have a total cost of 400 for a 2 day stay" do
      input = Hotel::Reservation.new(1, [2017,10,22], [2017,10,24])
      input.must_respond_to :total_cost
      (input.total_cost).must_equal 400
    end
  end
end
