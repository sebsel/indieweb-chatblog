defmodule Chatblog.Repo do
  use Ecto.Repo,
    otp_app: :chatblog,
    adapter: Ecto.Adapters.MySQL
end
