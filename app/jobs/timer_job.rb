class TimerJob < ApplicationJob
  queue_as :default

  def perform(channel, seconds)
    seconds.downto(1) do |remaining_time|
      ActionCable.server.broadcast(channel, { command: "countdown", time: remaining_time })
      sleep 1
    end
    ActionCable.server.broadcast(channel, { command: "time_up", message: "Time's up!" })
  end

  def self.start_countdown(channel, seconds)
    perform_later(channel, seconds)
  end
end
