module SignalCloud

  class TimeTransformer
    
    def self.call(value)
      return nil if value.nil? || value.to_s.strip == ''
      Time.parse(value)
    end
    
    def self.transform(value)
      call(value)
    end

  end

end