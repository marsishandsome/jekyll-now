---
layout: post
title: Gitbook的使用
---

GitBook是一款开源的电子书制作软件，基于Node.js，让你能够使用GitHub/Git和Marsdwon构建出美丽的pdf文档。

[GitBook官网](http://www.gitbook.io)

[GitBook Github地址](https://github.com/GitbookIO/gitbook)


# Windows安装步骤

### 1.安装Node.js
[下载Node.js](http://nodejs.org/download/)

### 2. 安装Gitbook
```bash
npm install gitbook -g
```

把```C:\Users\username\AppData\Roaming\npm```加入到系统环境变量中

### 3. 安装Calibre
[下载Calibre](http://www.calibre-ebook.com/)

### 4. 安装Gitbook Editor
[下载Gitbook Editor](https://github.com/GitbookIO/editor/releases)

[Gitbook Editor Github](https://github.com/GitbookIO/editor/releases)

# 使用GitBook

### 1.编辑
使用Gitbook Editor新建Book，用Markdown编辑

### 2. 预览
1: Gitbook Editor提供实时预览功能

![](/images/gitbook-preview.png)

2: 启动Preview Server，通过浏览器访问http://localhost:8004

![](/images/gitbook-start-server.png)

### 3. 导出
1. site
```bash
gitbook build ./repository -f site --output=./outputFolder
```
2. page
```bash
gitbook build ./repository -f page --output=./outputFolder
```
3. json
```bash
gitbook build ./repository -f json --output=./outputFolder
```
4. ebook
```bash
gitbook build ./repository -f ebook --output=./outputFolder
```
5. pdf
```bash
gitbook pdf ./repository -o file.pdf
```

# 参考
1. [书籍制作工具GITBOOK的安装](http://blog.liyibo.org/books-installation-authoring-tool-gitbook/)
2. [GitBook：使用Git+Markdown快速制作电子书](http://www.csdn.net/article/2014-04-09/2819217-gitbook-using-git-markdown-book)
3. [使用 Gitbook 寫一本書](http://blog.caesarchi.com/2014/05/gitbook.html)
