class TimerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts("koioyuigyfutdhfcgvhbjn")
    ActionCable.server.broadcast("room_hogehoge", "ihugi:lpkojihukbyftdh")
  end
end
