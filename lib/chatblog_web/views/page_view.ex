defmodule ChatblogWeb.PageView do
  use ChatblogWeb, :view

  def calculate_grid(date) do
    time = DateTime.to_time(date)
    {hours, minutes, _seconds} = Time.to_erl(time)
    # There's a bug in Chrome when you go over 1000 grid rows,
    # but one grid row per two minutes will do fine.
    (hours * 30) + div(minutes, 2)
  end
end
