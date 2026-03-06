# Codemagic 构建 APK 完整指南

## 什么是 Codemagic？
Codemagic 是专门给 Flutter APP 做云构建的平台，**免费**、**不用装软件**、**自动出APK**。

---

## 第一步：准备代码仓库

Codemagic 需要从 GitHub/GitLab/Bitbucket 拉代码，所以先把项目传上去：

### 1.1 注册 GitHub 账号
- 打开 https://github.com
- 用邮箱注册（有账号直接登录）

### 1.2 创建新仓库
1. 登录 GitHub
2. 点击右上角 **+** → **New repository**
3. 仓库名填：`lung-nodule-app`
4. 选择 **Public**（公开，免费）
5. 点击 **Create repository**

### 1.3 上传代码
在服务器执行：

```bash
cd /root/.openclaw/workspace/lung_nodule_app

# 初始化git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit"

# 连接远程仓库（把下面的URL换成你创建的仓库地址）
git remote add origin https://github.com/你的用户名/lung-nodule-app.git

# 上传
git push -u origin main
```

上传成功后，刷新 GitHub 页面应该能看到所有代码文件。

---

## 第二步：注册 Codemagic

1. 打开 https://codemagic.io
2. 点击 **Sign up**
3. 选择 **Sign up with GitHub**（用GitHub账号登录最方便）
4. 授权 Codemagic 访问你的仓库

---

## 第三步：配置构建

### 3.1 添加应用
1. 登录 Codemagic 后，点击 **Add application**
2. 选择 **GitHub**
3. 找到并选择 `lung-nodule-app` 仓库
4. 点击 **Select**

### 3.2 配置工作流

Codemagic 会自动识别 Flutter 项目，按下面步骤配置：

**左侧菜单 → Workflows → Default workflow**

#### 修改 Build 配置：

**Build section:**
- **Build for platforms**: 勾选 `Android`
- **Build format**: 选择 `APK`

**Build triggers:**
- **Trigger on push**: 勾选（代码推送自动构建）
- **Trigger on tag creation**: 勾选（打标签时构建）

**Artifact:**
- 保持默认（会自动保存APK文件）

### 3.3 保存配置
点击右上角 **Save** 按钮

---

## 第四步：开始构建

### 方法1：手动触发
1. 在 Codemagic 页面点击 **Start new build**
2. 选择分支 `main`
3. 点击 **Start new build**

### 方法2：自动触发（推荐）
1. 在服务器给代码打标签：
   ```bash
   cd /root/.openclaw/workspace/lung_nodule_app
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
2. Codemagic 会自动开始构建

---

## 第五步：下载 APK

构建大概需要 **3-10分钟**（第一次可能慢一些）。

### 查看构建状态
1. 在 Codemagic 的 **Builds** 页面看进度
2. 绿色 ✓ 表示成功
3. 红色 ✗ 表示失败（可以点击查看错误日志）

### 下载 APK
构建成功后：

1. 点击成功的构建记录
2. 找到 **Artifacts** 部分
3. 点击 `app-release.apk` 下载

或者 Codemagic 会自动发送邮件给你，邮件里有下载链接。

---

## 常见问题

### Q: 构建失败怎么办？
查看构建日志，常见问题：
- **依赖下载失败**: 重新构建一次
- **Flutter版本问题**: 在 Codemagic 设置里指定 Flutter 版本为 `3.16.0`
- **代码错误**: 查看具体报错信息修复

### Q: 如何修改APP名字和图标？
- 名字: 修改 `pubspec.yaml` 里的 `name` 字段
- 图标: 替换 `android/app/src/main/res/` 下的图标文件
- 改完重新 push，Codemagic 会自动重新构建

### Q: 构建太慢？
Codemagic 免费版构建时间有限制，如果超时：
- 去掉不需要的构建步骤（如测试）
- 或者升级到付费版（一般不需要）

### Q: 如何发布到应用商店？
Codemagic 也支持自动发布到：
- Google Play Store
- Firebase App Distribution
需要额外配置，初期先用直接下载APK的方式。

---

## 完整流程图

```
GitHub 创建仓库 ──→ 上传代码 ──→ Codemagic 配置 ──→ 点击构建 ──→ 下载APK
      ↑                                                      ↓
      └──────────── 代码更新后重新push ──────────────────────┘
```

---

## 需要帮助？

- Codemagic 官方文档: https://docs.codemagic.io/
- Flutter 构建问题: 查看构建日志中的错误信息
- 也可以把错误信息发给我帮你分析

**现在就按步骤1开始吧！** 先注册GitHub上传代码，后面的都很简单。