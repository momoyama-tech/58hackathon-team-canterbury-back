class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = data["text"]
    ActionCable.server.broadcast("room_#{params[:room]}", { text: message })
  end
end
