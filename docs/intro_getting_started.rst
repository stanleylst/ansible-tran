新手上路
===============

.. contents:: Topics

.. _gs_about:

前言
````````

现在你已经阅读了 :doc:`intro_installation` 安装指南并安装了Ansible.是时候通过一些命令开始深入了解Ansible了.

我们最先展示的并非那强大的集配置,部署,自动化于一身的playbook.
Playbooks 相关内容将在另一章节中讲述.

本章节讲述如何进行初始化.一旦你有了这些概念,请去阅读 :doc:`intro_adhoc` 以获取更多细节,然后你就能去深入playbook并探索它最有趣的部分.

.. _remote_connection_information:

远程连接概述

`````````````````````````````

在我们开始前要先理解Ansible是如何通过SSH与远程服务器连接是很重要的.

Ansible 1.3及之后的版本默认会在本地的 OpenSSH可用时会尝试用其进行远程通讯.这会启用ControlPersist(一个性能特性),Kerberos,和在~/.ssh/config中的配置选项如 Jump Host setup.然而,当你使用Linux企业版6作为主控机(红帽企业版及其衍生版如CentOS),其OpenSSH版本可能过于老旧无法支持ControlPersist.
在这些操作系统中,Ansible将会退回并采用 paramiko (由Python实现的高质量OpenSSH库).
如果你希望能够使用像是Kerberized SSH之类的特性,烦请考虑使用Fedora, OS X, 或 Ubuntu 作为你的主控机直到相关平台上有更新版本的OpenSSH可供使用,或者启用Ansible的“accelerated mode”.参见 :doc:`playbooks_acceleration`.

在Ansible 1.2 及之前的版本,默认将会使用 paramiko. 本地OpenSSH必须通过-c ssh 或者 在配置文件中设定.

你偶尔会遇到不支持SFTP的设备.虽然这很少见,但你会有概率中奖.你可以通过在配置文件(:doc:`intro_configuration`)中切换至 SCP模式来与之链接.

说起远程设备,Ansible会默认假定你使用 SSH Key(我们推荐这种)但是密码也一样可以.通过在需要的地方添加 --ask-pass选项 来启用密码验证.如果使用了sudo 特性,当sudo需要密码时,也同样适当的提供了--ask-sudo-pass选项.

也许这是常识,但也值得分享:任何管理系统受益于被管理的机器在主控机附近运行.如果在云中运行,可以考虑在使用云中的一台机器来运行Ansible.

作为一个进阶话题,Ansible不止支持SSH来远程连接.连接方式是插件化的而且还有许多本地化管理的选项诸如管理 chroot, lxc, 和 jail containers.一个叫做‘ansible-pull’的模式能够反转主控关系并使远程系统通过定期从中央git目录检出 并 拉取 配置指令来实现背景连接通信.

.. _你的_第一条_命令:

你的第一条命令
```````````````````

现在你已经安装了Ansible,是时候从一些基本知识开始了.
编辑(或创建)/etc/ansible/hosts 并在其中加入一个或多个远程系统.你的public SSH key必须在这些系统的``authorized_keys``中::

    192.168.1.50
    aserver.example.org
    bserver.example.org

这里有个节点设置文件(inventory file)将会在 :doc:`intro_inventory` 中得到深入说明.
我们假定你使用SSH Key来授权.为了避免在建立SSH连接时,重复输入密码你可以这么
做:

.. code-block:: bash

    $ ssh-agent bash
    $ ssh-add ~/.ssh/id_rsa

(根据你的建立方式,你也许希望使用Ansible的 ``--private-key`` 选项,通过指定pem文件来代替SSH Key来授权)
现在ping 你的所有节点:

.. code-block:: bash

   $ ansible all -m ping

Ansible会像SSH那样试图用你的当前用户名来连接你的远程机器.要覆写远程用户名,只需使用'-u'参数.
如果你想访问 sudo模式,这里也有标识(flags)来实现:

.. code-block:: bash

    # as bruce
    $ ansible all -m ping -u bruce
    # as bruce, sudoing to root
    $ ansible all -m ping -u bruce --sudo
    # as bruce, sudoing to batman
    $ ansible all -m ping -u bruce --sudo --sudo-user batman

(如果你碰巧想要使用其他sudo的实现方式,你可以通过修改Ansible的配置文件来实现.也可以通过传递标识给sudo(如-H)来设置.)
现在对你的所有节点运行一个命令:

.. code-block:: bash

   $ ansible all -a "/bin/echo hello"

恭喜你！你刚刚通过Ansible连接了你的所有节点.很快你就会阅读更多的关于现实案例 :doc:`intro_adhoc` 并探索可以通过不同的模块做什么以及研究Ansible的playbook语言

:doc:`playbooks` .Ansible不只是能运行命令,它同样也拥有强大的配置管理和部署特性.虽然还有更多内容等待你的探索,但你基础设施已经能完全工作了！

.. _a_note_about_host_key_checking:

公钥认证
`````````````````

Ansible1.2.1及其之后的版本都会默认启用公钥认证.

如果有个主机重新安装并在“known_hosts”中有了不同的key,这会提示一个错误信息直到被纠正为止.在使用Ansible时,你可能不想遇到这样的情况:如果有个主机没有在“known_hosts”中被初始化将会导致在交互使用Ansible或定时执行Ansible时对key信息的确认提示.

如果你想禁用此项行为并明白其含义,你能够通过编辑 /etc/ansible/ansible.cfg or ~/.ansible.cfg来实现::

    [defaults]
    host_key_checking = False

或者你也可以通过设置环境变量来实现:

.. code-block:: bash

    $ export ANSIBLE_HOST_KEY_CHECKING=False

同样注意在paramiko 模式中 公钥认证 相当的慢.因此,当使用这项特性时,切换至'SSH'是推荐做法.

.. _a_note_about_logging:

Ansible将会对远程系统模块参数记录在远程的syslog中,除非一个任务或者play被标记了“no_log: True”属性,稍后解释.
在主控机上启用基本的日志功能参见 :doc:`intro_configuration` 文档 并 在配置文件中设置'log_path'.企业用户可能也对 :doc:`tower` 感兴趣.

塔提供了非常实用数据库日志.它使一次次向下钻取并查看基于主机,项目,和特定的结果集成为可能———— 同时提供了图形和 RESTful API.


.. seealso::

   :doc:`intro_inventory`
       More information about inventory
   :doc:`intro_adhoc`
       Examples of basic commands
   :doc:`playbooks`
       Learning Ansible's configuration management language
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

