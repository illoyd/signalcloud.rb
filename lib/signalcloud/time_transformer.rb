module SignalCloud

  class TimeTransformer
    
    def self.call(value)
      return nil if value.nil? || value.to_s.strip == ''
      Time.parse(v)
    end

  end

end