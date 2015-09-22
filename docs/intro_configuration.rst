Ansible的配置文件
++++++++++++++++++

.. contents:: Topics

.. highlight:: bash

Ansible的一些的设置可以通过配置文件完成.在大多数场景下默认的配置就能满足大多数用户的需求,在一些特殊场景下,用户还是需要自行修改这些配置文件 

用户可以修改一下配置文件来修改设置,他们的被读取的顺序如下::

    * ANSIBLE_CONFIG (一个环境变量)
    * ansible.cfg (位于当前目录中)
    * .ansible.cfg (位于家目录中)
    * /etc/ansible/ansible.cfg

版本1.5之前的读取顺序如下::

    * ansible.cfg (位于当前目录)
    * ANSIBLE_CONFIG (一个环境变量)
    * .ansible.cfg (位于家目录下)
    * /etc/ansible/ansible.cfg

Ansible 将会按以上顺序逐个查询这些文件,直到找到一个为止,并且使用第一个寻找到个配置文件的配置,这些配置将不会被叠加. 

.. _getting_the_latest_configuration:

获取最新配置文件
````````````````````````


如果使用程序包管理器安装ansible,最新的 ansible.cfg 配置文件有可能出现在 /etc/ansible 下并且命名为 ".rpmnew", 也可能根据不同的更新命名为其它名称

如果你是通过 pip 或者其他方式安装,则可能需要自行创建这个文件,以免原配置文件被覆盖.Ansible 的默认设置将会将其覆盖  

配置文件的详细参数以及取值范围请查看`ansible.cfg  <https://raw.github.com/ansible/ansible/devel/examples/ansible.cfg>`_ 

.. _environmental_configuration:

环境配置
```````````````````````````

Ansible 通过环境变量的形式来进行配置.这些设置后的环境变量将会覆盖掉所有配置文件读取的配置.为了节省篇幅,这些变量没有被列在这里,详情请见源代码目录中的 ‘constants.py’. 相对于配置文件它门会比当作遗产系统（legacy system) 来被使用,但是仍然有效

.. _config_values_by_section:

配置文件不同段详解
````````````````````````````````

配置文件被切割成了不同段.多数配置选项位于“general”段, 也有一些属于特定的链接类型（connection type）

.. _general_defaults:

通用默认段
----------------

在 [defaults] 段中,一下选项是可以调节的:

.. _action_plugins:

action_plugins
==============

“行为”是 ansible中的一段代码,用来激活一些事件,例如执行一个模块,一个模版,等等 

这是一个以开发者为中心的特性,使得一些底层模块可以从外部不同地方加载::

   action_plugins = ~/.ansible/plugins/action_plugins/:/usr/share/ansible_plugins/action_plugins

大多数用户都会使用这一特性,详情请见 :doc:`developing_plugins` .

.. _ansible_managed:

ansible_managed
===============

Ansible-managed 是一个字符串.可以插入到Ansible配置模版系统生成的文件中.如果你使用以下的自字符::

   {{ ansible_managed }}

默认设置可以哪个用户修改和修改时间::

    ansible_managed = Ansible managed: {file} modified on %Y-%m-%d %H:%M:%S by {uid} on {host}

这个设置可以告知用户,Ansible修改了一个文件,并且手动写入的内容可能已经被覆盖. 

需要注意的是,如果使用这一特性,这个字符串中将包含一个日期注释,如果日期更新,模版系统将会在每一次报告文件修改.

.. _ask_pass:

ask_pass
========

这个可以控制,Ansible 剧本playbook 是否会自动默认弹出弹出密码.默认为no:: 
    ask_pass=True

如果使用SSH 密钥匙做身份认证.可能需要修改这一参数 

.. _ask_sudo_pass:

ask_sudo_pass
=============

类似 ask_pass,用来控制Ansible playbook 在执行sudo之前是否询问sudo密码.默认为no::

    ask_sudo_pass=True

如果用户使用的系统平台开启了sudo 密码的话,应该开绿这一参数

.. _bin_ansible_callbacks:

bin_ansible_callbacks
=====================

.. versionadded:: 1.8

用来控制callback插件是否在运行 /usr/bin/ansible 的时候被加载. 这个模块将用于命令行的日志系统,发出通知等特性.
Callback插件如果存在将会永久性的被 /usr/bin/ansible-playbook 加载,不能被禁用::

    bin_ansible_callbacks=False

1.8 版本之前,callbacks 插件不可以被 /usr/bin/ansible加载. 
.. _callback_plugins:

callback_plugins
================

Callbacks 在ansible中是一段代码,在特殊事件时将被调用.并且允许出发通知. 
这是一个以开发者为中心的特性,可以实现对Ansible的底层拓展,并且拓展模块可以位于任何位置:: 

   callback_plugins = ~/.ansible/plugins/callback_plugins/:/usr/share/ansible_plugins/callback_plugins

大多数的用户将会用到这一特性,详见 :doc:`developing_plugins`.

.. _command_warnings:

command_warnings
================

.. versionadded:: 1.8

从Ansible 1.8 开始,当shell和命令行模块被默认模块简化的时,Ansible 将默认发出警告.
这个包含提醒使用'git'但不是通过命令行执行.使用模块调用比冒然使用命令行调用可以使playbook工作更具有一致性也更加可靠同时也更加便于维护::

    command_warnings = False

我们可以通过在命令行末尾添加 warn=yes 或者 warn=no选项来控制是否开启警告提示::


    - name: usage of git that could be replaced with the git module
      shell: git update foo warn=yes

.. _connection_plugins:

connection_plugins
==================

连接插件允许拓展ansible拓展通讯信道,用来传输命令或者文件. 
这是一个开发者中心特性,拓展插件可以从任何不同地方加载::

    connection_plugins = ~/.ansible/plugins/connection_plugins/:/usr/share/ansible_plugins/connection_plugins

大多数用户会用到这一特性, 详见::doc:`developing_plugins`
.. _deprecation_warnings:

deprecation_warnings
====================

.. versionadded:: 1.3

允许在ansible-playbook输出结果中禁用“不建议使用”警告::

    deprecation_warnings = True

“不建议警告”指的是使用一些在新版本中可能会被淘汰的遗留特性. 

.. _display_skipped_hosts:

display_skipped_hosts
=====================

如果设置为`False`,ansible 将不会显示任何跳过任务的状态.默认选项是现实跳过任务的状态:: 
    display_skipped_hosts=True

注意Ansible 总是会显示任何任务的头文件, 不管这个任务被跳过与否. 

.. _error_on_undefined_vars:

error_on_undefined_vars
=======================

从Ansible 1.3开始,这个选项将为默认,如果所引用的变量名称错误的话, 将会导致ansible在执行步骤上失败::
    error_on_undefined_vars=True

If set to False, any '{{ template_expression }}' that contains undefined variables will be rendered in a template
or ansible action line exactly as written.

.. _executable:

executable
==========

这个选项可以在sudo环境下产生一个shell交互接口. 用户只在/bin/bash的或者sudo限制的一些场景中需要修改.大部分情况下不需要修改::
    executable = /bin/bash

.. _filter_plugins:

filter_plugins
==============

过滤器是一种特殊的函数,用来拓展模版系统 .

这是一个开发者核心的特性,允许Ansible从任何地方载入底层拓展模块:: 

    filter_plugins = ~/.ansible/plugins/filter_plugins/:/usr/share/ansible_plugins/filter_plugins

Most users will not need to use this feature.  See :doc:`developing_plugins` for more details
大部分用户不会用到这个特性,详见:doc:`developing_plugins`.

.. _force_color:

force_color
===========

到没有使用TTY终端的时候,这个选项当用来强制颜色模式::
    force_color = 1

.. _force_handlers:

force_handlers
==============

.. versionadded:: 1.9.1

即便这个用户崩溃,这个选项仍可以继续运行这个用户:: 

		force_handlers = True

The default is False, meaning that handlers will not run if a failure has occurred on a host.
This can also be set per play or on the command line. See :doc:`_handlers_and_failure` for more details.
如果这个选项是False. 如果一个主机崩溃了,handlers将不会再运行这个主机.这个选项也可以通过命令行临时使用.详见:doc:`_handlers_and_failure`.

.. _forks:

forks
=====

这个选项设置在与主机通信时的默认并行进程数.从Ansible 1.3开始,fork数量默认自动设置为主机数量或者潜在的主机数量,
这将直接控制有多少网络资源活着cpu可以被使用.很多用户把这个设置为50,有些设置为500或者更多.如果你有很多的主机,
高数值将会使得跨主机行为变快.默认值比较保守::

    _forks=5 	
	
	
.. _gathering:

gathering
=========

1.6版本中的新特性,这个设置控制默认facts收集（远程系统变量）.
默认值为'implicit', 每一次play,facts都会被手机,除非设置'gather_facts: False'. 选项‘explicit’正好相反,facts不会被收集,直到play中需要. 
‘smart’选项意思是,没有facts的新hosts将不会被扫描, 但是如果同样一个主机,在不同的plays里面被记录地址,在playbook运行中将不会通信.这个选项当有需求节省fact收集时比较有用. 

hash_behaviour
==============

Ansible 默认将会以一种特定的优先级覆盖变量,详见:doc:`playbooks_variables`.拥有更高优先级的参数将会覆盖掉其他参数

有些用户希望被hashed的参数（python 中的数据结构'dictionaries'）被合并. 这个设置叫做‘merge’.这不是一个默认设置,而且不影响数组类型的数组.我不建议使用这个设置除非你觉得一定需要这个设置.官方实例中不使用这个选项:: 

    hash_behaviour=replace

合法的值为'replace'(默认值)或者‘merge’.

.. _hostfile:

hostfile
========

在1.9版本中,这不是一个合法设置.详见:ref:`inventory`.

.. _host_key_checking:

host_key_checking
=================

这个特性详见:doc:`intro_getting_started`,在Ansible 1.3或更新版本中将会检测主机密钥. 如果你了解怎么使用并且希望禁用这个功能,你可以将这个值设置为False::

    host_key_checking=True

.. _inventory:

inventory
=========

这个事默认库文件位置,脚本,或者存放可通信主机的目录::

    inventory = /etc/ansible/hosts

在1.9版本中被叫做hostfile. 

.. _jinja2_extensions:

jinja2_extensions
=================

这是一个开发者中心特性,允许开启Jinja2拓展模块:: 

    jinja2_extensions = jinja2.ext.do,jinja2.ext.i18n

如果你不太清楚这些都是啥,还是不要改的好:)

.. _library:

library
=======

这个事Ansible默认搜寻模块的位置::

     library = /usr/share/ansible

Ansible知道如何搜寻多个用冒号隔开的路径,同时也会搜索在playbook中的“./library”.

.. _log_path:

log_path
========

如果出现在ansible.cfg文件中.Ansible 将会在选定的位置登陆执行信息.请留意用户运行的Ansible对于logfile有权限::

    log_path=/var/log/ansible.log

这个特性不是默认开启的.如果不设置,ansible将会吧模块加载纪录在系统日志系统中.不包含用密码. 

对于需要了解更多日志系统的企业及用户,你也许对:doc:`tower` 感兴趣. 

.. _lookup_plugins:

lookup_plugins
==============

这是一个开发者中心选项,允许模块插件在不同区域被加载::

    lookup_plugins = ~/.ansible/plugins/lookup_plugins/:/usr/share/ansible_plugins/lookup_plugins

绝大部分用户将不会使用这个特性,详见:doc:`developing_plugins`

.. _module_lang:

module_lang
===========

这是默认模块和系统之间通信的计算机语言,默认为'C'语言. 

.. _module_name:

module_name
===========

这个是/usr/bin/ansible的默认模块名（-m）. 默认是'command'模块. 之前提到过,command模块不支持shell变量,管道,配额.
所以也许你希望把这个参数改为'shell'::

    module_name = command

.. _nocolor:

nocolor
=======

默认ansible会为输出结果加上颜色,用来更好的区分状态信息和失败信息.如果你想关闭这一功能,可以把'nocolor'设置为‘1’::

    nocolor=0

.. _nocows:

nocows
======

默认ansible可以调用一些cowsay的特性,使得/usr/bin/ansible-playbook运行起来更加愉快.为啥呢,因为我们相信系统应该是一
比较愉快的经历.如果你不喜欢cows,你可以通通过将'nocows'设置为‘1’来禁用这一选项::

    nocows=0

.. _pattern:

pattern
=======

如果没有提供“hosts”节点,这是playbook要通信的默认主机组.默认值是对所有主机通信,如果不想被惊吓到,最好还是设置个个选项::


    hosts=*

注意 /usr/bin/ansible 一直需要一个host pattern,并且不使用这个选项.这个选项只作用于/usr/bin/ansible-playbook. 

.. _poll_interval:

poll_interval
=============

对于Ansible中的异步任务(详见 :doc:`playbooks_async`）, 这个是设置定义,当具体的poll interval 没有定义时,多少时间回查一下这些任务的状态,
默认值是一个折中选择15秒钟.这个时间是个回查频率和任务完成叫回频率和当任务完成时的回转频率的这种:: 

    poll_interval=15

.. _private_key_file:

private_key_file
================

如果你是用pem密钥文件而不是SSH 客户端或秘密啊认证的话,你可以设置这里的默认值,来避免每一次提醒设置密钥文件位置``--ansible-private-keyfile``::

    private_key_file=/path/to/file.pem

.. _remote_port:

remote_port
===========

这个设置是你系统默认的远程SSH端口,如果不指定,默认为22号端口:: 

    remote_port = 22

.. _remote_tmp:

remote_tmp
==========

Ansible 通过远程传输模块到远程主机,然后远程执行,执行后在清理现场.在有些场景下,你也许想使用默认路径希望像更换补丁一样使用,
这时候你可以使用这个选项.::

    remote_tmp = $HOME/.ansible/tmp

默认路径是在用户家目录下属的目录.Ansible 会在这个目录中使用一个随机的文件夹名称. 

.. _remote_user:

remote_user
===========

这是个ansible使用/usr/bin/ansible-playbook链接的默认用户名. 注意如果不指定,/usr/bin/ansible默认使用当前用户名称:: 

    remote_user = root

.. _roles_path:

roles_path
==========

.. versionadded: '1.4'

roles 路径指的是'roles/'下的额外目录,用于playbook搜索Ansible roles.比如, 如果我们有个用于common roles源代码控制仓库和一个不同的
playbooks仓库,你也许会建立一个惯例去在 /opt/mysite/roles 里面查找roles.::

    roles_path = /opt/mysite/roles

多余的路径可以用冒号分隔,类似于其他path字符串::

    roles_path = /opt/mysite/roles:/opt/othersite/roles

Roles将会在playbook目录中开始搜索.如果role没有找到,这个参数指定了其它可能的搜索路径. 

.. _sudo_exe:

sudo_exe
========

如果在其他远程主机上使用另一种方式执行sudo草做, sudo程序的路径可以用这个参数更换,使用命令行标签来拟合标准sudo::

   sudo_exe=sudo

.. _sudo_flags:

sudo_flags
==========

当使用sudo支持的时候,传递给sudo而外的标签. 默认值为"-H", 意思是保留原用户的环境.在有些场景下也许需要添加或者删除
标签,大多数用户不需要修改这个选项::

   sudo_flags=-H

.. _sudo_user:

sudo_user
=========

这个是sudo使用的默认用户,如果``--sudo-user`` 没有特指或者'sudo_user' 在Ansible playbooks中没有特指,在大多数的逻辑中
默认为: 'root' :: 

   sudo_user=root

.. _system_warnings:

system_warnings
===============

.. versionadded:: 1.6

允许禁用系统运行ansible相关的潜在问题警告（不包括操作主机）::

   system_warnings = True

这个包括第三方库或者一些需要解决问题的警告.

.. _timeout:

timeout
=======

这个事默认SSH链接尝试超市时间::

    timeout = 10

.. _transport:

transport
=========

如果"-c  <transport_name>" 选项没有在使用/usr/bin/ansible 或者 /usr/bin/ansible-playbook 特指的话,这个参数提供了默认通信机制.默认
值为'smart', 如果本地系统支持 ControlPersist技术的话,将会使用(基于OpenSSH)‘ssh’,如果不支持讲使用‘paramiko’.其他传输选项包括‘local’,
'chroot','jail'等等. 

用户通常可以这个设置为‘smart’,让playbook在需要的条件自己选择‘connectin:’参数. 

.. _vars_plugins:

vars_plugins
============

这是一个开发者中心选项,允许底层拓展模块从任何地方加载::

    vars_plugins = ~/.ansible/plugins/vars_plugins/:/usr/share/ansible_plugins/vars_plugins

大部分的用户不会用到这个特性,详见:doc:`developing_plugins` 

.. _vault_password_file:

vault_password_file
===================

.. versionadded:: 1.7

这个用来设置密码文件,也可以通过命令行指定``--vault-password-file``::

   vault_password_file = /path/to/vault_password_file

在1.7版本中,这个文件也可以称为一个脚本的形式.如果你使用脚本而不是单纯文件的话,请确保它可以执行并且密码可以在标准输出上打印出来.如果你的脚本需要提示请求数据,请求将会发到标准错误输出中. 

.. _paramiko_settings:

Paramiko Specific Settings
--------------------------

Paramiko 是商业版linux 6 的默认SSH链接.但在其他平台上不是默认使用的.请在[paramiko]头文件下激活它.

.. _record_host_keys:

record_host_keys
================

默认设置会记录并验证通过在用户hostfile中新发现的的主机（如果host key checking 被激活的话）. 这个选项在有很多主机的时候将会性能很差.在
这种情况下,建议使用SSH传输代替. 当设置为False时, 性能将会提升,在hostkey checking 被禁用时候,建议使用.::

    record_host_keys=True

.. _openssh_settings:

OpenSSH Specific Settings
-------------------------

在[ssh_connection]头文件之下,用来调整SSH的通信连接.OpenSSH是Ansible在操作系统上默认的通讯连接,对于支持ControlPersist足够新了.（意思除了Enterprise linux 6版以及更早的系统外的所有的操作系统). 

.. _ssh_args:

ssh_args
========

如果设置了的话,这个选项将会传递一组选项给Ansible 然不是使用以前的默认值::

    ssh_args = -o ControlMaster=auto -o ControlPersist=60s

用户可以提高ControlPersist值来提高性能.30 分钟通常比较合适. 

.. _control_path:

control_path
============

这个是保存ControlPath套接字的位置. 默认值是::

    control_path=%(directory)s/ansible-ssh-%%h-%%p-%%r

在有些系统上面,会遇到很长的主机名或者很长的路径名称（也许因为很长的用户名,或者比较深的家目录）,这些都会
超出套接字文件名字符上限（对于大多数平台上限为108个字符）.在这种情况下,你也许希望按照以下方式缩短字符串::

    control_path = %(directory)s/%%h-%%r

Ansible 1.4 以后的版本会引导用户在这种情况下使用"-vvvv"参数,这样很容易分辨 Control Path 文件名是否过长.这个
问题在EC2上会频繁的遇到. 

.. _scp_if_ssh:

scp_if_ssh
==========

又是用户操控一个一个没有开启SFTP协议的远程系统.如果这个设置为True,scp将代替用来为远程主机传输文件:: 

    scp_if_ssh=False

如果没有遇到这样的问题没有必要来修改这个设置.当然修改这个设置也没有什么明显的弊端.大部分的系统环境都默认支持SFTP,
通常情况下不需要修改. 


.. _pipelining:

pipelining
==========

在不通过实际文件传输的情况下执行ansible模块来使用管道特性,从而减少执行远程模块SSH操作次数.如果开启这个设置,将显著提高性能.
然而当使用"sudo:"操作的时候, 你必须在所有管理的主机的/etc/sudoers中禁用'requiretty'.

默认这个选项为了保证与sudoers requiretty的设置（在很多发行版中时默认的设置）的兼容性是禁用的. 
但是为了提高性能强烈建议开启这个设置.详见:doc:`playbooks_acceleration`::

    pipelining=False

.. _accelerate_settings:

Accelerated Mode Settings
-------------------------

在[accelerate]首部下, 以下设置可以调整,详见:doc:`playbooks_acceleration`.如果你不能在你的环境中开启:ref:`pipelining` ,
Accelertation 是一个很有用的性能特性. 但是如果你可以开启管道,这个选项也许对你无用.

.. _accelerate_port:

accelerate_port
===============

.. versionadded:: 1.3

在急速模式下使用的端口::

    accelerate_port = 5099

.. _accelerate_timeout:

accelerate_timeout
==================

.. versionadded:: 1.4

这个设置时用来控制从客户机获取数据的超时时间.如果在这段时间内没有数据传输,套接字连接会被关闭. 一个保持连接（keepalive）数据包通常每15秒回发回给控制台,所以这个超时时间不应该低于15秒（默认值为30秒）::

    accelerate_timeout = 30

.. _accelerate_connect_timeout:

accelerate_connect_timeout
==========================

.. versionadded:: 1.4

这个设置空着套接字调用的超时时间.这个应该设置相对比较短.这个和`accelerate_port`连接在回滚到ssh或者paramiko（受限于你默认的连接设置）连接方式之前会尝试三次开始远程加速daemon守护进程.默认设置为1.0秒::

    accelerate_connect_timeout = 1.0

注意,这个选项值可以设置为小于1秒钟,但是除非你拥有一个速度很快而且很可靠的网络,否则也许这样并不是一个很好的选择.如果你使用英特网访问你的系统,最好提高这个值.  

.. _accelerate_daemon_timeout:

accelerate_daemon_timeout
=========================

.. versionadded:: 1.6

This setting controls the timeout for the accelerated daemon, as measured in minutes. The default daemon timeout is 30 minutes::
这个控制加速daemon守护进程的超时时间,用分钟来衡量.默认为30分钟::

    accelerate_daemon_timeout = 30

注意, 在1.6版本之前,daemon发起的超时时间是硬编码的.对于1.6以后的版本,超时时间是根据daemon上一次活动信息和这个可设置的选项. 

.. _accelerate_multi_key:

accelerate_multi_key
====================

.. versionadded:: 1.6

If enabled, this setting allows multiple private keys to be uploaded to the daemon. Any clients connecting to the daemon must also enable this option::
如果这个选项开启,这个设置将允许多个私钥被加载到daemon. 任何客户端要想连接daemon都需要开启这个选项::

    accelerate_multi_key = yes

通过本地套接字文件连接的通过SSH上传密钥文件到目标节点的新客户端,必须在登陆daemon时使用原始的登陆密钥登陆. 
