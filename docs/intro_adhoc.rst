Introduction To Ad-Hoc Commands
===============================

.. contents:: Topics

.. highlight:: bash


在下面的例子中,我们将演示如何使用 `/usr/bin/ansible` 运行 ad hoc 任务.

所谓 ad-hoc 命令是什么呢?

(这其实是一个概念性的名字,是相对于写 Ansible playbook 来说的.类似于在命令行敲入shell命令和
写shell scripts两者之间的关系)...

如果我们敲入一些命令去比较快的完成一些事情,而不需要将这些执行的命令特别保存下来,
这样的命令就叫做 ad-hoc 命令.

Ansible提供两种方式去完成任务,一是 ad-hoc 命令,一是写 Ansible playbook.前者可以解决一些简单的任务,
后者解决较复杂的任务.

一般而言,在学习了 playbooks 之后,你才能体会到 Ansible 真正的强大之处在哪里.

那我们会在什么情境下去使用ad-hoc 命令呢?

比如说因为圣诞节要来了,想要把所有实验室的电源关闭,我们只需要执行一行命令
就可以达成这个任务,而不需要写 playbook 来做这个任务.

至于说做配置管理或部署这种事,还是要借助 playbook 来完成,即使用 '/usr/bin/ansible-playbook' 这个命令.

(关于 playbook 的使用,请参考  :doc:`playbooks` )

如果你还没有阅读 :doc:`intro_inventory` ,最好先看一看,然后我们继续往下.


.. _parallelism_and_shell_commands:

Parallelism and Shell Commands
````````````````````````````````

举一个例子

这里我们要使用 Ansible 的命令行工具来重启 Atlanta 组中所有的 web 服务器,每次重启10个.

我们先设置 SSH-agent,将私钥纳入其管理::

    $ ssh-agent bash
    $ ssh-add ~/.ssh/id_rsa

如果不想使用 ssh-agent, 想通过密码验证的方式使用 SSH,可以在执行ansible命令时使用 ``--ask-pass`` (``-k``)选项,
但这里建议使用 ssh-agent.

	
现在执行如下命令,这个命令中,atlanta是一个组,这个组里面有很多服务器,"/sbin/reboot"命令会在atlanta组下
的所有机器上执行.这里ssh-agent会fork出10个子进程(bash),以并行的方式执行reboot命令.如前所说“每次重启10个”
即是以这种方式实现::

    $ ansible atlanta -a "/sbin/reboot" -f 10

在执行 /usr/bin/ansible 时,默认是以当前用户的身份去执行这个命令.如果想以指定的用户执行 /usr/bin/ansible,
请添加 "-u username"选项,如下::

    $ ansible atlanta -a "/usr/bin/foo" -u username

如果想通过 sudo 去执行命令,如下::

    $ ansible atlanta -a "/usr/bin/foo" -u username --sudo [--ask-sudo-pass]

如果你不是以 passwordless 的模式执行 sudo,应加上 ``--ask-sudo-pass`` (``-K``)选项,加上之后会提示你输入
密码.使用 passwordless 模式的 sudo, 更容易实现自动化,但不要求一定要使用 passwordless sudo.

也可以通过``--sudo-user`` (``-U``)选项,使用 sudo 切换到其它用户身份,而不是 root(译者注:下面命令中好像写掉了--sudo)::

    $ ansible atlanta -a "/usr/bin/foo" -u username -U otheruser [--ask-sudo-pass]


.. note::

    在有些比较罕见的情况下,一些用户会受到安全规则的限制,使用 sudo 切换时只能运行指定的命令.这与 ansible的 no-bootstrapping 思想相悖,而且 ansible 有几百个模块,在这种限制下无法进行正常的工作.
    所以执行 ansible 命令时,应使用一个没有受到这种限制的账号来执行.One way of doing this without sharing access to unauthorized users would be gating Ansible with :doc:`tower`, which
    can hold on to an SSH credential and let members of certain organizations use it on their behalf without having direct access.

以上是关于 ansible 的基础.如果你还没阅读过 patterns 和 groups,应先阅读 :doc:`intro_patterns` .

在前面写出的命令中, ``-f 10`` 选项表示使用10个并行的进程.这个选项也可以在 :doc:`intro_configuration` 中设置,
在配置文件中指定的话,就不用在命令行中写出了.这个选项的默认值是 5,是比较小的.如果同时操作的主机数比较多的话,
可以调整到一个更大的值,只要不超出你系统的承受范围就没问题.如果主机数大于设置的并发进程数,Ansible会自行协调,
花得时间会更长一点.

ansible有许多模块,默认是 'command',也就是命令模块,我们可以通过 ``-m`` 选项来指定不同的模块.在前面所示的例子中,
因为我们是要在 Atlanta 组下的服务器中执行 reboot 命令,所以就不需要显示的用这个选项指定 'command' 模块,使用
默认设定就OK了.一会在其他例子中,我们会使用 ``-m`` 运行其他的模块,详情参见 :doc:`modules` .

.. note::

    :ref:`command` 模块不支持 shell 变量,也不支持管道等 shell 相关的东西.如果你想使用 shell相关的这些东西, 请使用'shell' 模块.两个模块之前的差别请参考 :doc:`modules` .

使用 :ref:`shell` 模块的示例如下::

    $ ansible raleigh -m shell -a 'echo $TERM'

使用 Ansible *ad hoc* 命令行接口时(与使用 :doc:`Playbooks <playbooks>` 的情况相反),尤其注意 shell 引号的规则.
比如在上面的例子中,如果使用双引号"echo $TERM",会求出TERM变量在当前系统的值,而我们实际希望的是把这个命令传递
到其它机器执行.

在此我们已经演示了一些简单命令如何去执行,但通常来讲大多数 Ansible 模块的工作方式与简单的脚本不同.They make the remote 
system look like you state, and run the commands necessary to get it there.这一般被称为 'idempotence',
是 Ansible 设计的核心目标.但我们也认识到,能运行任意命令也是重要的,所以 Ansible 对这两者都做支持.

.. _file_transfer:

File Transfer
```````````````

这是 `/usr/bin/ansible` 的另一种用法.Ansible 能够以并行的方式同时 SCP 大量的文件到多台机器.
命令如下::

    $ ansible atlanta -m copy -a "src=/etc/hosts dest=/tmp/hosts"

若你使用 playbooks, 则可以利用 ``template`` 模块来做到更进一步的事情.(请参见 module 和 playbook 的文档)

使用 ``file`` 模块可以做到修改文件的属主和权限,(在这里可替换为 ``copy`` 模块,是等效的)::

    $ ansible webservers -m file -a "dest=/srv/foo/a.txt mode=600"
    $ ansible webservers -m file -a "dest=/srv/foo/b.txt mode=600 owner=mdehaan group=mdehaan"

使用 ``file`` 模块也可以创建目录,与执行 ``mkdir -p`` 效果类似::

    $ ansible webservers -m file -a "dest=/path/to/c mode=755 owner=mdehaan group=mdehaan state=directory"

删除目录(递归的删除)和删除文件::

    $ ansible webservers -m file -a "dest=/path/to/c state=absent"


.. _managing_packages:

Managing Packages
```````````````````

Ansible 提供对 yum 和 apt 的支持.这里是关于 yum 的示例.

确认一个软件包已经安装,但不去升级它::

    $ ansible webservers -m yum -a "name=acme state=present"

确认一个软件包的安装版本::

    $ ansible webservers -m yum -a "name=acme-1.5 state=present"

确认一个软件包还没有安装::

    $ ansible webservers -m yum -a "name=acme state=absent"

对于不同平台的软件包管理工具,Ansible都有对应的模块.如果没有,你也可以使用 command 模块去安装软件.
或者最好是来为那个软件包管理工具贡献一个相应的模块.请在 mailing list 中查看相关的信息和详情.

.. _users_and_groups:

Users and Groups
``````````````````

使用 'user' 模块可以方便的创建账户,删除账户,或是管理现有的账户::

    $ ansible all -m user -a "name=foo password=<crypted password here>"

    $ ansible all -m user -a "name=foo state=absent"

更多可用的选项请参考 :doc:`modules` ,包括对组和组成员关系的操作.

.. _from_source_control:

Deploying From Source Control
```````````````````````````````

直接使用 git 部署 webapp::

    $ ansible webservers -m git -a "repo=git://foo.example.org/repo.git dest=/srv/myapp version=HEAD"

因为Ansible 模块可通知到 change handlers ,所以当源码被更新时,我们可以告知 Ansible 这个信息,并执行指定的任务,
比如直接通过 git 部署 Perl/Python/PHP/Ruby, 部署完成后重启 apache.

.. _managing_services:

Managing Services
```````````````````
	
确认某个服务在所有的webservers上都已经启动::

    $ ansible webservers -m service -a "name=httpd state=started"

或是在所有的webservers上重启某个服务(译者注:可能是确认已重启的状态?)::

    $ ansible webservers -m service -a "name=httpd state=restarted"

确认某个服务已经停止::

    $ ansible webservers -m service -a "name=httpd state=stopped"


.. _time_limited_background_operations:

Time Limited Background Operations
````````````````````````````````````

需要长时间运行的命令可以放到后台去,在命令开始运行后我们也可以检查运行的状态.如果运行命令后,不想获取返回的信息,
可执行如下命令::

    $ ansible all -B 3600 -P 0 -a "/usr/bin/long_running_operation --do-stuff"

如果你确定要在命令运行后检查运行的状态,可以使用 async_status 模块.前面执行后台命令后会返回一个 job id, 
将这个 id 传给 async_status 模块::

    $ ansible web1.example.com -m async_status -a "jid=488359678239.2844"

获取状态的命令如下::

    $ ansible all -B 1800 -P 60 -a "/usr/bin/long_running_operation --do-stuff"

其中 ``-B 1800`` 表示最多运行30分钟, ``-P 60`` 表示每隔60秒获取一次状态信息.

Polling 获取状态信息的操作会在后台工作任务启动之后开始.若你希望所有的工作任务快速启动, ``--forks`` 这个选项的值
要设置得足够大,这是前面讲过的并发进程的个数.在运行指定的时间(由``-B``选项所指定)后,远程节点上的任务进程便会被终止.

一般你只能在把需要长时间运行的命令或是软件升级这样的任务放到后台去执行.对于 copy 模块来说,即使按照前面的示例想放到
后台执行文件传输,实际上并不会如你所愿.

.. _checking_facts:

Gathering Facts
`````````````````

在 playbooks 中有对于 Facts 做描述,它代表的是一个系统中已发现的变量.These can be used to implement conditional execution 
of tasks but also just to get ad-hoc information about your system. 可通过如下方式查看所有的 facts::

    $ ansible all -m setup

我们也可以对这个命令的输出做过滤,只输出特定的一些 facts,详情请参考 "setup" 模块的文档.

如果你已准备好仔细研究 :doc:`Playbooks <playbooks>` ,可以继续读读 :doc:`playbooks_variables` ,会对 facts有更多了解.

.. seealso::

   :doc:`intro_configuration`
       All about the Ansible config file
   :doc:`modules`
       A list of available modules
   :doc:`playbooks`
       Using Ansible for configuration management & deployment
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel
