---
title: linux tar压缩排除某个文件夹
author: starifly
date: 2019-10-26T22:02:43+08:00
categories: [linux]
tags: [linux,tar]
draft: true
slug: linux-tarball-excludes-a-folder
---

一般直接用tar命令打包很简单，直接使用 `tar -czvf test.tar.gz test` 即可。

在很多时候，我们要对某一个目录打包，而这个目录下有几十个子目录和子文件，我们需要在打包的时候排除其中1、2个目录或文件。

这时候我们在用tar命令打包的时候，增加参数 --exclude 就能达到目的。

例如：

我们以 tomcat 为例，打包的时候我们要排除 tomcat/logs 目录，命令如下：

`tar -zcvf tomcat.tar.gz --exclude=tomcat/logs tomcat`

如果要排除多个目录，增加 --exclude 即可，如下命令排除logs和libs两个目录及文件xiaoshan.txt：  
`tar -zcvf tomcat.tar.gz --exclude=tomcat/logs --exclude=tomcat/libs --exclude=tomcat/xiaoshan.txt tomcat`

这里要说一下注意事项：

大家都知道 linux 在使用tab键的时候会对目录名称自动补全，这很方便，大家也比较常用。

如我们输入 tomcat/lo 的时候按tab键，命令行会自动生成 tomcat/logs/ ，对于目录，最后会多一个 “/”

这里大家要注意的时候，在我们使用tar 的--exclude 命令排除打包的时候，不能加“/”，否则还是会把logs目录以及其下的文件打包进去。

    错误写法：
    tar -zcvf tomcat.tar.gz --exclude=tomcat/logs/ --exclude=tomcat/libs/ tomcat

    正确写法：
    tar -zcvf tomcat.tar.gz --exclude=tomcat/logs --exclude=tomcat/libs tomcat
