module SignalCloud

  class Conversation < ::APISmith::Smash
    property :id,                   transformer: :to_i
    property :stencil_id,           transformer: :to_i
    property :customer_number
    property :internal_number
    
    property :status
    property :status_text

    property :challenge_status
    property :challenge_status_text

    property :reply_status
    property :reply_status_text

    property :webhook_uri

    property :question
    property :confirmed_reply
    property :denied_reply
    property :expired_reply
    property :failed_reply

    property :created_at,           transformer: TimeTransformer
    property :updated_at,           transformer: TimeTransformer
    property :expires_at,           transformer: TimeTransformer
    property :challenge_sent_at,    transformer: TimeTransformer
    property :response_received_at, transformer: TimeTransformer
    property :reply_received_at,    transformer: TimeTransformer
  end

end
