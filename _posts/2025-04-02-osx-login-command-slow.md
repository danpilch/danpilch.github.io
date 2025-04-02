---
layout: post
title: Debugging a Slow `/usr/bin/login` on macOS (WIP) 
last_updated: 2025-04-02
category: personal
---

# Debugging a Slow `/usr/bin/login` on macOS (WIP)

> Work-in-progress notes on figuring out why `/usr/bin/login` is painfully slow on my MacBook (Apple Silicon, arm64).

## 🤔 The Problem

I've noticed that terminal sessions using `/usr/bin/login` are significantly slower than expected. This impacts not just Terminal.app and iTerm2, but also remote logins and automated scripts that rely on login shells.

## 📍 Initial Observations

- System: macOS (Apple Silicon / arm64)
- Shell: zsh
- Behavior: noticeable delay (several seconds) before shell prompt appears after login

## 🔍 Investigation So Far

### 1. Shell Startup Profiling
Ran the following to trace shell init:
```sh
zsh -i -x -c exit
```
Findings:
- Several slow steps during plugin or theme loading (suspect `oh-my-zsh`, Homebrew init, etc.)
- Will try commenting out `.zshrc` sections and testing incrementally

### 2. Login Process Timing
```sh
time login -f $USER
```
Still slower than expected. Indicates delay might be deeper than shell config.

### 3. Console Logs
Checked logs via:
```sh
log show --predicate 'eventMessage contains "login"' --last 5m
```
Not much of note yet. May need more specific queries.

### 4. PAM Modules
Looking into `/etc/pam.d/login` in case there are any unusual or slow modules.

## 🧵 Slack Thread Highlights
Troubleshooting this in Slack led to some additional context:

- `/usr/bin/login` seems to be thrashing CPU at 100%, confirmed via Activity Monitor.
- Each new terminal session spawns another high-CPU `login` process.
- iTerm2 and Terminal.app both use `login`, though Terminal is less aggressive on CPU.
- Custom `.launchshell.sh` script to bypass login didn’t help—iTerm2 still invokes `login`.
- `/etc/resolv.conf` includes `127.0.0.1`, possibly due to Cisco Umbrella, though unchanged.
- Reinstalling iTerm2 didn’t fix it—important to also remove:
  ```sh
  rm -rf ~/Library/Application\ Support/iTerm2/
  ```
  or move it to reset daemon/config.
- Terminal eventually works (after 10-15 mins), pointing to some long-running delay during login.

## 🚫 Tooling Limitations
### `dtruss` is Broken on Apple Silicon 😞
Tried to trace with:
```sh
dtruss login
```
But on M1/M2 MacBooks:
> `dtrace: system integrity protection is on, some features will not be available`
> `ksh: dtrace: operation not permitted`

Even with SIP disabled, `dtruss` often fails or panics the machine.

Currently exploring alternatives like:
- `opensnoop`
- `fs_usage`
- `instruments`
- Writing custom `DTrace` scripts (with low expectations)

### Using `fs_usage` with a Script
I tried this script to watch `/usr/bin/login` as soon as it spawns:
```bash
#!/bin/bash
echo "Waiting for /usr/bin/login to start..."

while true; do
    pid=$(pgrep -f '^/usr/bin/login' | head -n1)
    if [[ -n "$pid" ]]; then
        echo "Found login with PID $pid"
        echo "Attaching fs_usage..."
        sudo fs_usage -w -f filesys -e $pid | gawk '$NF ~ /login/ { print }' | tee loginfs.log
        break
    fi
    sleep 0.5
done
```
This should help isolate file access patterns right at the moment `/usr/bin/login` kicks in.

## ✅ Next Steps
- [ ] Incrementally disable shell config lines to pinpoint slowness
- [ ] Compare behavior between login vs non-login shell
- [ ] Try alternative tracing tools (e.g. `fs_usage`)
- [ ] Create a minimal repro environment
- [ ] Investigate any DNS or resolver-related stalls (e.g., Umbrella or `/etc/resolv.conf` with `127.0.0.1`)
- [ ] Consider backing up and resetting iTerm2 daemon settings

## 🧠 Theories
- Shell startup configs are the main culprit
- PAM or launch agent overhead
- Rosetta fallback for some legacy binaries?
- DNS resolution delays from `127.0.0.1` entry in `resolv.conf`

---

Will keep updating this post as I dig further. If you’ve run into this issue or have debugging tips for arm64 macOS, reach out!

