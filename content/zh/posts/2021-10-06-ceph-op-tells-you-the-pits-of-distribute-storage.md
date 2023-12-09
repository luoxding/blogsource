---
title: Ceph运维告诉你分布式存储的那些“坑”
author: starifly
date: 2021-10-06T20:00:04+08:00
lastmod: 2021-10-06T20:00:04+08:00
description: Ceph运维告诉你分布式存储的那些“坑”
categories: [ceph]
tags: [ceph]
draft: false
slug: ceph-op-tells-you-the-pits-of-distribute-storage
---

[Ceph运维告诉你分布式存储的那些“坑”](https://blog.csdn.net/liukuan73/article/details/114646644)

以Ceph、VSAN为代表的软件定义存储（Software Defined Storage，SDS）是一个横向扩展、自动均衡、自愈合的分布式存储系统，将商用x86服务器、固态硬盘、机械硬盘等硬件资源整合为一个瘦供给的资源池，并以块存储、文件存储、对象存储、Restful API等多种接口方式提供存储服务。

无论是Ceph、VSAN，或者其演化版本，都有一个共同的技术特征，即采用网络RAID方式实现数据保护，以3副本或纠删码为代表。其中3副本用于对小块数据读写性能有一定要求的应用场景，而纠删码则适用于视频数据、备份及归档等大文件场景。

以3副本为例，业务数据被分割为固定大小的数据块，通常为4MB，每个数据块在不同的节点上保存3个副本（如图1所示），其分布机制是依照一致性哈希算法（Consistent Hashing）或CRUSH算法，将各个副本数据随机分布在不同节点、不同磁盘中，以实现数据自动平衡和横向扩展。当磁盘或节点遭遇故障或损坏时，系统会自动根据预先设定的规则，重新建立一个新的数据副本，称之为数据重建。

虽然分布式存储的SDS理念很好，横向扩展能力不错，自动添加和删除节点都是优势，但与传统集中式存储（磁盘阵列）相比，其稳定性和性能仍然存在明显的短板。

首先，在性能方面，三副本分布式存储容易受到IO分布不均匀和木桶效应的影响，导致大延迟和响应迟钝的现象。以Ceph为例，多个存储基本单元，Placement Group （PG），封装为一个OSD，每个OSD直接对应于某一个机械硬盘HDD；主流的7200转HDD，受到机械臂寻址限制，其单盘的读写性能仅为120 IOPS左右；由于数据在OSD上随机分布，因而单个硬盘上的IO负载不会固定在平均值上，而是总体呈现为正态分布，少数HDD上因正态分布的尾部效应，导致其IO负载远超平均值，以及远超单盘的性能阀值，造成拥堵。此外，分布式存储为保证数据完整性，必须定时进行数据完整性校验，即数据scrub/deep-scrub操作，而这些操作产生额外的IO负载，可能会加重磁盘阻塞现象。根据木桶效应原理，系统的性能取决于集群中表现最差的磁盘，因此个别慢盘严重拖累整个系统的性能，其可能的后果，就是带来大延迟、OSD假死，以及触发数据非必需的重建。

其次，三副本分布式存储还面临稳定性问题。当存储扩容、硬盘或节点损坏、网络故障、OSD假死、 Deep-scrub等多种因素叠加，可能导致多个OSD同时重建，引发重建风暴。在数据重建过程中，重建任务不仅消耗系统的内存、CPU、网络资源，而且还给存储系统带来额外的IO工作负载，挤占用户工作负载的存储资源。在此情形下，用户时常观察到，系统IO延迟大，响应迟钝，轻者引起业务中断，严重时系统可能会陷入不稳定的状态，OSD反复死机重启，甚至会导致数据丢失，系统崩溃。

此外，三副本分布式存储还面临数据丢失的风险。三副本最大可抵御两个HDD同时损坏。当系统处于扩容状态、或一个节点处于维护模式时，此时出现一个HDD故障，则该系统就会进入紧急状态，出现两个HDD同时故障，则可能导致数据丢失。对于一个具有一定规模的存储系统而言，同时出现两个机械硬盘故障的事件不可避免，尤其是当系统运行两三年之后，随着硬件的老化，出现Double、或Triple磁盘故障的概率急剧上升。此外，当系统出现大规模掉电或存储节点意外宕机时，也可能会导致多个机械硬盘同时出现损坏，危及三副本分布式存储的数据安全。