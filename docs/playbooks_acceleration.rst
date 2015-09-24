Accelerated Mode
================

.. versionadded:: 1.3

你也许不需要这个！
````````````````````````


你在使用 Ansible 1.5 或者 之后的版本吗？ 如果是的话,因为被称之为 "SSH pipelining" 的新特性,你也许就不需要加速模式了.详情请阅读:ref:`pipelining` 部分的章节.

对于使用 1.5 及之后版本的用户,加速模式只在以下情况下有用处: (A) 管理红帽企业版 Linux 6 或者更早的那些依然使用 paramiko 的版本 或者 (B) 像在文档中描述的那样:无法在 TTYs 中使用 sudo.

如果你能够使用pipelining,Ansible 将会降低通过 wire 传输文件的总量来提升有效率,并且在几乎所有情况下（甚至可能包括了传输大型文件）都能与加速模式相匹敌.归功于更少的移动文件块,管道几乎在所有的情况下优于加速模式.

加速模式将为了支持那些仍使用红帽企业版 Linux 6 做主控机或因其他环境因素受限制而保留.

加速模式详解
````````````````````````

尽管 OpenSSH 使用的 ControlPersist 特性既快速又可伸缩,但这会在 SSH 连接时造成少量的开销.虽然很多人不会遇到这样一个需求,但是如果你当前运行的平台不支持 ControlPersist (如 一台 EL6 control machine),
你大概会对 tuning 选项更感兴趣.

加速模式只是使用来加速连接的,它仍需使用 SSH 来进行初始安全密钥交换.它没有额外增加需要管理的基础设施的公共key,也不需要诸如 NTP 或 DNS.

加速模式在任何情况下将比启用 ControlPersist 特性的 SSH 快2-6倍,10倍于 paramiko.

加速模式通过启动一个临时的 SSH 守护进程来工作.只要这个守护进程在运行,Ansible 将会直接通过 socket 来连接.Ansible 通过在连接时交换临时的 AES key 来确保安全(这个秘钥对每个主机都是不同的并且会定期重新生成).


默认配置下,Ansible 会为加速模式开启5099端口(此配置可修改).一旦运行了,守护进程将会维持连接 30 分钟,过了时限后该连接将会自动终结,你需要重启一个 SSH.


加速模式对它所基于的 fireball 模式(已被废弃)做了许多改进:

* 不需要 bootstrapping,仅需在你想要运行加速模式的playbook上添加一行代码.
* 支持 sudo 命令(下文参见详情)
* 更少的依赖需求.ZeroMQ 不在需要,除了 python-keyczar 外再无其他依赖包需要安装.
* Python 版本必须大于等于 2.5


只需在你的 play 中添加 `accelerate: true` 即可使用加速模式::

    ---

    - hosts: all
      accelerate: true

      tasks:

      - name: some task
        command: echo {{ item }}
        with_items:
        - foo
        - bar
        - baz


如果你希望改变 Ansible 用于加速模式的端口,你只需添加 `accelerated_port` 选项::

    ---

    - hosts: all
      accelerate: true
      # default port is 5099
      accelerate_port: 10000

`accelerate_port` 选项也同样能通过指定环境变量 ACCELERATE_PORT 或者在你的 `ansible.cfg` 中配置::

    [accelerate]
    accelerate_port = 5099


如先前所述,加速模式同样支持通过 sudo 命令来运行任务.但是有两点需要予以提醒:


* 你必须移除 sudoers 选项中的 requiretty.
* 目前仍不支持 sudo 密码提示,所以 NOPASSWD 选项是必须的.


如果是 Ansible 版本是 `1.6`,你同样可以允许多个连接多个秘钥来连接多个 Ansible 管理节点.你可以通过在你的 `ansible.cfg` 中添加如下配置::

    accelerate_multi_key = yes

当启用时,守护进程将会打开一个 UNIX socket 文件(默认位于 `$ANSIBLE_REMOTE_TEMP/.ansible-accelerate/.local.socket`).来自 SSH 的新的连接能够通过这个 socket 文件来上载新的秘钥给守护进程.