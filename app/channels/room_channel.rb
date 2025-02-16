class RoomChannel < ApplicationCable::Channel
  def subscribed
    room_id = params[:room]
    stream_from "room_#{room_id}"
    nickname = params[:nickname]
    # 購読者リストを取得して更新
    players = Rails.cache.fetch("players_#{room_id}") { [] }
    players << { nickname: nickname, image: "https://placehold.jp/150x150.png" }
    Rails.cache.write("players_#{room_id}", players)
    Rails.logger.info "✅ Subscribed to room_#{room_id}"
    # ルームにいるプレイヤーリストを全員にブロードキャスト
    broadcast_players(room_id)
  end

  def unsubscribed
    hashed_room = params[:room]
    nickname = params[:nickname]

    # 購読者リストから削除
    players = Rails.cache.fetch("players_#{hashed_room}") { [] }
    players.reject! { |player| player[:nickname] == nickname }
    Rails.cache.write("players_#{hashed_room}", players)

    # 更新後のプレイヤーリストを全員にブロードキャスト
    broadcast_players(hashed_room)
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

  def start_game(data)
    ActionCable.server.broadcast("#{params[:room]}", {
      type: "text",
      data: {
        command: "start_game"
      }
    })
    TimerJob.start_countdown(params[:room], 60)
  end

  private

  def broadcast_players(room)
    players = Rails.cache.fetch("players_#{room}") { [] }
    ActionCable.server.broadcast("room_#{room}", {
      type: "text",
      data: {
        command: "get_players",
        players: players
      }
    })
  end
end
