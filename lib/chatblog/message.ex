defmodule Chatblog.Message do
  alias __MODULE__, as: Message

  defstruct html: nil,
            id: nil,
            text: nil,
            url: nil,
            published: nil,
            author: nil,
            author_photo: nil,
            author_url: nil,
            type: :message

  def from_html(html) do
    # First rule of HTML parsing: do not use regex.
    message =
      %Message{html: html}
      |> find(:id, ~r|id="(.*?)"|)
      |> find(:text, ~r|<span class="e-content p-name">(.*?)$|)
      |> Map.update!(:text, &strip_text_tags/1)
      |> find(:url, ~r|<a href="(.*?)" class="hash"|)
      |> find(:author, ~r|class="author p-nickname p-name u-url".*?>(.*?)</a>|)
      |> find(:author_photo, ~r|class="avatar"><img src="(.*?)"|)
      |> find(:author_url, ~r|p-author.*?<a href="(.*?)" class="author p-nickname p-name u-url"|)
      |> find(:published, ~r|class="dt-published" datetime="(.*?)"|)
      |> Map.update!(:published, &parse_published_time/1)

    %{message | type: determine_type(message)}
  end

  defp find(%Message{html: html} = message, field, regex) do
    match =
      case Regex.run(regex, html) do
        nil -> nil
        [_, match | _] -> match
      end

    Map.put(message, field, match)
  end

  defp determine_type(%Message{html: html, author: author}) do
    loqi? = author == "Loqi"

    cond do
      html == nil ->
        nil

      Regex.match?(~r|class=".*? msg-wiki .*?"|, html) ->
        :wiki_edit

      loqi? and Regex.match?(~r/>.+?: .+? left you a message .+? ago: /, html) ->
        :tell

      loqi? and Regex.match?(~r|ok, I added ".*?" to the "See Also" section of|, html) ->
        :wiki_append

      Regex.match?(~r|class=".*? msg-twitter .*?"|, html) ->
        :tweet

      Regex.match?(~r|class=".*? msg-message .*?"|, html) ->
        :message

      true ->
        :unknown
    end
  end

  # the things I do for love
  defp strip_text_tags(nil), do: nil
  defp strip_text_tags(text) do
    String.replace(text, ~r|<.*?>|, "")
  end

  defp parse_published_time(nil), do: nil
  defp parse_published_time(string) do
    {:ok, published, _} = DateTime.from_iso8601(string)
    published
  end
end
