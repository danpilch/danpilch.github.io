---
layout: post
title: Deep Dive into DYLD Injection and macOS Login Internals 
last_updated: 2025-04-03
category: personal
---

# Deep Dive into DYLD Injection and macOS Login Internals

Over the past few days, I explored DYLD-based injection on macOS, targeting low-level system binaries like `/usr/bin/login`. The goal was to trace file and process activity during user authentication by injecting a custom dynamic library that hooks standard C library calls like `open()`, `read()`, `write()`, and `execve()`.

This post documents what worked, what didn’t, and why macOS makes this particularly hard — along with working code snippets and observations.

---

## DYLD Injection on macOS

DYLD (the macOS dynamic linker) allows runtime interposition on functions using environment variables:

- `DYLD_INSERT_LIBRARIES` – injects a dynamic library into a process at startup.
- `DYLD_FORCE_FLAT_NAMESPACE` – disables two-level symbol resolution, allowing function overrides.

Example:

```sh
DYLD_INSERT_LIBRARIES=./log_syscalls.dylib DYLD_FORCE_FLAT_NAMESPACE=1 /bin/ls
```

This works well for normal binaries, but fails silently for setuid or hardened binaries like `/usr/bin/login`.

---

## Problem: Injecting into `/usr/bin/login`

macOS implements several layers of protection that prevent DYLD injection into sensitive system binaries:

1. **Setuid Protection**: DYLD variables are ignored by binaries with the setuid bit set.
2. **Code Signing and Hardened Runtime**: Binaries like `/usr/bin/login` are code signed by Apple with hardened runtime enabled.
3. **Platform Binaries**: Many system tools are “platform binaries” and restrict unsigned modifications.

We can verify this using `codesign`:

```sh
codesign -dvvv /usr/bin/login
```

Output (truncated):

```
Identifier=com.apple.login
Format=Mach-O universal (x86_64 arm64e)
CodeDirectory ... flags=0x0(none)
Platform identifier=16
...
```

Even with SIP disabled via `csrutil disable`, DYLD injection remains blocked for binaries signed in this way.

---

## Attempted Workarounds

### 1. Copying and Stripping Setuid

I copied `/usr/bin/login` to a local path and removed the setuid bit:

```sh
cp /usr/bin/login ./mylogin
chmod u-s ./mylogin
```

Result: still not injectable, and it failed with errors like:

```
mylogin: could not determine audit condition
```

Log output revealed `logind` attempting to activate system services and failing:

```
logind: listener failed to activate: xpc_error=[1: Operation not permitted]
```

This confirmed that `/usr/bin/login` is tightly coupled with launchd and the system session layer — it’s not safe or viable to run it manually.

---

## Building a Custom Login with PAM

To bypass these issues, I wrote a simplified `login` command using PAM. It prompts for a username and password, authenticates using macOS’s PAM stack, and launches the user’s default shell.

### `pam_login.c`

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <security/pam_appl.h>
#include <unistd.h>
#include <pwd.h>
#include <errno.h>

// PAM conversation callback
static int pam_conversation(int num_msg, const struct pam_message **msg,
                            struct pam_response **resp, void *appdata_ptr) {
    struct pam_response *replies = calloc(num_msg, sizeof(struct pam_response));
    if (!replies) return PAM_CONV_ERR;

    for (int i = 0; i < num_msg; ++i) {
        if (msg[i]->msg_style == PAM_PROMPT_ECHO_OFF) {
            char *pw = getpass(msg[i]->msg);
            replies[i].resp = strdup(pw);
        } else if (msg[i]->msg_style == PAM_PROMPT_ECHO_ON) {
            printf("%s", msg[i]->msg);
            char buf[256];
            if (!fgets(buf, sizeof(buf), stdin)) return PAM_CONV_ERR;
            replies[i].resp = strdup(buf);
        } else if (msg[i]->msg_style == PAM_ERROR_MSG || msg[i]->msg_style == PAM_TEXT_INFO) {
            fprintf(stderr, "%s\n", msg[i]->msg);
        } else {
            free(replies);
            return PAM_CONV_ERR;
        }
    }

    *resp = replies;
    return PAM_SUCCESS;
}

int main(int argc, char *argv[]) {
    const char *user = (argc >= 2) ? argv[1] : NULL;
    if (!user) {
        fprintf(stderr, "Usage: %s <username>\n", argv[0]);
        return 1;
    }

    struct pam_conv conv = { .conv = pam_conversation, .appdata_ptr = NULL };
    pam_handle_t *pamh = NULL;

    if (pam_start("login", user, &conv, &pamh) != PAM_SUCCESS) return 1;
    if (pam_authenticate(pamh, 0) != PAM_SUCCESS) return 1;
    if (pam_acct_mgmt(pamh, 0) != PAM_SUCCESS) return 1;

    pam_end(pamh, PAM_SUCCESS);
    printf("Authentication successful! Launching shell...\n");

    struct passwd *pw = getpwnam(user);
    if (!pw) return 1;

    setgid(pw->pw_gid);
    setuid(pw->pw_uid);

    execl(pw->pw_shell, pw->pw_shell, (char *)NULL);
    perror("execl");
    return 1;
}
```

Compile it:

```sh
clang -arch arm64 pam_login.c -o pam_login -lpam
```

This binary runs independently of system internals and accepts DYLD injection.

---

## DYLD Hook Library for Tracing Syscalls

I used the following interposer to hook common libc calls:

### `log_syscalls.c`

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <sys/types.h>

static void log_event(const char *format, ...) {
    FILE *log = fopen("/tmp/injected.log", "a");
    if (!log) return;
    va_list args;
    va_start(args, format);
    vfprintf(log, format, args);
    va_end(args);
    fclose(log);
}

__attribute__((constructor))
static void init() {
    log_event("[*] Dylib injected into process\n");
}

int open(const char *path, int oflag, ...) {
    static int (*real_open)(const char *, int, ...) = NULL;
    if (!real_open) real_open = dlsym(RTLD_NEXT, "open");
    log_event("open(\"%s\", 0x%x)\n", path, oflag);
    va_list args;
    va_start(args, oflag);
    int fd = real_open(path, oflag, args);
    va_end(args);
    return fd;
}

ssize_t read(int fd, void *buf, size_t count) {
    static ssize_t (*real_read)(int, void *, size_t) = NULL;
    if (!real_read) real_read = dlsym(RTLD_NEXT, "read");
    log_event("read(fd=%d, count=%zu)\n", fd, count);
    return real_read(fd, buf, count);
}

ssize_t write(int fd, const void *buf, size_t count) {
    static ssize_t (*real_write)(int, const void *, size_t) = NULL;
    if (!real_write) real_write = dlsym(RTLD_NEXT, "write");
    log_event("write(fd=%d, count=%zu)\n", fd, count);
    return real_write(fd, buf, count);
}

int execve(const char *pathname, char *const argv[], char *const envp[]) {
    static int (*real_execve)(const char *, char *const[], char *const[]) = NULL;
    if (!real_execve) real_execve = dlsym(RTLD_NEXT, "execve");
    log_event("execve(\"%s\")\n", pathname);
    return real_execve(pathname, argv, envp);
}

int access(const char *path, int amode) {
    static int (*real_access)(const char *, int) = NULL;
    if (!real_access) real_access = dlsym(RTLD_NEXT, "access");
    log_event("access(\"%s\", 0x%x)\n", path, amode);
    return real_access(path, amode);
}

int stat(const char *pathname, struct stat *statbuf) {
    static int (*real_stat)(const char *, struct stat *) = NULL;
    if (!real_stat) real_stat = dlsym(RTLD_NEXT, "stat");
    log_event("stat(\"%s\")\n", pathname);
    return real_stat(pathname, statbuf);
}
```

Compile:

```sh
clang -arch arm64e -dynamiclib -o log_syscalls.dylib log_syscalls.c
```

Test it with the custom login binary:

```sh
DYLD_INSERT_LIBRARIES=./log_syscalls.dylib DYLD_FORCE_FLAT_NAMESPACE=1 ./pam_login your_username
```

Check output:

```sh
cat /tmp/injected.log
```

---

## Conclusion

DYLD injection is a powerful mechanism for introspecting macOS binaries, but modern protections make injecting into system tools like `/usr/bin/login` nearly impossible. Building a minimal, injectable alternative using PAM provides a more flexible and transparent way to explore user authentication and shell launching behavior.

Further extensions could include:

- PTY session creation with `forkpty()`
- PAM session accounting (`pam_open_session`, `pam_close_session`)
- Logging shell I/O or command history
- Integrating syscall tracing into full user emulation environments
