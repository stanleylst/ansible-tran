Ansible Galaxy
++++++++++++++

"Ansible Galaxy" 指的是一个网站共享和下载 Ansible 角色,也可以是者是帮助 roles 更好的工作的命令行工具。

.. 内容:: 主题

The Website
网站
```````````

这个网站 `Ansible Galaxy <https://galaxy.ansible.com>`_，是一个免费的用于查找，下载，评论各种社区开发的 Ansible 角色，在你的自动化项目中引入一些角色也是不错的。

你可以使用 social auth 注册和使用 "ansible-galaxy" 下载客户端，"ansible-galaxy"在 Ansible 1.4.2 就已经被包含了。

阅读 Galaxy 网站的 "About" 页面获取更多信息。

ansible-galaxy命令行工具
````````````````````````````````````

ansible-galaxy 有许多不同的子命令

安装角色
----------------

很明显从 Ansible Galaxy 网站下载角色

   ansible-galaxy install username.rolename

构建角色架构
-----------------------------

也可以用于初始化一个新角色的基本文件结构，节省创建不同的目录和main.yml的时间了。

   ansible-galaxy init rolename

从一个文件安装多个角色
-------------------------------------

想安装多个角色，ansible-galaxy 命令行可以通过一个 requirements 文件实现。各种版本的ansible 都允许使用下面的语法从 Ansible galaxy 网站安装角色。

   ansible-galaxy install -r requirements.txt

requirements.txt 文件看起来就像这样

   username1.foo_role
   username2.bar_role

想得到指定版本(tag)的role，使用下面的语法

   username1.foo_role,version
   username2.bar_role,version

可用的版本在 Ansible Galaxy 网页上都有列出来。

Requirements 文件高级用法 
---------------------------------------------

一些控制从哪里下载角色，支持远程源的用法，在 Ansible 1.8 之后支持通过 YMAL 语法的 requirements 文件实现，但是必须以 yml为文件扩展名。就像这样

    ansible-galaxy install -r requirements.yml

扩展名是很重要的，如果 .yml 扩展忘记写了， ansible-galaxy 命令行会假设这个文件是普通格式的，而且会失败，

这里有个例子展示通过多个源下载一些指定版本。 其中也实现了覆盖下载角色的名字到其它名字。

    # from galaxy
    - src: yatesr.timezone

    # from github
    - src: https://github.com/bennojoy/nginx

    # from github installing to a relative path
    - src: https://github.com/bennojoy/nginx
      path: vagrant/roles/

    # from github, overriding the name and specifying a specific tag
    - src: https://github.com/bennojoy/nginx
      version: master
      name: nginx_role
    
    # from a webserver, where the role is packaged in a tar.gz
    - src: https://some.webserver.example.com/files/master.tar.gz
      name: http-role

    # from bitbucket, if bitbucket happens to be operational right now :)
    - src: git+http://bitbucket.org/willthames/git-ansible-galaxy
      version: v1.4

    # from bitbucket, alternative syntax and caveats
    - src: http://bitbucket.org/willthames/hg-ansible-galaxy
      scm: hg

从上面你可以看到，有许多控制命令可以使用去自定义那些角色从哪里获得，保存为什么角色名称。

Roles pulled from galaxy work as with other SCM sourced roles above. To download a role with dependencies, and automatically install those dependencies, the role must be uploaded to the Ansible Galaxy website.
有些角色之间会有依赖关系，想要从依赖关系中自动安装，这个角色需要被上传到 Ansible Galaxy 网站上。

.. seealso::

   :doc:`playbooks_roles`
       关于 Ansible role 的内容
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

