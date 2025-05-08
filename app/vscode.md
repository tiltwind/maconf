# vscode 常见用法

### 方法一：借助`launch.json`文件 配置环境变量
1. 开启`.vscode`文件夹下的`launch.json`文件。若该文件不存在，可通过以下步骤创建：
    - 打开“Run and Debug”视图（快捷键`Ctrl + Shift + D`）。
    - 点击“create a launch.json file”。
    - 选择“Go”环境。
2. 在`launch.json`文件里添加或修改`env`字段，以此设置环境变量。以下是示例：
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Go Test",
            "type": "go",
            "request": "launch",
            "mode": "test",
            "program": "${fileDirname}",
            "env": {
                "MY_VARIABLE": "my_value",
                "ANOTHER_VARIABLE": "another_value"
            }
        }
    ]
}
```
在这个示例中，`MY_VARIABLE`和`ANOTHER_VARIABLE`就是你设定的环境变量，你可以按需进行修改。

### 方法二：使用`settings.json`文件 配置环境变量
1. 打开“File” -> “Preferences” -> “Settings”（快捷键`Ctrl + ,`）。
2. 切换到“Workspace Settings”（工作区设置）。
3. 点击右上角的“Open Settings (JSON)”图标，打开`settings.json`文件。
4. 在`settings.json`文件中添加`go.testEnvVars`字段来设置环境变量，示例如下：
```json
{
    "go.testEnvVars": {
        "MY_VARIABLE": "my_value",
        "ANOTHER_VARIABLE": "another_value"
    }
}
```
这样配置之后，所有的Go测试都会使用这些环境变量。
