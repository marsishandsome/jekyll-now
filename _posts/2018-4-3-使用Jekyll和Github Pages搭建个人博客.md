---
layout: post
title: 使用Jekyll和Github Pages搭建个人博客
category: 未分类
---
我的个人博客最早使用的是WordPress，当时也没觉得麻烦，申请了一台带有固定IP的机器，申请了域名，在机器上安装WordPress、MySQL以及WordPress各种插件基本上就搞定了。后来Github推出了Github Pages用来免费托管静态页面并提供*.github.io域名，非常适合用来托管个人小型博客，于是就可以用Markdown来写文章，然后通过自己写的脚本生成静态站点，push到Github进行版本管理，最后用Github Pages托管站点，这是我之前个人站点的[源代码](https://github.com/marsishandsome/marsishandsome.github.com)。用自己的脚本生成静态站点灵活度不大，后来发现可以用Jekyll取代，Jekyll是Github的co-founder Tom Preston-Werner用Ruby开发的一款开源的静态站点生成器，适合用于生成个博客和项目主页。

# 系统搭建
1. fork https://github.com/barryclark/jekyll-now 并修改仓库名称
2. 编辑_config.yml, 配置Google Analytics, Disqus等信息
3. 在_posts目录下编辑2014-3-3-Hello-World.md
4. git commit & git push
5. 访问https://yourname.github.io

# 写文章流程
1. 启动jekyll serve，可以通过http://127.0.0.1:4000/ 访问
本地站点，有任何修改都会马上生效
2. 在_posts目录下面创建编辑Markdown文件
3. 用过http://127.0.0.1:4000/进行预览
4. git commit & git push
5. 访问https://yourname.github.io

# 推荐工具
1. atom用于Markdown文件编写
2. atom的Markdown Preview插件用于实时预览

# Jekyll
作为一款面向于个人博客和项目主页静态网页生成器，需要考虑以下几个问题：
1. 支持Markdown：写文章方便
2. 支持HTML，css和js：构建比较复杂的项目页面
3. 支持模板或者include语法：消除冗余代码
4. 支持日期、分类、标签和草稿功能：个人博客必备
5. 支持自定义页面：静态定制化页面
6. 支持静态资源：图片、PPT、PDF
7. 支持模板语言：构建动态页面，例如分类页面、标签页面
8. 支持插件：扩展功能，实现例如：Sitemap生成器、RSS生成器等
9. 提供的规则语法尽量简单规范，不能有太多自定义的隐藏规则

我们来看一下Jekyll是怎么解决这些问题的：

## 1) 支持Markdown：写文章方便
Jekyll支持将Markdown编译成html

## 2) 支持HTML，css和js：构建比较复杂的项目页面
Jekyll支持html,css和js编写网页

## 3) 支持模板或者include语法：消除冗余代码
Jekyll支持在html和markdown文件头部嵌入Front Matter，例如：

blog.md
```yaml
---
layout: post
title: Blogging Like a Hacker
---

# Title
This is a blog.
```

/\_layouts/post.html
{% raw %}
```html
<article class="post">
  <h1>{{ page.title }}</h1>

  <div class="entry">
    {{ content }}
  </div>
</article>
```
{% endraw %}

blog.md的内容最终会把嵌入到`content`，Jekyll通过这种方式实现冗余代码消除。

## 4) 支持日期、分类、标签和草稿功能：个人博客必备

### 日期
Jekyll通过文件名表示文章日期，例如/\_posts/2018-4-3-HelloWorld.md，通过.date属性可以访问日期，例如

/\_layouts/post.html

{% raw %}
```html
<div class="date">
  Written on {{ page.date | date: "%B %e, %Y" }}
</div>
```
{% endraw %}

Jekyll在Front Matter中预定义了`category`变量用来标识文章的分类
```yaml
---
layout: post
title: 使用Jekyll和Github Pages搭建个人博客
category: 未分类
---
```

### 分类
通过`site.categories`可以遍历所有的分类信息
{% raw %}
```html
{% for category in site.categories %}
<h2>
  <a href="{{ site.baseurl}}/category/{{ category.first }}.html">
    {{category.first}}（{{category.last.size}}）
  </a>
</h2>

<ul class="posts">
{% for post in category.last %}
  <li>
    <a href="{{ post.url | absolute_url }}">
      {{ post.title }}
    </a>
  </li>
{% endfor %}
</ul>

{% endfor %}
```
{% endraw %}

### 草稿
未发布的文章可以暂时存放到/\_drafts/目录，通过命令`jekyll build --drafts`可以预览草稿
```
|-- _drafts/
|   |-- a-draft-post.md
```

## 5) 支持自定义页面：静态定制化页面
用户可以在Jekyll预定义目录（/\_includes, /\_layouts/, /\_posts/, /\_site/）和文件（/\_config.yml, /index.html）以外添加任意的Markdown和HTML文件用来创建自定义页面，例如:
```
.
|-- about.html    # => http://example.com/about.html
|-- other
    └── contact.html  # => http://example.com/other/contact.html
```

## 6) 支持静态资源：图片、PPT、PDF
用户可以在Jekyll预定义目录（/\_includes, /\_layouts/, /\_posts/, /\_site/）和文件（/\_config.yml, /index.html）以外添加任意的非Markdown和HTML文件的静态资源，并且支持目录嵌套，例如:
```
.
|-- test.pdf    # => http://example.com/test.pdf
|-- other
    └── test2.jpg  # => http://example.com/other/test2.jpg
```

## 7) 支持模板语言：构建动态页面，例如分类页面、标签页面
Jekyll采用Liquid模板语言，下面的例子就是使用Liquid语言实现分类页面

{% raw %}
```html
<h1>分类</h1>
{% for category in site.categories %}

<h2>
  <a href="{{ site.baseurl}}/category/{{ category.first }}.html">
    {{category.first}}（{{category.last.size}}）
  </a>
</h2>

<ul class="posts">
{% for post in category.last %}
  <li>
    <a href="{{ post.url | absolute_url }}">
      {{ post.title }}
    </a>
  </li>
{% endfor %}
</ul>

{% endfor %}
```
{% endraw %}

## 8) 支持插件：扩展功能，实现例如：Sitemap生成器、RSS生成器等
在`_config.yml`配置文件中通过plugins或者gems配置插件
```
gems:
  - jekyll-sitemap # Create a sitemap using the official Jekyll sitemap gem
  - jekyll-feed # Create an Atom feed using the official Jekyll feed gem
```

# Liquid
Liquid是一款用Ruby实现的模板语言，最初是由加拿大电子商务软件开发商Shopify的Co-founder和CEO Tobias Lütke 开发的，目前已经[开源](https://shopify.github.io/liquid/)。

# 静态网站生成器
除了Jekyll外还有很多热门的开源静态站点生成器：
- [Hugo](gohugo.io): Go语言写的静态站点生成器
- [Hexo](hexo.io): NodeJS实现的静态站点生成器
- [GitBook](gitbook.com): 基于Git制作电子书
- [Octopress](octopress.org)
- [Gatsby](github.com/gatsbyjs)
- [Pelican](getpelican.com)
- [Brunch](brunch.io)
- [Metalsmith](metalsmith.io)
- [Middleman](middlemanapp.com)
- [Nuxt](nuxtjs.org)
- [MkDocs](mkdocs.org)
- [StaticGen](staticgen.com)

<!-- https://www.netlify.com/blog/2017/05/25/top-ten-static-site-generators-of-2017/ -->
