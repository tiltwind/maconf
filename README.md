# my mac config

- [System-preferences](system-preferences)
- [Apps](app)
- [Scripts](scripts)
- [etc](etc)


## useful app in app store

- Tencent Lemon Cleanner (Lite) : Clean up and free up space

## view all app under mac

```bash
system_profiler SPApplicationsDataType|sed -n 's/^ *Location: \(.*\)/\1/p' | sort > apps.txt
```

## experience

1. chrome full screen capture:
- open dev tool: `command + option + i`
- open command tool: `command + shift + p`#
- input `screenshot`, choose the `Capture full size screenshot`

## Application Management

- update all software: `softwareupdate --all --install --force`

