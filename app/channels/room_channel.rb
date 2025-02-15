class RoomChannel < ApplicationCable::Channel
  def subscribed
    hashed_room = params[:room]
    stream_from "room_#{hashed_room}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    hashed_room = params[:room]

    if data["type"] == "image" && data["data"].start_with?("data:image/")
      ActionCable.server.broadcast("room_#{hashed_room}", {
        type: "image",
        data: data["data"]
      })
    elsif data["text"].present?
      ActionCable.server.broadcast("room_#{hashed_room}", {
        type: "text",
        text: data["text"]
      })
    else
      Rails.logger.error "Invalid data received: #{data.inspect}"
    end
  end
end
