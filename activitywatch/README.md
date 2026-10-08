# ActivityWatch configuration

ActivityWatch's `~/.config/activitywatch/aw-tauri/config.toml` is managed by
mise's shared dotfile history in `FilipHarald/dotfiles-private`, not by a
symlink into this Git checkout. This prevents a Git pull or Stow operation
from enabling machine-specific watchers on the wrong host.

The shared `~/.config/mise/config.toml` declares:

```toml
[dotfiles]
"~/.config/activitywatch/aw-tauri/config.toml" = { mode = "track", variants = [{ profile = "octi" }, { profile = "decem" }] }
```

The `octi` variant autostarts only `aw-awatcher`. The `decem` variant
autostarts `aw-awatcher` and `aw-watcher-steam`. The Steam watcher must not
be installed on `octi`; syncing its configuration does not install packages.

Each machine's `dev.mise.mise-history.service` has a local `profile.conf`
drop-in setting `MISE_ENV` to its hostname. The watcher automatically saves,
publishes, and applies only the matching variant using the same shared repo.
For manual operations, select the profile explicitly:

```sh
mise -E "$(hostname)" dot save ~/.config/activitywatch/aw-tauri/config.toml
mise -E "$(hostname)" dot sync
mise -E "$(hostname)" dot pull --dry-run
mise -E "$(hostname)" dot pull --yes
```

When migrating an existing installation, preserve the current config and
replace any symlink to the old checkout path with a regular file before
pulling the Git commit that removes that path. Sync mise on both hosts to
receive the new declaration and capture each host's own configuration.
ActivityWatch reads its autostart configuration when it starts next.
