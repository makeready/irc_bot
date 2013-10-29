class Changer
  def self.make_change(input)
    to_change = input.to_i
    return "Nope" unless to_change.is_a? Fixnum
    denominations = [10000,5000,2000,1000,500,200,100,25,10,5,1]
    change = []
    while to_change > 0 do
      denominations.each do |denomination|
        if to_change / denomination > 0 
          change << denomination
          to_change -= denomination
          break
        end
      end
    end
    change
  end
end
