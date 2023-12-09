---
title: "Demo"
date: 2023-12-09T16:16:47+08:00
draft: false
author: ""
categories: "TeX"
tags: 
- test
- demo
- example
toc: true
thumbnail: ""
headline: 
    enabled: false
    background: ""
---

# latex笔记

表格整体相关设置【表名及位置、表宽、注解、字号】

很多时候，我们都是对表格整体进行相关设置，来达到自己的相关需求。而对表格整体的相关设置其实与表格内容并无太大关系。

因此我们需要在表格内容环境【如上文中的 **\begin{tabular}、\begin{longtable}** 】外面进行相关环境设置。

<!--more--> 

## 跨页三线表

跨页表格需要导入宏包 ==longtable==，并将原来的表格内容环境==tabular==改成==longtable==即可。

示例代码：

```tex
\documentclass{article}
\usepackage{booktabs} % 导入三线表需要的宏包
\usepackage{longtable}% 导入跨页表格所需宏包
\begin{document}

\begin{longtable}{ccc}% 其中，tabular是表格内容的环境；c表示centering，即文本格式居中；c的个数代表列的个数
\toprule %[2pt]设置线宽     
a & b  &  c \\ %换行
\midrule %[2pt]  
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9 \\
\bottomrule %[2pt]     
\end{longtable}

\end{document}
```

Content.