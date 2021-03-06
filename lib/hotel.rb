require 'csv'
require_relative 'room'
require_relative 'reservation'

module Hotel

  ROOM_NUMBERS = (1..20)

  HOTEL_ROOMS = ROOM_NUMBERS.map {|num| Hotel::Room.new(num, 200)}


  def self.all_rooms
    return HOTEL_ROOMS
  end

  def self.find_room(input_id)
    HOTEL_ROOMS.each do |room|
      return room if room.id == input_id
    end
  end


  def self.find_reservation(input_id)
    raise ArgumentError.new "Invalid input.  Please enter Reservation ID as an Integer" if !(input_id.is_a? Integer)
    all_reservations = self.all_reservations
    all_reservations.each do |reservation|
      return reservation if reservation.id == input_id
    end
    raise ArgumentError.new "Reservation ID does not exist"
  end

  def self.find_reservation_by_block_id(input_id)
    raise ArgumentError.new "Invalid input.  Please enter Block ID as an Integer" if !(input_id.is_a? Integer)
    blocked_reservations = []
    all_reservations = self.all_reservations
    all_reservations.each do |reservation|
      blocked_reservations << reservation if reservation.block_id == input_id
    end
    raise ArgumentError.new "No Reservations found under that Block ID" if blocked_reservations.length == 0
    return blocked_reservations
  end

  def self.find_block(input_id)
    all_blocks = self.all_blocks
    all_blocks.each do |block|
      return block if block.block_id == input_id
    end
  end

  def self.all_reservations
    all_reservations = []
    CSV.read('support/reservations.csv').each do |row|
      reservation_id = row[0]
      room_num = row[1]
      check_in_date = row[2].split
      check_out_date = row[3].split
      block_id = row[4] ? row[4] : 0
      all_reservations.push(Hotel::Reservation.new(reservation_id, room_num, check_in_date, check_out_date, block_id))
    end
    return all_reservations
  end

  def self.all_blocks
    all_blocks =[]
    CSV.read('support/blocks.csv').each do |row|
      block_rate = row[0]
      num_of_rooms = row[1]
      check_in_date = row[2].split
      check_out_date = row[3].split
      block_id = row[4]
      all_blocks.push(Hotel::Block.new(block_rate, num_of_rooms, check_in_date, check_out_date, block_id))
    end
    return all_blocks
  end

  def self.cost(input_reservation_id)
    raise ArgumentError.new "Invalid reservation ID.  Must be Integer." if !(input_reservation_id.is_a? Integer)
    all_reservations = self.all_reservations
    all_reservations.each do |reservation|
      return (reservation.total_cost) if reservation.id == input_reservation_id
    end
    raise ArgumentError.new "Reservation ID does not exist"
  end

  def self.access_reservation(input_date)
    search_date = Date.new(input_date[0], input_date[1], input_date[2])
    search_reservations = []
    all_reservations = self.all_reservations
    all_reservations.each do |reservation|
      search_reservations << reservation if search_date.between?(reservation.check_in, reservation.check_out - 1)
    end
    raise ArgumentError.new "No Reservations are present on that date" if search_reservations.length == 0
    return search_reservations
  end

  def self.available_rooms(begin_date, end_date)
    begin_search = Date.new(begin_date[0].to_i, begin_date[1].to_i, begin_date[2].to_i)
    end_search = Date.new(end_date[0].to_i, end_date[1].to_i, end_date[2].to_i)
    unavailable_rooms = []
    all_reservations = self.all_reservations
    all_reservations.each do |reservation|
      if reservation.available(begin_search, end_search) == false
        unavailable_rooms << reservation.room
      end
    end
      # if (begin_search >= reservation.check_in) && (begin_search < reservation.check_out) && (end_search >= reservation.check_in) && (end_search <= reservation.check_out)
      #   unavailable_rooms<< reservation.room
      # end
    available_rooms = HOTEL_ROOMS - unavailable_rooms
    return available_rooms
  end

  def self.blocked_rooms(begin_date, end_date)
    begin_search = Date.new(begin_date[0].to_i, begin_date[1].to_i, begin_date[2].to_i)
    end_search = Date.new(end_date[0].to_i, end_date[1].to_i, end_date[2].to_i)
    blocked_rooms = []
    all_the_blocks = self.all_blocks
    all_the_blocks.each do |block|
      # if (begin_search >= block.check_in) && (begin_search < block.check_out) && (end_search >= block.check_in) && (end_search <= block.check_out)
      if block.available(begin_search, end_search) == false
        block.rooms.each do |room|
          blocked_rooms << room
        end
      end
    end
    return blocked_rooms
  end

  def self.truly_available(begin_date, end_date)
    available_rooms = self.available_rooms(begin_date, end_date)
    blocked_rooms = self.blocked_rooms(begin_date, end_date)
    truly_available = available_rooms - blocked_rooms
    return truly_available
  end


  def self.reserve_room(begin_date, end_date)
    # begin_reservation = Date.new(begin_date[0], begin_date[1], begin_date[2])
    # end_reservation = Date.new(end_date[0], end_date[1], end_date[2])
    available_rooms = self.available_rooms(begin_date, end_date)
    raise ArgumentError.new "No rooms are available for this date range" if available_rooms.length == 0
    return Hotel::Reservation.new(10, available_rooms[0].id, begin_date, end_date)
  end

  def self.reserve_block(rate, num_of_rooms, check_in_date, check_out_date, input_block_id)
    available_rooms = truly_available(check_in_date, check_out_date)
    raise ArgumentError.new "Not enough rooms are available for this date range" if available_rooms.length < num_of_rooms.to_i
    return Hotel::Block.new(rate, num_of_rooms, check_in_date, check_out_date, input_block_id)
  end

  def self.block_available(block_id)
    block = self.find_block(block_id)
    rooms = block.rooms.length
    taken = self.find_reservation_by_block_id(block_id)
    return rooms - taken.length
  end

  def self.reserve_block_room(block_id)
    raise ArgumentError.new "Invalid input. Please enter Block ID as an Integer" if !(block_id.is_a? Integer)
    block = self.find_block(block_id)
    raise ArgumentError.new "Block ID is not found" if !(block.is_a? Hotel::Block)
    # block.add_rooms
    availability = block_available(block_id)
    raise ArgumentError.new "No rooms available in Block #{block_id}" if availability == 0
    array_check_in = [block.check_in.year, block.check_in.month, block.check_in.day]
    array_check_out =[block.check_out.year, block.check_out.month, block.check_out.day]
    new_reservation = Hotel::Reservation.new(5, block.rooms[0].id, array_check_in, array_check_out, block.block_id)
    # block.add_reservations # => does nothing currently, would work if I was writing new reservations to CSV...)-':'
    block.reservations << (new_reservation)
    return new_reservation
  end
end
