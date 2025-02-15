class TimersController < ApplicationController
  def set_timer
    room = params[:room]
    seconds = params[:seconds].to_i
    message = params[:message]

    if room.present? && seconds > 0
      TimerJob.set(wait: seconds.seconds).perform_later(room, message)
      render json: { status: "ok", message: "タイマーをセットしました" }, status: :ok
    else
      render json: { status: "error", message: "無効なデータです" }, status: :unprocessable_entity
    end
  end
end
