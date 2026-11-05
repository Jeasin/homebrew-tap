# homebrew-tap

Jeasin 的个人 Homebrew tap：把 GitHub Release 里的 macOS App 做成 cask，一条命令安装和升级。

## 安装

```bash
brew tap jeasin/tap
brew install --cask astris
```

新版 Homebrew 对第三方 tap 有信任校验，如果提示 `Refusing to load cask ... from untrusted tap`：

```bash
brew trust --tap jeasin/tap
```

## 升级 / 卸载

```bash
brew update && brew upgrade --cask
brew uninstall --cask astris         # 保留用户数据
brew uninstall --zap --cask astris   # 连同 ~/Library 下的配置和数据一起删
```

## 已收录

| Cask | 说明 | 平台 |
| --- | --- | --- |
| [`astris`](Casks/astris.rb) | Nintendo Switch emulator | macOS 15+ / arm64 |
| [`jpop-corpus-tool`](Casks/jpop-corpus-tool.rb) | 本地 Jpop 语料检索、Anki 制卡与同步歌词播放器 | macOS 14+ / arm64 |

## 新增一个 App

1. 写 `Casks/<name>.rb`。`url` 里用 `#{version}` 插值，不要写死版本号，否则 `brew audit` 会报 URL unversioned。
2. 在 `.github/casks.json` 里加一条规则，告诉自动更新脚本怎么从 release 里认版本和安装包：

   ```json
   "<name>": {
     "repo": "owner/repo",
     "tag": "^v?(?<version>[0-9]+\\.[0-9]+\\.[0-9]+)$",
     "asset": "^MyApp_(?<version>[0-9]+\\.[0-9]+\\.[0-9]+)_arm64\\.dmg$",
     "version": "{version}"
   }
   ```

   `tag` / `asset` 是带命名捕获组的正则，`version` 是写进 cask 的版本模板。需要把构建号带进 URL 的（例如 `astris`）用 `"{version},{build}"`，cask 里配合 `#{version.csv.first}` / `#{version.csv.second}` 使用。
3. 本地验证：`./scripts/bump-casks.sh <name>`，它会拉最新 release、算出 sha256 并回写 `version` / `sha256` 两行。

## 自动更新

- `.github/workflows/update-casks.yml`：每天 02:17 UTC 拉一遍所有上游 release，只重写 cask 里的 `version` 和 `sha256`，有变化就提交。支持手动触发并指定单个 cask。
- `.github/workflows/audit.yml`：`Casks/**` 有改动时在 macOS runner 上跑 `brew audit`，挡住不合规的 cask。

两个 workflow 都只改 `version` / `sha256`，不会覆盖 cask 里手写的 `livecheck`、`zap`、`caveats` 等内容。

## 本地调试

```bash
brew audit --cask --tap jeasin/tap <name>
brew livecheck --cask --tap jeasin/tap <name>
brew install --cask --verbose <name>
```

改了本地这份仓库之后，要么推上去再 `brew update`，要么直接改 `/opt/homebrew/Library/Taps/jeasin/homebrew-tap` 里的副本做验证。
