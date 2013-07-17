module Ruby2600
  class TIAPlayer
    include Constants

    def initialize(tia_registers)
      @tia = tia_registers
      @counter = TIACounter.new
      @counter.on_change do |value|
        if (value == 39) ||
           (value ==  3 && [0b001, 0b011].include?(@tia[NUSIZ0])) ||
           (value ==  7 && [0b010, 0b011, 0b110].include?(@tia[NUSIZ0])) ||
           (value == 15 && [0b100, 0b110].include?(@tia[NUSIZ0]))
          @grp_bit = -5
          @bit_copies_written = 0
        end
      end
    end

    def pixel
      update_pixel_bit
      @counter.tick
      @tia[COLUP0] if @pixel_bit == 1
    end

    # FIXME might call reset?
    def strobe
      @counter.reset
    end

    # FIXME test; might call the counter one hmove?
    def hmove(value)
      @counter.move(value)
    end

    private

    def update_pixel_bit
      if @grp_bit
        if (0..7).include?(@grp_bit)
          @pixel_bit = @tia[GRP0][7 - @grp_bit] 
          @bit_copies_written += 1
          if @bit_copies_written == player_size
            @bit_copies_written = 0
            @grp_bit += 1
          end
        else
          @grp_bit += 1
        end
        @grp_bit = nil if @grp_bit > 7
      else
        @pixel_bit = nil
      end
    end

    def player_size
      case @tia[NUSIZ0]
      when 0b101 then 2
      when 0b111 then 4
      else 1
      end
    end
  end
end

