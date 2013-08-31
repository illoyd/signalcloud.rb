module SignalCloud

  class Organization < ::APISmith::Smash
    property :id,                   transformer: :to_i
    property :label

    property :created_at,           transformer: lambda { |v| Time.parse(v) rescue nil }
    property :updated_at,           transformer: lambda { |v| Time.parse(v) rescue nil }
  end

end
