require_relative 'hotel'
require_relative 'room'

module Hotel
  class Reservation
    # @@reservation_id_max = 0
    attr_reader :id, :room_number, :room, :check_in, :check_out, :total_cost
    def initialize(input_id, input_room_number, check_in_date, check_out_date)
      @id = input_id

      @room_number = input_room_number.to_i

      @room = Hotel.find_room(@room_number)

      @check_in = Date.new(check_in_date[0].to_i, check_in_date[1].to_i, check_in_date[2].to_i)

      @check_out = Date.new(check_out_date[0].to_i, check_out_date[1].to_i, check_out_date[2].to_i)

      @total_cost = cost
    end

    def cost
      length_of_stay = (@check_out - @check_in).to_i
      cost_of_stay = length_of_stay * @room.cost
      return cost_of_stay
    end
    # def generate_id
    #   @@reservation_id_max += 1
    #   return @@reservation_id_max
    # end
  end
end
