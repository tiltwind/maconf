function cc(){
  claude \
    --permission-mode auto \
    --allowedTools "Edit(./)" "Read(~/**)" "WebSearch" "WebFetch" \
    --disallowedTools "Read(~/.ssh/**)"
}
