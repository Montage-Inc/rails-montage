module MontageRails
  class Boolean
    def self.is_me?(value)
      return true if value.is_a?(TrueClass)
      return true if value.is_a?(FalseClass)
      return true if ["true", "false", "1", "0"].include?(value.to_s.downcase)
      false
    end  
  end
end
