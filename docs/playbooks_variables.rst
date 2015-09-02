Variables
变量
=========

.. contents:: Topics

While automation exists to make it easier to make things repeatable, all of your systems are likely not exactly alike.

已经存在的自动化技术使得重复做事变得更加容易，但你的所有系统有时则不会这样。

On some systems you may want to set some behavior or configuration that is slightly different from others. 

在有些系统中你想设置一些行为或者配置，这与其它系统稍有不同。

Also, some of the observed behavior or state 
of remote systems might need to influence how you configure those systems.  (Such as you might need to find out the IP
address of a system and even use it as a configuration value on another system).

并且，远程系统的可视行为或状态会影响我们配置这些系统。（比如你需要得到一个系统的IP地址，甚至用该值来配置另一个系统）。

You might have some templates for configuration files that are mostly the same, but slightly different based on those variables.  

你可能有一些非常相似的模板或配置文件，而有些变量则稍微不同。

Variables in Ansible are how we deal with differences between systems.  

Ansible中的变量用来处理系统间的不同。

To understand variables you'll also want to dig into :doc:`playbooks_conditionals` and :doc:`playbooks_loops`.
Useful things like the "group_by" module
and the "when" conditional can also be used with variables, and to help manage differences between systems.

为了理解变量，你也需要深入阅读 :doc:`playbooks_conditionals` 和 :doc:`playbooks_loops`。有用的模块(比如"group_by"模块和"when"条件)也可以结合变量使用，用于管理系统间的不同之处。

It's highly recommended that you consult the ansible-examples github repository to see a lot of examples of variables put to use.

强烈建议你学习 ansible-examples github代码库，里面有大量使用变量的例子。

.. _valid_variable_names:

What Makes A Valid Variable Name
合法的变量名
````````````````````````````````

Before we start using variables it's important to know what are valid variable names.

在使用变量之前最好先知道什么是合法的变量名。

Variable names should be letters, numbers, and underscores.  Variables should always start with a letter.

变量名可以为字母，数字以及下划线。变量始终应该以字母开头。

"foo_port" is a great variable.  "foo5" is fine too.  

"foo_port"是个合法的变量名。"foo5"也是。

"foo-port", "foo port", "foo.port" and "12" are not valid variable names.

"foo-port", "foo port", "foo.port" 和 "12"则不是合法的变量名。

Easy enough, let's move on.

很简单吧，继续往下看。

.. _variables_in_inventory:

Variables Defined in Inventory
在Inventory中定义变量
``````````````````````````````

We've actually already covered a lot about variables in another section, so far this shouldn't be terribly new, but
a bit of a refresher.

我们已经在其它文档中覆盖了大量关于使用变量的场景，所以这里没多少新的知识点，权当加深记忆。

Often you'll want to set variables based on what groups a machine is in.  For instance, maybe machines in Boston
want to use 'boston.ntp.example.com' as an NTP server.

通常你想基于一个机器位于哪个群组而设置变量。比如，位于波士顿的很多机器会使用 'boston.ntp.example.com' 作为NTP服务器。

See the :doc:`intro_inventory` document for multiple ways on how to define variables in inventory.

请看 :doc:`intro_inventory` 文档来学习在inventory中使用多种方式来定义变量。

.. _playbook_variables:

Variables Defined in a Playbook
在playbook中定义变量
```````````````````````````````

In a playbook, it's possible to define variables directly inline like so::
在playbook中，可以直接定义变量，如下所示::

   - hosts: webservers
     vars:
       http_port: 80

This can be nice as it's right there when you are reading the playbook.
这种所见即所得的方式非常好。

.. _included_variables:

Variables defined from included files and roles
在文件和role中定义变量
```````````````````````````````````````````````

It turns out we've already talked about variables in another place too.

事实上在其它地方我们也讲过这点了。

As described in :doc:`playbooks_roles`, variables can also be included in the playbook via include files, which may or may
not be part of an "Ansible Role".  Usage of roles is preferred as it provides a nice organizational system.

正如在 :doc:`playbooks_roles` 描述的一样，变量也可以通过文件包含在playbook中，该变量可以作为或者不作为“Ansible Role”的一部分。使用role是首选，因为它提供了一个很好的组织体系。

.. _about_jinja2:

Using Variables: About Jinja2
使用变量: 关于Jinja2
`````````````````````````````

It's nice enough to know about how to define variables, but how do you use them?

我们已经知道很多关于定义变量的知识，那么你知道如何使用它们吗？

Ansible allows you to
reference variables in your playbooks using the Jinja2 templating system.  While you can do a lot of complex
things in Jinja, only the basics are things you really need to learn at first.

Ansible允许你使用Jinja2模板系统在playbook中引用变量。借助Jinja你能做很多复杂的操作，首先你要学习基本使用。

For instance, in a simple template, you can do something like::

例如，在简单的模板中你可以这样做::

    My amp goes to {{ max_amp_value }}

And that will provide the most basic form of variable substitution.

这就是变量替换最基本的形式。

This is also valid directly in playbooks, and you'll occasionally want to do things like::

你也可以在playbook中直接这样用，你偶尔想这样做::

    template: src=foo.cfg.j2 dest={{ remote_install_path }}/foo.cfg

In the above example, we used a variable to help decide where to place a file.
在上述的例子中，我们使用变量来决定文件放置在哪里。

Inside a template you automatically have access to all of the variables that are in scope for a host.  Actually
it's more than that -- you can also read variables about other hosts.  We'll show how to do that in a bit.

在模板中你自动会获取在主机范围之内的所有变量的访问权。事实上更多，你可以读取其它主机的变量。我们将演示如何做。

.. note:: ansible allows Jinja2 loops and conditionals in templates, but in playbooks, we do not use them.  Ansible
   playbooks are pure machine-parseable YAML.  This is a rather important feature as it means it is possible to code-generate
   pieces of files, or to have other ecosystem tools read Ansible files.  Not everyone will need this but it can unlock
   possibilities.

.. 注意:: 在模板中Jinja2可以用循环和条件语句，而在playbook中则不行。Ansible playbook是纯粹的机器解析的YAML。这是一个非常重要的功能，这意味着根据文件可以生成代码，或者其它系统工具能够读取Ansible文件。虽然并不是所有人都需要这个功能，但我们不能封锁可能性。

.. _jinja2_filters:

Jinja2 Filters
Jinja2过滤器
``````````````

.. note:: These are infrequently utilized features.  Use them if they fit a use case you have, but this is optional knowledge.

.. 注意:: 这并不是常用的特性。只在合适的时候使用它们，这是一个附加知识点。

Filters in Jinja2 are a way of transforming template expressions from one kind of data into another.  Jinja2
ships with many of these. See `builtin filters`_ in the official Jinja2 template documentation.

Jinja2中的过滤器可以把一个模板表达式转换为另一个。Jinja2附带了很多这样的功能。请参见Jinja2官方模板文档中的 `builtin filters`_。

In addition to those, Ansible supplies many more. See the :doc:`playbooks_filters` document
for a list of available filters and example usage guide.

另外，Ansible还支持其它特性。请看 :doc:`playbooks_filters`文档中关于一系列可用的过滤器及示例。

.. _yaml_gotchas:

Hey Wait, A YAML Gotcha
YAML陷阱
```````````````````````

YAML syntax requires that if you start a value with {{ foo }} you quote the whole line, since it wants to be
sure you aren't trying to start a YAML dictionary.  This is covered on the :doc:`YAMLSyntax` page.

YAML语法要求如果值以{{ foo }}开头的话我们需要将整行用双引号包起来。这是为了确认你不是想声明一个YAML字典。该知识点在 :doc:`YAMLSyntax`页面有所讲述。

This won't work::

这样是不行的::

    - hosts: app_servers
      vars:
          app_path: {{ base_path }}/22

Do it like this and you'll be fine::

你应该这么做::

    - hosts: app_servers
      vars:
           app_path: "{{ base_path }}/22"

.. _vars_and_facts:

Information discovered from systems: Facts
使用Facts获取的信息
``````````````````````````````````````````

There are other places where variables can come from, but these are a type of variable that are discovered, not set by the user.

还有其它地方可以获取变量，这些变量是自动发现的，而不是用户自己设置的。

Facts are information derived from speaking with your remote systems.

Facts通过访问远程系统获取相应的信息。

An example of this might be the ip address of the remote host, or what the operating system is. 

一个例子就是远程主机的IP地址或者操作系统是什么。

To see what information is available, try the following::

使用以下命令可以查看哪些信息是可用的::

    ansible hostname -m setup

This will return a ginormous amount of variable data, which may look like this, as taken from Ansible 1.4 on a Ubuntu 12.04 system::

这会返回巨量的变量数据，比如对于Ubutu 12.04系统，Ansible 1.4获取的信息显示如下::

        "ansible_all_ipv4_addresses": [
            "REDACTED IP ADDRESS"
        ], 
        "ansible_all_ipv6_addresses": [
            "REDACTED IPV6 ADDRESS"
        ], 
        "ansible_architecture": "x86_64", 
        "ansible_bios_date": "09/20/2012", 
        "ansible_bios_version": "6.00", 
        "ansible_cmdline": {
            "BOOT_IMAGE": "/boot/vmlinuz-3.5.0-23-generic", 
            "quiet": true, 
            "ro": true, 
            "root": "UUID=4195bff4-e157-4e41-8701-e93f0aec9e22", 
            "splash": true
        }, 
        "ansible_date_time": {
            "date": "2013-10-02", 
            "day": "02", 
            "epoch": "1380756810", 
            "hour": "19", 
            "iso8601": "2013-10-02T23:33:30Z", 
            "iso8601_micro": "2013-10-02T23:33:30.036070Z", 
            "minute": "33", 
            "month": "10", 
            "second": "30", 
            "time": "19:33:30", 
            "tz": "EDT", 
            "year": "2013"
        }, 
        "ansible_default_ipv4": {
            "address": "REDACTED", 
            "alias": "eth0", 
            "gateway": "REDACTED", 
            "interface": "eth0", 
            "macaddress": "REDACTED", 
            "mtu": 1500, 
            "netmask": "255.255.255.0", 
            "network": "REDACTED", 
            "type": "ether"
        }, 
        "ansible_default_ipv6": {}, 
        "ansible_devices": {
            "fd0": {
                "holders": [], 
                "host": "", 
                "model": null, 
                "partitions": {}, 
                "removable": "1", 
                "rotational": "1", 
                "scheduler_mode": "deadline", 
                "sectors": "0", 
                "sectorsize": "512", 
                "size": "0.00 Bytes", 
                "support_discard": "0", 
                "vendor": null
            }, 
            "sda": {
                "holders": [], 
                "host": "SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X Fusion-MPT Dual Ultra320 SCSI (rev 01)", 
                "model": "VMware Virtual S", 
                "partitions": {
                    "sda1": {
                        "sectors": "39843840", 
                        "sectorsize": 512, 
                        "size": "19.00 GB", 
                        "start": "2048"
                    }, 
                    "sda2": {
                        "sectors": "2", 
                        "sectorsize": 512, 
                        "size": "1.00 KB", 
                        "start": "39847934"
                    }, 
                    "sda5": {
                        "sectors": "2093056", 
                        "sectorsize": 512, 
                        "size": "1022.00 MB", 
                        "start": "39847936"
                    }
                }, 
                "removable": "0", 
                "rotational": "1", 
                "scheduler_mode": "deadline", 
                "sectors": "41943040", 
                "sectorsize": "512", 
                "size": "20.00 GB", 
                "support_discard": "0", 
                "vendor": "VMware,"
            }, 
            "sr0": {
                "holders": [], 
                "host": "IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE (rev 01)", 
                "model": "VMware IDE CDR10", 
                "partitions": {}, 
                "removable": "1", 
                "rotational": "1", 
                "scheduler_mode": "deadline", 
                "sectors": "2097151", 
                "sectorsize": "512", 
                "size": "1024.00 MB", 
                "support_discard": "0", 
                "vendor": "NECVMWar"
            }
        }, 
        "ansible_distribution": "Ubuntu", 
        "ansible_distribution_release": "precise", 
        "ansible_distribution_version": "12.04", 
        "ansible_domain": "", 
        "ansible_env": {
            "COLORTERM": "gnome-terminal", 
            "DISPLAY": ":0", 
            "HOME": "/home/mdehaan", 
            "LANG": "C", 
            "LESSCLOSE": "/usr/bin/lesspipe %s %s", 
            "LESSOPEN": "| /usr/bin/lesspipe %s", 
            "LOGNAME": "root", 
            "LS_COLORS": "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:", 
            "MAIL": "/var/mail/root", 
            "OLDPWD": "/root/ansible/docsite", 
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", 
            "PWD": "/root/ansible", 
            "SHELL": "/bin/bash", 
            "SHLVL": "1", 
            "SUDO_COMMAND": "/bin/bash", 
            "SUDO_GID": "1000", 
            "SUDO_UID": "1000", 
            "SUDO_USER": "mdehaan", 
            "TERM": "xterm", 
            "USER": "root", 
            "USERNAME": "root", 
            "XAUTHORITY": "/home/mdehaan/.Xauthority", 
            "_": "/usr/local/bin/ansible"
        }, 
        "ansible_eth0": {
            "active": true, 
            "device": "eth0", 
            "ipv4": {
                "address": "REDACTED", 
                "netmask": "255.255.255.0", 
                "network": "REDACTED"
            }, 
            "ipv6": [
                {
                    "address": "REDACTED", 
                    "prefix": "64", 
                    "scope": "link"
                }
            ], 
            "macaddress": "REDACTED", 
            "module": "e1000", 
            "mtu": 1500, 
            "type": "ether"
        }, 
        "ansible_form_factor": "Other", 
        "ansible_fqdn": "ubuntu2.example.com",
        "ansible_hostname": "ubuntu2", 
        "ansible_interfaces": [
            "lo", 
            "eth0"
        ], 
        "ansible_kernel": "3.5.0-23-generic", 
        "ansible_lo": {
            "active": true, 
            "device": "lo", 
            "ipv4": {
                "address": "127.0.0.1", 
                "netmask": "255.0.0.0", 
                "network": "127.0.0.0"
            }, 
            "ipv6": [
                {
                    "address": "::1", 
                    "prefix": "128", 
                    "scope": "host"
                }
            ], 
            "mtu": 16436, 
            "type": "loopback"
        }, 
        "ansible_lsb": {
            "codename": "precise", 
            "description": "Ubuntu 12.04.2 LTS", 
            "id": "Ubuntu", 
            "major_release": "12", 
            "release": "12.04"
        }, 
        "ansible_machine": "x86_64", 
        "ansible_memfree_mb": 74, 
        "ansible_memtotal_mb": 991, 
        "ansible_mounts": [
            {
                "device": "/dev/sda1", 
                "fstype": "ext4", 
                "mount": "/", 
                "options": "rw,errors=remount-ro", 
                "size_available": 15032406016, 
                "size_total": 20079898624
            }
        ], 
        "ansible_nodename": "ubuntu2.example.com",
        "ansible_os_family": "Debian", 
        "ansible_pkg_mgr": "apt", 
        "ansible_processor": [
            "Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz"
        ], 
        "ansible_processor_cores": 1, 
        "ansible_processor_count": 1, 
        "ansible_processor_threads_per_core": 1, 
        "ansible_processor_vcpus": 1, 
        "ansible_product_name": "VMware Virtual Platform", 
        "ansible_product_serial": "REDACTED", 
        "ansible_product_uuid": "REDACTED", 
        "ansible_product_version": "None", 
        "ansible_python_version": "2.7.3", 
        "ansible_selinux": false, 
        "ansible_ssh_host_key_dsa_public": "REDACTED KEY VALUE"
        "ansible_ssh_host_key_ecdsa_public": "REDACTED KEY VALUE"
        "ansible_ssh_host_key_rsa_public": "REDACTED KEY VALUE"
        "ansible_swapfree_mb": 665, 
        "ansible_swaptotal_mb": 1021, 
        "ansible_system": "Linux", 
        "ansible_system_vendor": "VMware, Inc.", 
        "ansible_user_id": "root", 
        "ansible_userspace_architecture": "x86_64", 
        "ansible_userspace_bits": "64", 
        "ansible_virtualization_role": "guest", 
        "ansible_virtualization_type": "VMware"

In the above the model of the first harddrive may be referenced in a template or playbook as::

可以在playbook中这样引用以上例子中第一个硬盘的模型::

    {{ ansible_devices.sda.model }}

Similarly, the hostname as the system reports it is::

同样，作为系统报告的主机名如以下所示::

    {{ ansible_nodename }}

and the unqualified hostname shows the string before the first period(.)::

不合格的主机名显示了句号(.)之前的字符串::

    {{ ansible_hostname }}

Facts are frequently used in conditionals (see :doc:`playbooks_conditionals`) and also in templates.

在模板和条件判断(请看 :doc:`playbook_conditionals`)中会经常使用Facts。

Facts can be also used to create dynamic groups of hosts that match particular criteria, see the :doc:`modules` documentation on 'group_by' for details, as well as in generalized conditional statements as discussed in the :doc:`playbooks_conditionals` chapter.

还可以使用Facts根据特定的条件动态创建主机群组，请查看 :doc:`modules` 文档中的 'group_by' 小节获取详细内容。以及参见 :doc:`playbooks_conditionals` 章节讨论的广义条件语句部分。

.. _disabling_facts:

Turning Off Facts
关闭Facts
`````````````````

If you know you don't need any fact data about your hosts, and know everything about your systems centrally, you
can turn off fact gathering.  This has advantages in scaling Ansible in push mode with very large numbers of
systems, mainly, or if you are using Ansible on experimental platforms.   In any play, just do this::

如果你不需要使用你主机的任何fact数据，你已经知道了你系统的一切，那么你可以关闭fact数据的获取。这有利于增强Ansilbe面对大量系统的push模块，或者你在实验性平台中使用Ansible。在任何playbook中可以这样做::

    - hosts: whatever
      gather_facts: no

.. _local_facts:

Local Facts (Facts.d)
本地Facts(Facts.d)
`````````````````````

.. versionadded:: 1.3

As discussed in the playbooks chapter, Ansible facts are a way of getting data about remote systems for use in playbook variables.

正如在playbook章节讨论的一样，Ansible facts主要用于获取远程系统的数据，从而可以在playbook中作为变量使用。

Usually these are discovered automatically by the 'setup' module in Ansible. Users can also write custom facts modules, as described
in the API guide.  However, what if you want to have a simple way to provide system or user
provided data for use in Ansible variables, without writing a fact module? 

通常facts中的数据是由Ansible中的 ‘setup’模块自动发现的。用户也可以自定义facts模块，在API文档中有说明。然而，如果不借助于fact模块，而是通过一个简单的方式为Ansible变量提供系统或用户数据？ 

For instance, what if you want users to be able to control some aspect about how their systems are managed? "Facts.d" is one such mechanism.

比如，你想用户能够控制受他们管理的系统的一些切面，那么应该怎么做？ "Facts.d"是这样的一种机制。

.. note:: Perhaps "local facts" is a bit of a misnomer, it means "locally supplied user values" as opposed to "centrally supplied user values", or what facts are -- "locally dynamically determined values".

.. 注意:: 可能 "局部facts"有点用词不当，它与 "中心供应的用户值"相对应，为"局部供应的用户值"，或者facts是 "局部动态测定的值"。

If a remotely managed system has an "/etc/ansible/facts.d" directory, any files in this directory
ending in ".fact", can be JSON, INI, or executable files returning JSON, and these can supply local facts in Ansible.

如果远程受管理的机器有一个 "/etc/ansible/facts.d" 目录，那么在该目录中任何以 ".fact"结尾的文件都可以在Ansible中提供局部facts。这些文件可以是JSON,INI或者任何可以返回JSON的可执行文件。

For instance assume a /etc/ansible/facts.d/preferences.fact::

例如建设有一个 /etc/ansible/facts.d/perferences.fact文件::

    [general]
    asdf=1
    bar=2

This will produce a hash variable fact named "general" with 'asdf' and 'bar' as members.
To validate this, run the following::

这将产生一个名为 "general" 的哈希表fact，里面成员有 'asdf' 和 'bar'。
可以这样验证::

    ansible <hostname> -m setup -a "filter=ansible_local"

And you will see the following fact added::

然后你会看到有以下fact被添加::

    "ansible_local": {
            "preferences": {
                "general": {
                    "asdf" : "1",
                    "bar"  : "2"
                }
            }
     }

And this data can be accessed in a template/playbook as::

而且也可以在template或palybook中访问该数据::

     {{ ansible_local.preferences.general.asdf }}

The local namespace prevents any user supplied fact from overriding system facts
or variables defined elsewhere in the playbook.

本地命名空间放置其它用户提供的fact或者playbook中定义的变量覆盖系统facts值。

If you have a playbook that is copying over a custom fact and then running it, making an explicit call to re-run the setup module
can allow that fact to be used during that particular play.  Otherwise, it will be available in the next play that gathers fact information.
Here is an example of what that might look like::

如果你有个一个playook，它复制了一个自定义的fact，然后运行它，请显式调用来重新运行setup模块，这样可以让我们在该playbook中使用这些fact。否则，在下一个play中才能获取这些自定义的fact信息。这里有一个示例::

  - hosts: webservers
    tasks:
      - name: create directory for ansible custom facts
        file: state=directory recurse=yes path=/etc/ansible/facts.d
      - name: install custom impi fact
        copy: src=ipmi.fact dest=/etc/ansible/facts.d
      - name: re-read facts after adding custom fact
        setup: filter=ansible_local

In this pattern however, you could also write a fact module as well, and may wish to consider this as an option.

然而在该模式中你也可以编写一个fact模块，这只不过是多了一个选项。

.. _fact_caching:

Fact Caching

Fact缓存
````````````

.. versionadded:: 1.8

As shown elsewhere in the docs, it is possible for one server to reference variables about another, like so::

正如该文档中其它地方所示，从一个服务器引用另一个服务器的变量是可行的。比如::

    {{ hostvars['asdf.example.com']['ansible_os_family'] }}

With "Fact Caching" disabled, in order to do this, Ansible must have already talked to 'asdf.example.com' in the
current play, or another play up higher in the playbook.  This is the default configuration of ansible.

如果禁用 "Fact Caching",为了实现以上功能，Ansible在当前play之前已经与 'asdf.example.com' 通讯过，或者在playbook有其它优先的play。这是ansible的默认配置。

To avoid this, Ansible 1.8 allows the ability to save facts between playbook runs, but this feature must be manually
enabled.  Why might this be useful?

为了避免这些，Ansible 1.8允许在playbook运行期间保存facts。但该功能需要手动开启。这有什么用处那？

Imagine, for instance, a very large infrastructure with thousands of hosts.  Fact caching could be configured to run nightly, but
configuration of a small set of servers could run ad-hoc or periodically throughout the day.  With fact-caching enabled, it would
not be necessary to "hit" all servers to reference variables and information about them.

想象一下，如果我们有一个非常大的基础设施，里面有数千个主机。Fact缓存可以配置在夜间运行，但小型服务器集群可以配置fact随时运行，或者在白天定期运行。即使开启了fact缓存，也不需要访问所有服务器来引用它们的变量和信息。

With fact caching enabled, it is possible for machine in one group to reference variables about machines in the other group, despite
the fact that they have not been communicated with in the current execution of /usr/bin/ansible-playbook.

使用fact缓存可以跨群组访问变量，即使群组间在当前/user/bin/ansible-playbook执行中并没有通讯过。

To benefit from cached facts, you will want to change the 'gathering' setting to 'smart' or 'explicit' or set 'gather_facts' to False in most plays.

为了启用fact缓存，在大多数plays中你可以修改 'gathering' 设置为 'smart' 或者 'explicit'，也可以设置 'gather_facts' 为False。

Currently, Ansible ships with two persistent cache plugins: redis and jsonfile.

当前，Ansible可以使用两种持久的缓存插件: redis和jsonfile。

To configure fact caching using redis, enable it in ansible.cfg as follows::

可以在ansible.cfg中配置fact缓存使用redis::

    [defaults]
    gathering = smart
    fact_caching = redis
    fact_caching_timeout = 86400
    # seconds

To get redis up and running, perform the equivalent OS commands::

请执行适当的系统命令来启动和运行redis::

    yum install redis
    service redis start
    pip install redis

Note that the Python redis library should be installed from pip, the version packaged in EPEL is too old for use by Ansible.

请注意可以使用pip来安装Python redis库，在EPEL中的包版本对Ansible来说太旧了。

In current embodiments, this feature is in beta-level state and the Redis plugin does not support port or password configuration, this is expected to change in the near future.

在当前Ansible版本中，该功能还处于试用状态，Redis插件还不支持端口或密码配置，以后会改善这点。

To configure fact caching using jsonfile, enable it in ansible.cfg as follows::

在ansible.cfg中使用以下代码来配置fact缓存使用jsonfile::

    [defaults]
    gathering = smart
    fact_caching = jsonfile
    fact_caching_connection = /path/to/cachedir
    fact_caching_timeout = 86400
    # seconds

`fact_caching_connection` is a local filesystem path to a writeable
directory (ansible will attempt to create the directory if one does not exist).

`fact_caching_connection` 是一个放置在可读目录(如果目录不存在，ansible会试图创建它)中的本地文件路径。

.. _registered_variables:

Registered Variables
注册变量
````````````````````

Another major use of variables is running a command and using the result of that command to save the result into a variable. Results will vary from module to module. Use of -v when executing playbooks will show possible values for the results.

变量的另一个主要用途是在运行命令时，把命令结果存储到一个变量中。不同模块的执行结果是不同的。运行playbook时使用-v选项可以看到可能的结果值。

The value of a task being executed in ansible can be saved in a variable and used later.  See some examples of this in the
:doc:`playbooks_conditionals` chapter.

在ansible执行任务的结果值可以保存在变量中，以便稍后使用它。在 :doc:`playbooks_conditionals`章节有一些示例。

While it's mentioned elsewhere in that document too, here's a quick syntax example::

这里有一个语法示例，在上面文档中也有所提及::

   - hosts: web_servers

     tasks:

        - shell: /usr/bin/foo
          register: foo_result
          ignore_errors: True

        - shell: /usr/bin/bar
          when: foo_result.rc == 5

Registered variables are valid on the host the remainder of the playbook run, which is the same as the lifetime of "facts"
in Ansible.  Effectively registered variables are just like facts.

在当前主机接下来playbook运行过程中注册的变量是有效地。这与Ansile中的 "facts" 生命周期一样。 实际上注册变量和facts很相似。

.. _accessing_complex_variable_data:

Accessing Complex Variable Data
访问复杂变量数据
```````````````````````````````

We already talked about facts a little higher up in the documentation.

在该文档中我们已经讨论了一些与facts有关的高级特性。

Some provided facts, like networking information, are made available as nested data structures.  To access
them a simple {{ foo }} is not sufficient, but it is still easy to do.   Here's how we get an IP address::

有些提供的facts，比如网络信息等，是一个嵌套的数据结构。访问它们使用简单的 {{ foo }} 语法并不够用，当仍然很容易。如下所示::

    {{ ansible_eth0["ipv4"]["address"] }}

OR alternatively::

或者这样写::

    {{ ansible_eth0.ipv4.address }}

Similarly, this is how we access the first element of an array::

相似的，以下代码展示了我们如何访问数组的第一个元素::

    {{ foo[0] }}

.. _magic_variables_and_hostvars:

Magic Variables, and How To Access Information About Other Hosts
魔法变量，以及如何访问其它主机的信息
````````````````````````````````````````````````````````````````

Even if you didn't define them yourself, Ansible provides a few variables for you automatically.
The most important of these are 'hostvars', 'group_names', and 'groups'.  Users should not use
these names themselves as they are reserved.  'environment' is also reserved.

Ansible会自动提供给你一些变量，即使你并没有定义过它们。这些变量中重要的有 'hostvars'，'group_names'，和 'groups'。由于这些变量名是预留的，所以用户不应当覆盖它们。 'environmen' 也是预留的。

Hostvars lets you ask about the variables of another host, including facts that have been gathered
about that host.  If, at this point, you haven't talked to that host yet in any play in the playbook
or set of playbooks, you can get at the variables, but you will not be able to see the facts.

hostvars可以让你访问其它主机的变量，包括哪些主机中获取到的facts。如果你还没有在当前playbook或者一组playbook的任何play中访问那个主机，那么你可以获取变量，但无法看到facts值。

If your database server wants to use the value of a 'fact' from another node, or an inventory variable
assigned to another node, it's easy to do so within a template or even an action line::

如果数据库服务器想使用另一个节点的某个 'fact' 值，或者赋值给该节点的一个inventory变量。可以在一个模板中甚至命令行中轻松实现::

    {{ hostvars['test.example.com']['ansible_distribution'] }}

Additionally, *group_names* is a list (array) of all the groups the current host is in.  This can be used in templates using Jinja2 syntax to make template source files that vary based on the group membership (or role) of the host::

另外， *group_names* 是当前主机所在所有群组的列表(数组)。所以可以使用Jinja2语法在模板中根据该主机所在群组关系(或角色)来产生变化。

   {% if 'webserver' in group_names %}
      # some part of a configuration file that only applies to webservers
   {% endif %}

*groups* is a list of all the groups (and hosts) in the inventory.  This can be used to enumerate all hosts within a group.
For example::

*groups* 是inventory中所有群组(主机)的列表。可用于枚举群组中的所有主机。例如::

   {% for host in groups['app_servers'] %}
      # something that applies to all app servers.
   {% endfor %}

A frequently used idiom is walking a group to find all IP addresses in that group::

一个经常使用的范式是找出该群组中的所有IP地址::

   {% for host in groups['app_servers'] %}
      {{ hostvars[host]['ansible_eth0']['ipv4']['address'] }}
   {% endfor %}

An example of this could include pointing a frontend proxy server to all of the app servers, setting up the correct firewall rules between servers, etc.
You need to make sure that the facts of those hosts have been populated before though, for example by running a play against them if the facts have not been cached recently (fact caching was added in Ansible 1.8).

比如，一个前端代理服务器需要指向所有的应用服务器，在服务器间设置正确的防火墙规则等。你需要确保所有主机的facts在使用前都已被获取到，例如运行一个play来检查这些facts是否已经被缓存起来(fact缓存是Ansible 1.8中的新特性)。

Additionally, *inventory_hostname* is the name of the hostname as configured in Ansible's inventory host file.  This can
be useful for when you don't want to rely on the discovered hostname `ansible_hostname` or for other mysterious
reasons.  If you have a long FQDN, *inventory_hostname_short* also contains the part up to the first
period, without the rest of the domain.

*play_hosts* is available as a list of hostnames that are in scope for the current play. This may be useful for filling out templates with multiple hostnames or for injecting the list into the rules for a load balancer.

*delegate_to* is the inventory hostname of the host that the current task has been delegated to using 'delegate_to'.

Don't worry about any of this unless you think you need it.  You'll know when you do.

Also available, *inventory_dir* is the pathname of the directory holding Ansible's inventory host file, *inventory_file* is the pathname and the filename pointing to the Ansible's inventory host file.

And finally, *role_path* will return the current role's pathname (since 1.8). This will only work inside a role.

.. _variable_file_separation_details:

Variable File Separation
````````````````````````

It's a great idea to keep your playbooks under source control, but
you may wish to make the playbook source public while keeping certain
important variables private.  Similarly, sometimes you may just
want to keep certain information in different files, away from
the main playbook.

You can do this by using an external variables file, or files, just like this::

    ---

    - hosts: all
      remote_user: root
      vars:
        favcolor: blue
      vars_files:
        - /vars/external_vars.yml

      tasks:

      - name: this is just a placeholder
        command: /bin/echo foo

This removes the risk of sharing sensitive data with others when
sharing your playbook source with them.

The contents of each variables file is a simple YAML dictionary, like this::

    ---
    # in the above example, this would be vars/external_vars.yml
    somevar: somevalue
    password: magic

.. note::
   It's also possible to keep per-host and per-group variables in very
   similar files, this is covered in :ref:`splitting_out_vars`.

.. _passing_variables_on_the_command_line:

Passing Variables On The Command Line
`````````````````````````````````````

In addition to `vars_prompt` and `vars_files`, it is possible to send variables over
the Ansible command line.  This is particularly useful when writing a generic release playbook
where you may want to pass in the version of the application to deploy::

    ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"

This is useful, for, among other things, setting the hosts group or the user for the playbook.

Example::

    ---

    - hosts: '{{ hosts }}'
      remote_user: '{{ user }}'

      tasks:
         - ...

    ansible-playbook release.yml --extra-vars "hosts=vipers user=starbuck"

As of Ansible 1.2, you can also pass in extra vars as quoted JSON, like so::

    --extra-vars '{"pacman":"mrs","ghosts":["inky","pinky","clyde","sue"]}'

The key=value form is obviously simpler, but it's there if you need it!

As of Ansible 1.3, extra vars can be loaded from a JSON file with the "@" syntax::

    --extra-vars "@some_file.json"

Also as of Ansible 1.3, extra vars can be formatted as YAML, either on the command line
or in a file as above.

.. _variable_precedence:

Variable Precedence: Where Should I Put A Variable?
```````````````````````````````````````````````````

A lot of folks may ask about how variables override another.  Ultimately it's Ansible's philosophy that it's better
you know where to put a variable, and then you have to think about it a lot less.  

Avoid defining the variable "x" in 47 places and then ask the question "which x gets used".  
Why?  Because that's not Ansible's Zen philosophy of doing things.

There is only one Empire State Building. One Mona Lisa, etc.  Figure out where to define a variable, and don't make
it complicated.

However, let's go ahead and get precedence out of the way!  It exists.  It's a real thing, and you might have
a use for it.

If multiple variables of the same name are defined in different places, they win in a certain order, which is::

    * extra vars (-e in the command line) always win
    * then comes connection variables defined in inventory (ansible_ssh_user, etc)
    * then comes "most everything else" (command line switches, vars in play, included vars, role vars, etc)
    * then comes the rest of the variables defined in inventory
    * then comes facts discovered about a system
    * then "role defaults", which are the most "defaulty" and lose in priority to everything.

.. note:: In versions prior to 1.5.4, facts discovered about a system were in the "most everything else" category above.

That seems a little theoretical.  Let's show some examples and where you would choose to put what based on the kind of 
control you might want over values.

First off, group variables are super powerful.

Site wide defaults should be defined as a 'group_vars/all' setting.  Group variables are generally placed alongside
your inventory file.  They can also be returned by a dynamic inventory script (see :doc:`intro_dynamic_inventory`) or defined
in things like :doc:`tower` from the UI or API::

    ---
    # file: /etc/ansible/group_vars/all
    # this is the site wide default
    ntp_server: default-time.example.com

Regional information might be defined in a 'group_vars/region' variable.  If this group is a child of the 'all' group (which it is, because all groups are), it will override the group that is higher up and more general::

    ---
    # file: /etc/ansible/group_vars/boston
    ntp_server: boston-time.example.com 

If for some crazy reason we wanted to tell just a specific host to use a specific NTP server, it would then override the group variable!::

    ---
    # file: /etc/ansible/host_vars/xyz.boston.example.com
    ntp_server: override.example.com

So that covers inventory and what you would normally set there.  It's a great place for things that deal with geography or behavior.  Since groups are frequently the entity that maps roles onto hosts, it is sometimes a shortcut to set variables on the group instead of defining them on a role.  You could go either way.

Remember:  Child groups override parent groups, and hosts always override their groups.

Next up: learning about role variable precedence.

We'll pretty much assume you are using roles at this point.  You should be using roles for sure.  Roles are great.  You are using
roles aren't you?  Hint hint.  

Ok, so if you are writing a redistributable role with reasonable defaults, put those in the 'roles/x/defaults/main.yml' file.  This means
the role will bring along a default value but ANYTHING in Ansible will override it.  It's just a default.  That's why it says "defaults" :)
See :doc:`playbooks_roles` for more info about this::

    ---
    # file: roles/x/defaults/main.yml
    # if not overridden in inventory or as a parameter, this is the value that will be used
    http_port: 80

if you are writing a role and want to ensure the value in the role is absolutely used in that role, and is not going to be overridden
by inventory, you should put it in roles/x/vars/main.yml like so, and inventory values cannot override it.  -e however, still will::

    ---
    # file: roles/x/vars/main.yml
    # this will absolutely be used in this role
    http_port: 80

So the above is a great way to plug in constants about the role that are always true.  If you are not sharing your role with others,
app specific behaviors like ports is fine to put in here.  But if you are sharing roles with others, putting variables in here might
be bad. Nobody will be able to override them with inventory, but they still can by passing a parameter to the role.

Parameterized roles are useful.

If you are using a role and want to override a default, pass it as a parameter to the role like so::

    roles:
       - { role: apache, http_port: 8080 }

This makes it clear to the playbook reader that you've made a conscious choice to override some default in the role, or pass in some
configuration that the role can't assume by itself.  It also allows you to pass something site-specific that isn't really part of the
role you are sharing with others.

This can often be used for things that might apply to some hosts multiple times,
like so::

    roles:
       - { role: app_user, name: Ian    }
       - { role: app_user, name: Terry  }
       - { role: app_user, name: Graham }
       - { role: app_user, name: John   }

That's a bit arbitrary, but you can see how the same role was invoked multiple Times.  In that example it's quite likely there was
no default for 'name' supplied at all.  Ansible can yell at you when variables aren't defined -- it's the default behavior in fact.

So that's a bit about roles.

There are a few bonus things that go on with roles.

Generally speaking, variables set in one role are available to others.  This means if you have a "roles/common/vars/main.yml" you
can set variables in there and make use of them in other roles and elsewhere in your playbook::

     roles:
        - { role: common_settings }
        - { role: something, foo: 12 }
        - { role: something_else }

.. note:: There are some protections in place to avoid the need to namespace variables.  
          In the above, variables defined in common_settings are most definitely available to 'something' and 'something_else' tasks, but if
          "something's" guaranteed to have foo set at 12, even if somewhere deep in common settings it set foo to 20.

So, that's precedence, explained in a more direct way.  Don't worry about precedence, just think about if your role is defining a
variable that is a default, or a "live" variable you definitely want to use.  Inventory lies in precedence right in the middle, and
if you want to forcibly override something, use -e.

If you found that a little hard to understand, take a look at the `ansible-examples`_ repo on our github for a bit more about
how all of these things can work together.

如果你还感觉有点难以理解，你可以学习我们放在github中的 `ansible-examples`_ 代码库，来了解这些东西是如何一起协作的。

.. _ansible-examples: https://github.com/ansible/ansible-examples
.. _builtin filters: http://jinja.pocoo.org/docs/templates/#builtin-filters

.. seealso::

   :doc:`playbooks`
       An introduction to playbooks
   :doc:`playbooks_conditionals`
       Conditional statements in playbooks
   :doc:`playbooks_filters`
       Jinja2 filters and their uses
   :doc:`playbooks_loops`
       Looping in playbooks
   :doc:`playbooks_roles`
       Playbook organization by roles
   :doc:`playbooks_best_practices`
       Best practices in playbooks
   `User Mailing List <http://groups.google.com/group/ansible-devel>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel


