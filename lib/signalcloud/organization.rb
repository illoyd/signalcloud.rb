module SignalCloud

  class Organization < ::APISmith::Smash
    property :id,                   transformer: :to_i
    property :label

    property :created_at,           transformer: TimeTransformer
    property :updated_at,           transformer: TimeTransformer
  end

end
