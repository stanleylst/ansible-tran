Ansible的配置文件
++++++++++++++++++++++++++++++

.. contents:: 标题

.. highlight:: bash

Ansible的一些的设置可以通过配置文件完成。在大多数场景下默认的配置就能满足大多数用户的需求，在一些特殊场景下，用户还是需要自行修改这些配置文件 

用户可以修改一下配置文件来修改设置，他们的被读取的顺序如下::

    * ANSIBLE_CONFIG (一个环境变量)
    * ansible.cfg (位于当前目录中)
    * .ansible.cfg (位于家目录中)
    * /etc/ansible/ansible.cfg

版本1.5之前的读取顺序如下::

    * ansible.cfg (位于当前目录)
    * ANSIBLE_CONFIG (一个环境变量)
    * .ansible.cfg (位于家目录下)
    * /etc/ansible/ansible.cfg

Ansible 将会按以上顺序逐个查询这些文件，直到找到一个为止，并且使用第一个寻找到个配置文件的配置，这些配置将不会被叠加。 

.. _getting_the_latest_configuration:

获取最新配置文件
````````````````````````````````

如果使用程序包管理器安装ansible，最新的 ansible.cfg 配置文件有可能出现在 /etc/ansible 下并且命名为 ".rpmnew", 也可能根据不同的更新命名为其它名称

如果你是通过 pip 或者其他方式安装，则可能需要自行创建这个文件,以免原配置文件被覆盖。Ansible 的默认设置将会将其覆盖  

配置文件的详细参数以及取值范围请查看`ansible.cfg  <https://raw.github.com/ansible/ansible/devel/examples/ansible.cfg>`_ 

.. _environmental_configuration:

环境配置
```````````````````````````

Ansible 通过环境变量的形式来进行配置。这些设置后的环境变量将会覆盖掉所有配置文件读取的配置。为了节省篇幅，这些变量没有被列在这里，详情请见源代码目录中的 ‘constants.py’. 相对于配置文件它门会比当作遗产系统（legacy system) 来被使用，但是仍然有效

.. _config_values_by_section:

配置文件不同段详解
````````````````````````````````

配置文件被切割成了不同段。多数配置选项位于“general”段， 也有一些属于特定的链接类型（connection type）

.. _general_defaults:

通用默认段
----------------

在 [defaults] 段中，一下选项是可以调节的:

.. _action_plugins:

action_plugins
==============

“行为”是 ansible中的一段代码，用来激活一些事件，例如执行一个模块，一个模版，等等 

这是一个以开发者为中心的特性，使得一些底层模块可以从外部不同地方加载::

   action_plugins = ~/.ansible/plugins/action_plugins/:/usr/share/ansible_plugins/action_plugins

大多数用户都会使用这一特性，详情请见 :doc:`developing_plugins` .

.. _ansible_managed:

ansible_managed
===============

Ansible-managed 是一个字符串。可以插入到Ansible配置模版系统生成的文件中。如果你使用以下的自字符::

   {{ ansible_managed }}

默认设置可以哪个用户修改和修改时间::

    ansible_managed = Ansible managed: {file} modified on %Y-%m-%d %H:%M:%S by {uid} on {host}

这个设置可以告知用户，Ansible修改了一个文件，并且手动写入的内容可能已经被覆盖。 

需要注意的是，如果使用这一特性，这个字符串中将包含一个日期注释，如果日期更新，模版系统将会在每一次报告文件修改。

.. _ask_pass:

ask_pass
========

这个可以控制，Ansible 剧本playbook 是否会自动默认弹出弹出密码。默认为no:: 
    ask_pass=True

如果使用SSH 密钥匙做身份认证。可能需要修改这一参数 

.. _ask_sudo_pass:

ask_sudo_pass
=============

类似 ask_pass,用来控制Ansible playbook 在执行sudo之前是否询问sudo密码。默认为no::

    ask_sudo_pass=True

如果用户使用的系统平台开启了sudo 密码的话，应该开绿这一参数

.. _bin_ansible_callbacks:

bin_ansible_callbacks
=====================

.. versionadded:: 1.8

用来控制callback插件是否在运行 /usr/bin/ansible 的时候被加载。 这个模块将用于命令行的日志系统，发出通知等特性。
Callback插件如果存在将会永久性的被 /usr/bin/ansible-playbook 加载，不能被禁用::

    bin_ansible_callbacks=False

1.8 版本之前，callbacks 插件不可以被 /usr/bin/ansible加载。 
.. _callback_plugins:

callback_plugins
================

Callbacks 在ansible中是一段代码，在特殊事件时将被调用。并且允许出发通知。 
这是一个以开发者为中心的特性，可以实现对Ansible的底层拓展，并且拓展模块可以位于任何位置:: 

   callback_plugins = ~/.ansible/plugins/callback_plugins/:/usr/share/ansible_plugins/callback_plugins

大多数的用户将会用到这一特性，详见 :doc:`developing_plugins`。

.. _command_warnings:

command_warnings
================

.. versionadded:: 1.8

从Ansible 1.8 开始，当shell和命令行模块被默认模块简化的时，Ansible 将默认发出警告。
这个包含提醒使用'git'但不是通过命令行执行。使用模块调用比冒然使用命令行调用可以使playbook工作更具有一致性也更加可靠同时也更加便于维护::

    command_warnings = False

我们可以通过在命令行末尾添加 warn=yes 或者 warn=no选项来控制是否开启警告提示::


    - name: usage of git that could be replaced with the git module
      shell: git update foo warn=yes

.. _connection_plugins:

connection_plugins
==================

连接插件允许拓展ansible拓展通讯信道，用来传输命令或者文件。 
这是一个开发者中心特性，拓展插件可以从任何不同地方加载::

    connection_plugins = ~/.ansible/plugins/connection_plugins/:/usr/share/ansible_plugins/connection_plugins

大多数用户会用到这一特性， 详见：:doc:`developing_plugins`
.. _deprecation_warnings:

deprecation_warnings
====================

.. versionadded:: 1.3

允许在ansible-playbook输出结果中禁用“不建议使用”警告::

    deprecation_warnings = True

“不建议警告”指的是使用一些在新版本中可能会被淘汰的遗留特性。 

.. _display_skipped_hosts:

display_skipped_hosts
=====================

如果设置为`False`,ansible 将不会显示任何跳过任务的状态。默认选项是现实跳过任务的状态:: 
    display_skipped_hosts=True

注意Ansible 总是会显示任何任务的头文件， 不管这个任务被跳过与否。 

.. _error_on_undefined_vars:

error_on_undefined_vars
=======================

从Ansible 1.3开始，这个选项将为默认，如果所引用的变量名称错误的话， 将会导致ansible在执行步骤上失败::
    error_on_undefined_vars=True

If set to False, any '{{ template_expression }}' that contains undefined variables will be rendered in a template
or ansible action line exactly as written.

.. _executable:

executable
==========

这个选项可以在sudo环境下产生一个shell交互接口。 用户只在/bin/bash的或者sudo限制的一些场景中需要修改。大部分情况下不需要修改::
    executable = /bin/bash

.. _filter_plugins:

filter_plugins
==============

过滤器是一种特殊的函数，用来拓展模版系统 。

这是一个开发者核心的特性，允许Ansible从任何地方载入底层拓展模块:: 

    filter_plugins = ~/.ansible/plugins/filter_plugins/:/usr/share/ansible_plugins/filter_plugins

Most users will not need to use this feature.  See :doc:`developing_plugins` for more details
大部分用户不会用到这个特性，详见:doc:`developing_plugins`。

.. _force_color:

force_color
===========

到没有使用TTY终端的时候，这个选项当用来强制颜色模式::
    force_color = 1

.. _force_handlers:

force_handlers
==============

.. versionadded:: 1.9.1

即便这个用户崩溃，这个选项仍可以继续运行这个用户:: 

		force_handlers = True

The default is False, meaning that handlers will not run if a failure has occurred on a host.
This can also be set per play or on the command line. See :doc:`_handlers_and_failure` for more details.
如果这个选项是False. 如果一个主机崩溃了，handlers将不会再运行这个主机。这个选项也可以通过命令行临时使用。详见:doc:`_handlers_and_failure`.

.. _forks:

forks
=====

这个选项设置在与主机通信时的默认并行进程数。从Ansible 1.3开始，fork数量默认自动设置为主机数量或者潜在的主机数量，
这将直接控制有多少网络资源活着cpu可以被使用。很多用户把这个设置为50，有些设置为500或者更多。如果你有很多的主机，
高数值将会使得跨主机行为变快。默认值比较保守::
    _forks=5 	
	
	
.. _gathering:

gathering
=========

1.6版本中的新特性，这个设置控制默认facts收集（远程系统变量）。
默认值为'implicit', 每一次play，facts都会被手机,除非设置'gather_facts: False'。 选项‘explicit’正好相反，facts不会被收集，直到play中需要。 
‘smart’选项意思是，没有facts的新hosts将不会被扫描， 但是如果同样一个主机，在不同的plays里面被记录地址，在playbook运行中将不会通信。这个选项当有需求节省fact收集时比较有用。 

hash_behaviour
==============

Ansible 默认将会以一种特定的优先级覆盖变量，详见:doc:`playbooks_variables`。拥有更高优先级的参数将会覆盖掉其他参数

有些用户希望被hashed的参数（python 中的数据结构'dictionaries'）被合并。 这个设置叫做‘merge’。这不是一个默认设置，而且不影响数组类型的数组。我不建议使用这个设置除非你觉得一定需要这个设置。官方实例中不使用这个选项:: 

    hash_behaviour=replace

合法的值为'replace'(默认值)或者‘merge’。

.. _hostfile:

hostfile
========

在1.9版本中，这不是一个合法设置。详见:ref:`inventory`。

.. _host_key_checking:

host_key_checking
=================

这个特性详见:doc:`intro_getting_started`,在Ansible 1.3或更新版本中将会检测主机密钥。 如果你了解怎么使用并且希望禁用这个功能，你可以将这个值设置为False::

    host_key_checking=True

.. _inventory:

inventory
=========

这个事默认库文件位置，脚本，或者存放可通信主机的目录::

    inventory = /etc/ansible/hosts

在1.9版本中被叫做hostfile. 

.. _jinja2_extensions:

jinja2_extensions
=================

这是一个开发者中心特性，允许开启Jinja2拓展模块:: 

    jinja2_extensions = jinja2.ext.do,jinja2.ext.i18n

如果你不太清楚这些都是啥，还是不要改的好:)

.. _library:

library
=======

这个事Ansible默认搜寻模块的位置::

     library = /usr/share/ansible

Ansible知道如何搜寻多个用冒号隔开的路径，同时也会搜索在playbook中的“./library”。

.. _log_path:

log_path
========

如果出现在ansible.cfg文件中。Ansible 将会在选定的位置登陆执行信息。请留意用户运行的Ansible对于logfile有权限::

    log_path=/var/log/ansible.log

这个特性不是默认开启的。如果不设置，ansible将会吧模块加载纪录在系统日志系统中。不包含用密码。 

对于需要了解更多日志系统的企业及用户，你也许对:doc:`tower` 感兴趣。 

.. _lookup_plugins:

lookup_plugins
==============

这是一个开发者中心选项，允许模块插件在不同区域被加载::

    lookup_plugins = ~/.ansible/plugins/lookup_plugins/:/usr/share/ansible_plugins/lookup_plugins

绝大部分用户将不会使用这个特性，详见:doc:`developing_plugins`

.. _module_lang:

module_lang
===========

这是默认模块和系统之间通信的计算机语言，默认为'C'语言。 

.. _module_name:

module_name
===========

这个是/usr/bin/ansible的默认模块名（-m）。 默认是'command'模块。 之前提到过，command模块不支持shell变量，管道，配额。
所以也许你希望把这个参数改为'shell'::

    module_name = command

.. _nocolor:

nocolor
=======

默认ansible会为输出结果加上颜色，用来更好的区分状态信息和失败信息。如果你想关闭这一功能，可以把'nocolor'设置为‘1’:：

    nocolor=0

.. _nocows:

nocows
======

默认ansible可以调用一些cowsay的特性，使得/usr/bin/ansible-playbook运行起来更加愉快。为啥呢，因为我们相信系统应该是一
比较愉快的经历。如果你不喜欢cows，你可以通通过将'nocows'设置为‘1’来禁用这一选项::

    nocows=0

.. _pattern:

pattern
=======

如果没有提供“hosts”节点，这是playbook要通信的默认主机组。默认值是对所有主机通信，如果不想被惊吓到，最好还是设置个个选项::


    hosts=*

注意 /usr/bin/ansible 一直需要一个host pattern，并且不使用这个选项。这个选项只作用于/usr/bin/ansible-playbook. 

.. _poll_interval:

poll_interval
=============

对于Ansible中的异步任务(详见 :doc:`playbooks_async`）， 这个是设置定义，当具体的poll interval 没有定义时，多少时间回查一下这些任务的状态，
默认值是一个折中选择15秒钟。这个时间是个回查频率和任务完成叫回频率和当任务完成时的回转频率的这种:: 

    poll_interval=15

.. _private_key_file:

private_key_file
================

如果你是用pem密钥文件而不是SSH 客户端或秘密啊认证的话，你可以设置这里的默认值，来避免每一次提醒设置密钥文件位置``--ansible-private-keyfile``::

    private_key_file=/path/to/file.pem

.. _remote_port:

remote_port
===========

这个设置是你系统默认的远程SSH端口，如果不指定，默认为22号端口:: 

    remote_port = 22

.. _remote_tmp:

remote_tmp
==========

Ansible works by transferring modules to your remote machines, running them, and then cleaning up after itself.  In some
cases, you may not wish to use the default location and would like to change the path.  You can do so by altering this
setting::

    remote_tmp = $HOME/.ansible/tmp

The default is to use a subdirectory of the user's home directory.  Ansible will then choose a random directory name
inside this location.

.. _remote_user:

remote_user
===========

This is the default username ansible will connect as for /usr/bin/ansible-playbook.  Note that /usr/bin/ansible will
always default to the current user if this is not defined::

    remote_user = root

.. _roles_path:

roles_path
==========

.. versionadded: '1.4'

The roles path indicate additional directories beyond the 'roles/' subdirectory of a playbook project to search to find Ansible
roles.  For instance, if there was a source control repository of common roles and a different repository of playbooks, you might
choose to establish a convention to checkout roles in /opt/mysite/roles like so::

    roles_path = /opt/mysite/roles

Additional paths can be provided separated by colon characters, in the same way as other pathstrings::

    roles_path = /opt/mysite/roles:/opt/othersite/roles

Roles will be first searched for in the playbook directory.  Should a role not be found, it will indicate all the possible paths
that were searched.

.. _sudo_exe:

sudo_exe
========

If using an alternative sudo implementation on remote machines, the path to sudo can be replaced here provided
the sudo implementation is matching CLI flags with the standard sudo::

   sudo_exe=sudo

.. _sudo_flags:

sudo_flags
==========

Additional flags to pass to sudo when engaging sudo support.  The default is '-H' which preserves the environment
of the original user.  In some situations you may wish to add or remove flags, but in general most users
will not need to change this setting::

   sudo_flags=-H

.. _sudo_user:

sudo_user
=========

This is the default user to sudo to if ``--sudo-user`` is not specified or 'sudo_user' is not specified in an Ansible
playbook.  The default is the most logical: 'root'::

   sudo_user=root

.. _system_warnings:

system_warnings
===============

.. versionadded:: 1.6

Allows disabling of warnings related to potential issues on the system running ansible itself (not on the managed hosts)::

   system_warnings = True

These may include warnings about 3rd party packages or other conditions that should be resolved if possible.

.. _timeout:

timeout
=======

This is the default SSH timeout to use on connection attempts::

    timeout = 10

.. _transport:

transport
=========

This is the default transport to use if "-c <transport_name>" is not specified to /usr/bin/ansible or /usr/bin/ansible-playbook.
The default is 'smart', which will use 'ssh' (OpenSSH based) if the local operating system is new enough to support ControlPersist
technology, and then will otherwise use 'paramiko'.  Other transport options include 'local', 'chroot', 'jail', and so on.

Users should usually leave this setting as 'smart' and let their playbooks choose an alternate setting when needed with the
'connection:' play parameter.

.. _vars_plugins:

vars_plugins
============

This is a developer-centric feature that allows low-level extensions around Ansible to be loaded from
different locations::

    vars_plugins = ~/.ansible/plugins/vars_plugins/:/usr/share/ansible_plugins/vars_plugins

Most users will not need to use this feature.  See :doc:`developing_plugins` for more details


.. _vault_password_file:

vault_password_file
===================

.. versionadded:: 1.7

Configures the path to the Vault password file as an alternative to specifying ``--vault-password-file`` on the command line::

   vault_password_file = /path/to/vault_password_file

As of 1.7 this file can also be a script. If you are using a script instead of a flat file, ensure that it is marked as executable, and that the password is printed to standard output. If your script needs to prompt for data, prompts can be sent to standard error.

.. _paramiko_settings:

Paramiko Specific Settings
--------------------------

Paramiko is the default SSH connection implementation on Enterprise Linux 6 or earlier, and is not used by default on other
platforms.  Settings live under the [paramiko] header.

.. _record_host_keys:

record_host_keys
================

The default setting of yes will record newly discovered and approved (if host key checking is enabled) hosts in the user's hostfile.
This setting may be inefficient for large numbers of hosts, and in those situations, using the ssh transport is definitely recommended
instead.  Setting it to False will improve performance and is recommended when host key checking is disabled::

    record_host_keys=True

.. _openssh_settings:

OpenSSH Specific Settings
-------------------------

Under the [ssh_connection] header, the following settings are tunable for SSH connections.  OpenSSH is the default connection type for Ansible
on OSes that are new enough to support ControlPersist.  (This means basically all operating systems except Enterprise Linux 6 or earlier).

.. _ssh_args:

ssh_args
========

If set, this will pass a specific set of options to Ansible rather than Ansible's usual defaults::

    ssh_args = -o ControlMaster=auto -o ControlPersist=60s

In particular, users may wish to raise the ControlPersist time to encourage performance.  A value of 30 minutes may
be appropriate.

.. _control_path:

control_path
============

This is the location to save ControlPath sockets. This defaults to::

    control_path=%(directory)s/ansible-ssh-%%h-%%p-%%r

On some systems with very long hostnames or very long path names (caused by long user names or
deeply nested home directories) this can exceed the character limit on
file socket names (108 characters for most platforms). In that case, you
may wish to shorten the string to something like the below::

    control_path = %(directory)s/%%h-%%r

Ansible 1.4 and later will instruct users to run with "-vvvv" in situations where it hits this problem
and if so it is easy to tell there is too long of a Control Path filename.  This may be frequently
encountered on EC2.

.. _scp_if_ssh:

scp_if_ssh
==========

Occasionally users may be managing a remote system that doesn't have SFTP enabled.  If set to True, we can
cause scp to be used to transfer remote files instead::

    scp_if_ssh=False

There's really no reason to change this unless problems are encountered, and then there's also no real drawback
to managing the switch.  Most environments support SFTP by default and this doesn't usually need to be changed.


.. _pipelining:

pipelining
==========

Enabling pipelining reduces the number of SSH operations required to
execute a module on the remote server, by executing many ansible modules without actual file transfer. 
This can result in a very significant performance improvement when enabled, however when using "sudo:" operations you must
first disable 'requiretty' in /etc/sudoers on all managed hosts.

By default, this option is disabled to preserve compatibility with
sudoers configurations that have requiretty (the default on many distros), but is highly
recommended if you can enable it, eliminating the need for :doc:`playbooks_acceleration`::

    pipelining=False

.. _accelerate_settings:

Accelerated Mode Settings
-------------------------

Under the [accelerate] header, the following settings are tunable for :doc:`playbooks_acceleration`.  Acceleration is 
a useful performance feature to use if you cannot enable :ref:`pipelining` in your environment, but is probably
not needed if you can.

.. _accelerate_port:

accelerate_port
===============

.. versionadded:: 1.3

This is the port to use for accelerated mode::

    accelerate_port = 5099

.. _accelerate_timeout:

accelerate_timeout
==================

.. versionadded:: 1.4

This setting controls the timeout for receiving data from a client. If no data is received during this time, the socket connection will be closed. A keepalive packet is sent back to the controller every 15 seconds, so this timeout should not be set lower than 15 (by default, the timeout is 30 seconds)::

    accelerate_timeout = 30

.. _accelerate_connect_timeout:

accelerate_connect_timeout
==========================

.. versionadded:: 1.4

This setting controls the timeout for the socket connect call, and should be kept relatively low. The connection to the `accelerate_port` will be attempted 3 times before Ansible will fall back to ssh or paramiko (depending on your default connection setting) to try and start the accelerate daemon remotely. The default setting is 1.0 seconds::

    accelerate_connect_timeout = 1.0

Note, this value can be set to less than one second, however it is probably not a good idea to do so unless you're on a very fast and reliable LAN. If you're connecting to systems over the internet, it may be necessary to increase this timeout.

.. _accelerate_daemon_timeout:

accelerate_daemon_timeout
=========================

.. versionadded:: 1.6

This setting controls the timeout for the accelerated daemon, as measured in minutes. The default daemon timeout is 30 minutes::

    accelerate_daemon_timeout = 30

Note, prior to 1.6, the timeout was hard-coded from the time of the daemon's launch. For version 1.6+, the timeout is now based on the last activity to the daemon and is configurable via this option.

.. _accelerate_multi_key:

accelerate_multi_key
====================

.. versionadded:: 1.6

If enabled, this setting allows multiple private keys to be uploaded to the daemon. Any clients connecting to the daemon must also enable this option::

    accelerate_multi_key = yes

New clients first connect to the target node over SSH to upload the key, which is done via a local socket file, so they must have the same access as the user that launched the daemon originally.

