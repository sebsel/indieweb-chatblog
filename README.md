# Chatblog

The idea was to create a blog that would bundle chat messages from the 
[IndieWeb chat log](https://chat.indieweb.org) and present them as
blog posts. The `Lurker` reads the Javascript EventSource of the chat log
page, and feeds them to the appropriate `Curator` (one per channel).
These are responsible for holding the state of the conversation and
deciding whether to break or not.

When visiting the server from a browser, you will see a list of "blogposts".

## Development

To start the Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

