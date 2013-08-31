module SignalCloud

  class Conversation < ::APISmith::Smash
    property :id,                   transformer: :to_i
    property :stencil_id,           transformer: :to_i
    property :to_number
    property :from_number
    
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

    property :created_at,           transformer: lambda { |v| Time.parse(v) rescue nil }
    property :updated_at,           transformer: lambda { |v| Time.parse(v) rescue nil }
    property :expires_at,           transformer: lambda { |v| Time.parse(v) rescue nil }
    property :challenge_sent_at,    transformer: lambda { |v| Time.parse(v) rescue nil }
    property :response_received_at, transformer: lambda { |v| Time.parse(v) rescue nil }
    property :reply_received_at,    transformer: lambda { |v| Time.parse(v) rescue nil }
  end

end
