
# 配置程序启动环境变量

```bash

#!/bin/bash
export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890
exec /Applications/Claude.app/Contents/MacOS/Claude
```


