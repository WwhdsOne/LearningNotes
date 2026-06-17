使用zsh的，在**setting.json**中加入：

```json
{
    "rust-analyzer.restartServerOnConfigChange": true,
    "rust-analyzer.runnables.extraEnv": {
        "PATH": "${env:HOME}/.cargo/bin:${env:PATH}"
    }
}
```

即可避免报错