---
title: "Mama"
date: 2023-12-09T20:40:04+08:00
draft: false
author: ""
categories: "Demo"
tags: ["unstar"]
thumbnail: ""
headline: 
    enabled: false
    background: ""
---

目前最新版是 118.0.2088.69 (正式版本) (64 位)，你可以更新一下，然后就应该有了。

特地找了几台空闲服务器（Dell R720），设备支持2个CPU和N多内存，可以插8块硬盘。

重新安装了Linux系统（Ubuntu），做了磁盘整列Raid，和Samba共享配置这一套，理论上后面添加新硬盘，直接加挂载配置即可。

<!--more--> 

由此可得到如下文件目录：

```text
personal-site
├── archetypes
├── config.toml
├── content
├── data
├── layouts
├── static
└── themes
```

常用目录用处如下

| 子目录名称 | 功能 |  
| ------------ | ---------------------------------------------------------------------- |  
| archetypes | 新文章默认模板 |  
| config.toml | `Hugo`配置文档 |  
| content | 存放所有`Markdown`格式的文章 |  
| layouts | 存放自定义的`view`，可为空 |  
| static | 存放图像、CNAME、css、js等资源，发布后该目录下所有资源将处于网页根目录 |  
| themes | 存放下载的主题 |

使用下面的命令生成新的文章草稿：

```text
hugo new posts/first-post.md

<!-- more -->
```

在content目录中会自动以`archetypes/default.md`为模板在`content/posts`目录下生成一篇名为`first-post.md`的文章草稿：

```text
---
title: "First Post"
date: 2017-12-27T23:15:53-05:00
draft: true #draft: false
---
```

我们可以加一个标题在下面并去掉标记为草稿的这一行：`draft: true`
