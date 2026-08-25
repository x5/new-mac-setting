# GitHub 发布标准（SOP）：README、仓库设置与持续演进

> 从「Mac Mini × AI Agent 开发环境指南」项目实践提炼的可复用标准。
> 适用于任何要公开发布、希望被搜索到、被 star 的 GitHub 仓库。
> 覆盖三层资产：**文档内容**（README）、**法律与卫生**（LICENSE / .gitignore）、**仓库元数据**（description / topics / Pages / social preview / releases）。

---

## 一、动笔前：定位三问

1. **谁会搜到它？** → 决定关键词（中英双语，想读者会搜什么词）
2. **30 秒内读者要决定什么？** → 决定头版放什么（值不值得读下去）
3. **读完他要做什么？** → 决定行动召唤（clone / 按章节执行 / star）

答不出这三问，先别写。

## 二、README 结构标准（自上而下 = 注意力递减）

| 层级 | 内容 | 目标 |
|---|---|---|
| 1. 头版 | 名称 + 一句话价值主张（双语）+ 徽章行 + 锚点导航 + 效果图 | 30 秒决定去留 |
| 2. What / Why | 这是什么、解决什么问题、核心原则（≤3 条） | 建立认同 |
| 3. 演示 | 实拍截图 / GIF | 一图胜千言 |
| 4. 内容清单 | 功能 / 章节表格 | 快速扫描 |
| 5. 快速开始 | 最快路径的命令（非全部命令） | 降低行动门槛 |
| 6. 详细文档 | 链向完整手册 | 分流深度读者 |
| 7. 技术栈 | 速览代码块或列表 | 给同行看的 |
| 8. 参考 / 致谢 | 真实链接 | 严谨性背书 |
| 9. License + Star 引导 | 授权与社区信号 | 收尾转化 |

**铁律：读者 30 秒决定去留——"名称 + 价值主张 + 徽章 + 效果图"必须在第一屏。**

## 三、视觉规范

- 居中对齐**只用于头版**，正文一律左对齐
- 徽章 ≤ 6 枚（shields.io），信息必须真实——不堆装饰性徽章
- 能用表格就不用长段落：对比、清单、导航全部表格化
- emoji 当章节图标：**每标题一个、正文不用**。克制才专业
- 截图必须真实渲染（推荐 Playwright 实拍），宽度 1200-1440px，风格统一
- 代码块标注语言，只给"最快路径"

## 四、严谨性规范

- 每条命令可复制执行；版本、事实有出处
- 存疑信息明确标注"未验证"及原因
- 参考链接真实有效
- README 声明了什么 License，仓库就必须存在对应的 `LICENSE` 实体文件

## 五、可发现性（SEO）

- 仓库名：kebab-case，含核心关键词
- 关键词进 README 的 H1 / H2（GitHub 搜索和搜索引擎都吃标题权重）
- 文末放 SEO Keywords 区（英文检索词 + 中文检索词）
- description / topics 见下章——它们出现在 GitHub 搜索结果里，权重高于 README 正文

## 六、GitHub 仓库设置（发布配置）

README 之外，仓库本身的元数据是第二战场。搜索列表里用户看到的是**仓库名 + description + topics**，不是 README。

### 6.1 Description（仓库描述）

- 出现在仓库页 About 和**搜索结果第二行**，是 CTR（点击率）的决定因素
- 规范：≤120 字符（截断后仍完整）；中英双语，用 `—` 分隔；结构 = 中文价值主张 — English value + keywords
- 命令：`gh repo edit --description "..."`

### 6.2 Topics

- 8-12 个；全小写、连字符
- 三层选词法：**平台/生态**（`macos`、`homebrew`）+ **领域**（`ai-agents`、`dotfiles`）+ **具体工具名**（`claude-code`、`ghostty`）
- 命令：`gh repo edit --add-topic xxx`

### 6.3 Website / Homepage

- About 里的链接位，别浪费：文档型仓库填在线阅读地址
- 单页 HTML 项目直接开 **GitHub Pages**（Settings → Pages → Deploy from branch → main），把 `xxx.html` 变成可分享的在线版
- 命令：`gh repo edit --homepage "https://<user>.github.io/<repo>/<page>.html"`

### 6.4 Social Preview（社交分享图）

- Settings → General → Social preview，上传 **1280×640** PNG
- 链接被分享到 X / 微信 / Discord 时的卡片图——没有它，分享出去只是一行灰字
- 做法：复用 hero 截图裁到 1280×640

### 6.5 功能开关（按需）

- Issues：开着收反馈；Wiki：文档就在仓库里则关掉；Discussions：想做社区再开
- 赞助：`FUNDING.yml` 可选

### 6.6 Releases 与版本

- 内容型仓库也用 Release 标记版本（`v1.0.0` = 初版），配 release notes——watch 仓库的人会收到更新
- 命令：`gh release create v1.0.0 --notes "..."`

### 6.7 安全与杂项

- 公开仓库自动开启 secret scanning，但 push 前仍要自查一遍敏感信息
- 分支保护（个人项目可选）：main 禁止 force push
- 社区文件（做大后再补）：`CONTRIBUTING.md`、`CODE_OF_CONDUCT.md`、Issue/PR 模板

## 七、发布检查清单

**文件层**

- [ ] `LICENSE` 实体文件存在（与 README 声明一致）
- [ ] `.gitignore`（系统文件、临时文件）
- [ ] 截图已入库，README 用相对路径引用
- [ ] 全文无敏感信息（Key、token、内网地址）

**提交层**

- [ ] 提交单一目的，Conventional Commits 英文提交信息
- [ ] 初始发布打 tag：`v1.0.0`

**仓库设置层**

- [ ] description：中英双语 ≤120 字符
- [ ] topics：8-12 个，三层选词
- [ ] homepage：Pages 在线地址（如适用）
- [ ] social preview：1280×640 分享图
- [ ] 功能开关：Issues 开 / Wiki 按需关
- [ ] Release `v1.0.0` + notes

**验收层**

- [ ] 窄屏 / 手机预览，表格不换行炸裂
- [ ] 用无痕窗口搜一个目标关键词，确认仓库能被搜到

## 八、持续演进

- README 随内容更新——文档是会腐烂的资产
- 效果图过期立即重截（截图脚本留在 scripts/ 或仓库外）
- 重大更新配 release notes；topics 随内容扩展补充
- 对环境类项目：README 的运维纪律 = 项目本身的 dotsync 思维——变更即同步

---

*提炼自 [x5/new-mac-setting](https://github.com/x5/new-mac-setting) 的发布实践，2026。*
