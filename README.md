# Jeopardy

To start your Phoenix server:

  * `npm install --prefix ./assets`
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Prod config with systemd

I use systemd to run the service so that restarts and log files are handled in a standard way.

- Write this file to `/etc/systemd/system/jeopardy.service`
- Append necessary environment variables to `/etc/environment`
- After each change to the `jeopardy.service` config file: `sudo systemctl daemon-reload`
- Start the service: `sudo systemctl start jeopardy`
- Stop the service: `sudo systemctl stop jeopardy`
- Tail logs: `sudo journalctl -f -u jeopardy`

### Sample systemd config

```
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

LimitNOFILE=65535
UMask=0027
SyslogIdentifier=jeopardy
Restart=always

[Install]
WantedBy=multi-user.target
```

### etc/environment

```
DATABASE_PATH="/path/to/sqlite/database/file"
JARCHIVE_PATH="/path/to/jarchive"
SECRET_KEY_BASE="result of mix phx.gen.secret"
PHX_HOST="public hostname"
PORT=80
```
