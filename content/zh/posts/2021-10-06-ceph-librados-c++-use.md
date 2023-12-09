---
title: ceph librados库c++使用
author: starifly
date: 2021-10-06T16:51:53+08:00
lastmod: 2021-10-06T16:51:53+08:00
categories: [ceph]
tags: [ceph,librados]
draft: false
slug: ceph-librados-c++-use
---


## 依赖

```bash
# centos
yum install librados2-devel
```

## 源程序

```c
#include <iostream>
#include <string>
#include <rados/librados.hpp>

int main(int argc, const char **argv)
{

        int ret = 0;

        /* Declare the cluster handle and required variables. */
        librados::Rados cluster;
        char cluster_name[] = "ceph";
        char user_name[] = "client.admin";
        uint64_t flags = 0;

        /* Initialize the cluster handle with the "ceph" cluster name and "client.admin" user */
        {
                ret = cluster.init2(user_name, cluster_name, flags);
                if (ret < 0) {
                        std::cerr << "Couldn't initialize the cluster handle! error " << ret << std::endl;
                        return EXIT_FAILURE;
                } else {
                        std::cout << "Created a cluster handle." << std::endl;
                }
        }

        /* Read a Ceph configuration file to configure the cluster handle. */
        {
                ret = cluster.conf_read_file("/etc/ceph/ceph.conf");
                if (ret < 0) {
                        std::cerr << "Couldn't read the Ceph configuration file! error " << ret << std::endl;
                        return EXIT_FAILURE;
                } else {
                        std::cout << "Read the Ceph configuration file." << std::endl;
                }
        }

        /* Read command line arguments */
        {
                ret = cluster.conf_parse_argv(argc, argv);
                if (ret < 0) {
                        std::cerr << "Couldn't parse command line options! error " << ret << std::endl;
                        return EXIT_FAILURE;
                } else {
                        std::cout << "Parsed command line options." << std::endl;
                }
        }

        /* Connect to the cluster */
        {
                ret = cluster.connect();
                if (ret < 0) {
                        std::cerr << "Couldn't connect to cluster! error " << ret << std::endl;
                        return EXIT_FAILURE;
                } else {
                        std::cout << "Connected to the cluster." << std::endl;
                }
        }

	librados::IoCtx io_ctx;
        const char *pool_name = "testpool";

        {
                ret = cluster.ioctx_create(pool_name, io_ctx);
                if (ret < 0) {
                        std::cerr << "Couldn't set up ioctx! error " << ret << std::endl;
                        exit(EXIT_FAILURE);
                } else {
                        std::cout << "Created an ioctx for the pool." << std::endl;
                }
        }


        /* Write an object synchronously. */
        {
                librados::bufferlist bl;
                bl.append("Hello World!");
                ret = io_ctx.write_full("hw", bl);
                if (ret < 0) {
                        std::cerr << "Couldn't write object! error " << ret << std::endl;
                        exit(EXIT_FAILURE);
                } else {
                        std::cout << "Wrote new object 'hw' " << std::endl;
                }
        }


        /*
         * Add an xattr to the object.
         */
        {
                librados::bufferlist lang_bl;
                lang_bl.append("en_US");
                ret = io_ctx.setxattr("hw", "lang", lang_bl);
                if (ret < 0) {
                        std::cerr << "failed to set xattr version entry! error "
                        << ret << std::endl;
                        exit(EXIT_FAILURE);
                } else {
                        std::cout << "Set the xattr 'lang' on our object!" << std::endl;
                }
        }


        /*
         * Read the object back asynchronously.
         */
        {
                librados::bufferlist read_buf;
                int read_len = 4194304;

                //Create I/O Completion.
                librados::AioCompletion *read_completion = librados::Rados::aio_create_completion();

                //Send read request.
                ret = io_ctx.aio_read("hw", read_completion, &read_buf, read_len, 0);
                if (ret < 0) {
                        std::cerr << "Couldn't start read object! error " << ret << std::endl;
                        exit(EXIT_FAILURE);
                }

                // Wait for the request to complete, and check that it succeeded.
                read_completion->wait_for_complete();
                ret = read_completion->get_return_value();
                if (ret < 0) {
                        std::cerr << "Couldn't read object! error " << ret << std::endl;
                        exit(EXIT_FAILURE);
                } else {
                        std::cout << "Read object hw asynchronously with contents.\n"
                        << read_buf.c_str() << std::endl;
                }
        }


        /*
         * Read the xattr.
         */
        {
                librados::bufferlist lang_res;
                ret = io_ctx.getxattr("hw", "lang", lang_res);
                if (ret < 0) {
                        std::cerr << "failed to get xattr version entry! error "
                        << ret << std::endl;
                        exit(EXIT_FAILURE);
                } else {
                        std::cout << "Got the xattr 'lang' from object hw!"
                        << lang_res.c_str() << std::endl;
                }
        }


        /*
         * Remove the xattr.
         */
        {
                ret = io_ctx.rmxattr("hw", "lang");
                if (ret < 0) {
                        std::cerr << "Failed to remove xattr! error "
                        << ret << std::endl;
                        exit(EXIT_FAILURE);
                } else {
                        std::cout << "Removed the xattr 'lang' from our object!" << std::endl;
                }
        }

        /*
         * Remove the object.
         */
        {
                ret = io_ctx.remove("hw");
                if (ret < 0) {
                        std::cerr << "Couldn't remove object! error " << ret << std::endl;
                        exit(EXIT_FAILURE);
                } else {
                        std::cout << "Removed object 'hw'." << std::endl;
                }
        }
	
	io_ctx.close();
	cluster.shutdown();

        return 0;
}
```

## 编译

```bash
g++ -g -c cephclient.cc -o cephclient.o -std=c++11
g++ -g cephclient.o -lrados -o cephclient
```

## 运行

注意运行前要先创建“testpool”存储池

```bash
[root@203 ~]# ./cephclient 
Created a cluster handle.
Read the Ceph configuration file.
Parsed command line options.
Connected to the cluster.
Created an ioctx for the pool.
Wrote new object 'hw' 
Set the xattr 'lang' on our object!
Read object hw asynchronously with contents.
Hello World!
Got the xattr 'lang' from object hw!en_US
Removed the xattr 'lang' from our object!
Removed object 'hw'.
```

## Reference

- [Introduction to librados](https://docs.ceph.com/en/latest/rados/api/librados-intro/)
- [librados/c++/N版](https://www.jianshu.com/p/31e83854be28)
