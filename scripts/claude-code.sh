function cc(){
  claude \
    --permission-mode auto \
    --allowedTools "Edit(./**)" "Write(./**)" "Read(~/**)" "WebSearch" "WebFetch" \
    --disallowedTools "Read(~/.ssh/**)"
}