# Jeopardy

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * `cd assets && npm i && cd ..`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Prod config

I use systemd to run the service so that restarts and log files are handled in a standard way.

- Write this file to `/etc/systemd/system/jeopardy.service
- After each change to the `jeopardy.service` config file: `sudo systemctl daemon-reload`
- Start the service: `sudo systemctl start jeopardy`
- Stop the service: `sudo systemctl stop jeopardy`
- Tail logs: `sudo journalctl -f -u jeopardy`

### Sample systemd config

``` toml
# /etc/systemd/system/jeopardy.service
[Unit]
Description=Jeopardy service
After=local-fs.target network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/home/jeopardy/_build/prod/rel/jeopardy
ExecStart=/home/jeopardy/_build/prod/rel/jeopardy/bin/server
ExecStop=/home/jeopardy/_build/prod/rel/jeopardy/bin/jeopardy stop
Environment=LANG=en_US.utf8
Environment=MIX_ENV=prod

Environment=DATABASE_PATH="/path/to/sqlite/db"
Environment=SECRET_KEY_BASE="result of mix phx.gen.secret"
Environment=PHX_HOST="your hostname"
Environment=PORT=80

LimitNOFILE=65535
UMask=0027
SyslogIdentifier=jeopardy
Restart=always


[Install]
WantedBy=multi-user.target
```


``` toml
[Unit]
Description=Jeopardy service
After=local-fs.target network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/home/jeopardy/_build/prod/rel/jeopardy
ExecStart=/home/jeopardy/_build/prod/rel/jeopardy/bin/server
ExecStop=/home/jeopardy/_build/prod/rel/jeopardy/bin/jeopardy stop
# EnvironmentFile=/etc/default/jeopardy.env
Environment=LANG=en_US.utf8
Environment=MIX_ENV=prod

Environment=DATABASE_PATH="/home/jeopardy/db/jeopardy.db"
Environment=SECRET_KEY_BASE="fwLiNDqXTaAbH+kD8iWfmnl7sHd2puYhBa5p5ClpC3P+CNltlWDH0gGaWdb9uWtZ"
Environment=PHX_HOST="jeopardy.ryoung.info"
Environment=PORT=80

LimitNOFILE=65535
UMask=0027
SyslogIdentifier=jeopardy
Restart=always


[Install]
WantedBy=multi-user.target
```
