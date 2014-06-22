module SignalCloud

  class Stencil < ::APISmith::Smash
  
    property :id,                       transformer: :to_i
    property :phone_directory_id,       transformer: :to_i

    property :label
    property :description
    property :primary

    property :webhook_uri
    property :seconds_to_live

    property :question
    property :expected_confirmed_answer
    property :expected_denied_answer
    property :confirmed_reply
    property :denied_reply
    property :failed_reply
    property :expired_reply

    property :created_at,               transformer: TimeTransformer
    property :updated_at,               transformer: TimeTransformer
  end

end
