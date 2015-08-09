.. _dynamic_inventory:

动态 Inventory
=================

.. contents:: Topics

使用配置管理系统经常有一种需求，需要在其他的软件系统中保存自己的 inventory 配置信息。

Ansible 是通过一种基于文本的方式来记录 inventory 配置信息，前面介绍过(详见 :doc:`intro_inventory` )。 

而 Ansible 也支持用其他方式保存配置信息。

在其他软件系统保存配置信息的例子：
1， 从云端拉取 inventory,
2， LDAP(Lightweight Directory Access Protocol，轻量级目录访问协议)
3， `Cobbler <http://cobbler.github.com>`_ 
4， 或者是一份昂贵的企业版的 CMDB(配置管理数据库) 软件。

对于这些需求，Ansible 通过一个外部 inventory 系统来支持。而在插件目录包已经含有一些选项 -- 包括 EC2/Eucalyptus, Rackspace Cloud, and OpenStack, 稍后会详细介绍它们。

Ansible :doc:`tower` 提供了一个数据库来存储 inventory 配置信息, 这个数据库可以通过 web 访问，或通过 REST 访问。
Tower 与所有你使用的 Ansible 动态 inventory 源保持同步，并提供了一个图形化的 inventory 编辑器。
有了这个数据库，便可以很容易的关联过去的事件历史，可以看到在上一次 playbook 运行时，哪里出现了运行失败的情况。

关于如何编写你自己的动态 inventory 源，请参见 :doc:`developing_inventory`.

.. _cobbler_example:


Cobbler 外部 Inventory 脚本
``````````````````````````````````````````````

在管理的物理硬件到达了一定数量的时，很多 Ansible 用户可能也会使用到 `Cobbler <http://cobbler.github.com>`_ 。
(注: Cobbler 最初由 Michael DeHaan 编写，现在项目主导人是 James Cammarata, 他目前在 Ansible 公司工作).

Cobbler 主要用于操作系统的 kickoff 安装，管理 DHCP 和 DNS, 而除此之外，它也有一个通用层，允许它为多种配置管理系统(甚至是同时的)提供数据。
所以 Cobbler 也被一些管理员称为是轻量级的 CMDB。

如何将 Ansible 的 inventory 与 Cobbler 联系起来呢？方法是:
将脚本 `script <https://raw.github.com/ansible/ansible/devel/plugins/inventory/cobbler.py>`_ 拷贝到 /etc/ansible，通过 `chmod +x` 赋予可执行权限。

在使用 Ansible 之前，要先启动 cobblerd 进程。

现在使用 Ansible 需要加上  ``-i`` 选项 (e.g. ``-i /etc/ansible/cobbler.py``)。这个脚本使用 Cobbler 的 XMLRPC API 与 Cobbler 通信。

执行脚本 ``/etc/ansible/cobbler.py`` ，应该能看到一些 JSON 格式的数据输出(也许还没有具体的内容)。

在 cobbler 中，假设有一个如下的场景::

    cobbler profile add --name=webserver --distro=CentOS6-x86_64
    cobbler profile edit --name=webserver --mgmt-classes="webserver" --ksmeta="a=2 b=3"
    cobbler system edit --name=foo --dns-name="foo.example.com" --mgmt-classes="atlanta" --ksmeta="c=4"
    cobbler system edit --name=bar --dns-name="bar.example.com" --mgmt-classes="atlanta" --ksmeta="c=5"

'foo.example.com' 是一个域名，Ansible 可以通过这个域名寻址找到对应的主机foo，对其进行操作。也可以通过组名 'webserver' 或者 'atlanta' 寻址找到这个主机，只要这个主机是属于这两个组的。直接使用 foo 是不行的。例如执行命令 "ansible foo" ，无法找到该主机，但使用 "ansible 'foo*'" 却可以，因为域名 'foo.example.com' 以foo开头。


这个脚本不仅提供主机和组的信息。如果运行了 'setup' 模块(只要使用 playbooks，'setup' 模块自动运行)，变量 a, b, c 可按照以下模板自动填充::

    # file: /srv/motd.j2
    Welcome, I am templated with a value of a={{ a }}, b={{ b }}, and c={{ c }}

模板的使用如下::

    ansible webserver -m setup
    ansible webserver -m template -a "src=/tmp/motd.j2 dest=/etc/motd"


.. note::
   组名 'webserver' 是 cobbler 中定义的。你仍然可以在 Ansible 的配置文件中定义变量。
   但要注意，变量名相同时，外部 inventory 脚本中定义的变量会覆盖 Ansible 中的变量。


执行上面命令后，主机 foo 的/etc/motd文件被写入如下的内容::

    Welcome, I am templated with a value of a=2, b=3, and c=4

主机 'bar' (bar.example.com)的 /etc/motd 中写入如下内容::

    Welcome, I am templated with a value of a=2, b=3, and c=5

你也可以通过下面这个命令测试变量的替换::

    ansible webserver -m shell -a "echo {{ a }}"

也就是说，你可以在参数或命令操作中使用变量的替换。


.. _aws_example:

AWS EC2 外部 Inventory 脚本
``````````````````````````````````````````

如果使用 AWC EC2，那么保存一份 inventory 文件在有些时候不是最好的方法。因为主机的数量有可能变动，或者主机是由外部的应用管理的，或者使用了 AWS autoscaling。你可以使用 `EC2 external inventory  <https://raw.github.com/ansible/ansible/devel/plugins/inventory/ec2.py>`_ 脚本。

脚本的使用方式有两种，最简单的是直接使用 Ansible 的命令行选项 ``-i`` ，指定脚本的路径(脚本要有可执行权限)::

    ansible -i ec2.py -u ubuntu us-east-1d -m ping

第二种方式，把脚本拷贝为 `/etc/ansible/hosts` ，并赋予可执行权限。还需把 `ec2.ini  <https://raw.githubusercontent.com/ansible/ansible/devel/plugins/inventory/ec2.ini>`_ 文件拷贝到 `/etc/ansible/ec2.ini`，然后运行 ansible。

要成功的调用 API 访问 AWS，需要配置 Boto (AWS 的 Python 接口)。方法有多种： `variety of methods <http://docs.pythonboto.org/en/latest/boto_config_tut.html>`_ ，最简单的方法是定义两个环境变量::

    export AWS_ACCESS_KEY_ID='AK123'
    export AWS_SECRET_ACCESS_KEY='abc123'

如何知道配置是否正确，执行脚本来测试::

    cd plugins/inventory
    ./ec2.py --list

你可以看到以 JSON 格式表示的覆盖所有 regions 的 inventory 信息。

因为每一个 region 需要自己的 API 调用，如果你仅适用了所有 regions 的一个子集，可以编辑 ``ec2.ini`` ，使之仅显示你所感兴趣的那些 regions。
在配置文件 ``ec2.ini`` 中，包含了其他配置选项，包括缓存控制和目的地址变量。

inventory 文件的核心部分，是一些名字到目的地址的映射。默认的 ``ec2.ini`` 设置适用于在 EC2 之外运行 Ansible(比如一台笔记本电脑)，但这不是最有效的方式。

在 EC2 内部运行 Ansible 的话，内部的 DNS 名和 IP 地址比公共 DNS 名更容易理解。你可以在 ``ec2.ini`` 文件中修改 ``destination_variable`` 变量，
改为一个实例的私有 DNS 名。这对于在私有子网中的 VPC 上运行 Ansible 是很重要的，使我们不仅可以使用内部IP地址访问到一个VPC。在 ``ec2.ini`` 文件中，
`vpc_destination_variable` 可以命名为任意一个 `boto.ec2.instance variable <http://docs.pythonboto.org/en/latest/ref/ec2.html#module-boto.ec2.instance>`_ 变量。


EC2 外部 inventory 提供了一种从多个组到实例的映射:

Global
全局
  所有的实例都属于 ``ec2``这个组。

Instance ID
实例ID
  e.g.
  ``i-00112233``
  ``i-a1b1c1d1``
  

Region
  属于一个 AWS region 的所有实例构成的一个组。
  e.g.
  ``us-east-1``
  ``us-west-2``

Availability Zone
可用性区域
  所有属于 availability zone 的实例构成一个组。
  e.g.
  ``us-east-1a``
  ``us-east-1b``

Security Group
安全组
  实例可属于一个或多个安全组。每一个组的前缀都是 ``security_group_``，符号(-) 已被转换为(_). with all characters except alphanumerics (这句没明白)
  
  e.g.
  ``security_group_default``
  ``security_group_webservers``
  ``security_group_Pete_s_Fancy_Group``

Tags
标签
  每一个实例可有多个不同的 key/value 键值对，这些键值对被称为标签。标签名可以随意定义，最常见的标签是 'Name'。每一个键值对是这个实例自己的组。
  特殊字符已转换为下划线，格式为 ``tag_KEY_VALUE``
  e.g.
  ``tag_Name_Web``
  ``tag_Name_redis-master-001``
  ``tag_aws_cloudformation_logical-id_WebServerGroup``

使用 Ansible 与指定的服务器进行交互时，EC2 inventory 脚本会被再次调用(加上了命令行选项  ``--host HOST`` )。在索引缓存中查找，取得实例 ID，然后
调用 API 访问 AWS, 获取指定实例的所有信息。这些信息被转换为 playbooks 中的变量，可以进行访问。每一个变量的前缀为 ``ec2_``，下面是一些变量的示例:

- ec2_architecture
- ec2_description
- ec2_dns_name
- ec2_id
- ec2_image_id
- ec2_instance_type
- ec2_ip_address
- ec2_kernel
- ec2_key_name
- ec2_launch_time
- ec2_monitored
- ec2_ownerId
- ec2_placement
- ec2_platform
- ec2_previous_state
- ec2_private_dns_name
- ec2_private_ip_address
- ec2_public_dns_name
- ec2_ramdisk
- ec2_region
- ec2_root_device_name
- ec2_root_device_type
- ec2_security_group_ids
- ec2_security_group_names
- ec2_spot_instance_request_id
- ec2_state
- ec2_state_code
- ec2_state_reason
- ec2_status
- ec2_subnet_id
- ec2_tag_Name
- ec2_tenancy
- ec2_virtualization_type
- ec2_vpc_id

其中，``ec2_security_group_ids`` 和 ``ec2_security_group_names`` 的值是所有安全组的列表，使用逗号分隔。每一个 EC2 标签是一个格式为 ``ec2_tag_KEY`` 的变量。

要查看一个实例的完整的可用变量的列表，执行脚本::

    cd plugins/inventory
    ./ec2.py --host ec2-12-12-12-12.compute-1.amazonaws.com

注意，AWS inventory 脚本会将结果进行缓存，以避免重复的 API 调用，这个缓存的设置可在 ec2.ini 文件中配置。要显式地清空缓存，你可以加上 ``--refresh-cache`` 选项，执行脚本如下::

    # ./ec2.py --refresh-cache

.. _other_inventory_scripts:

Other inventory scripts
```````````````````````

In addition to Cobbler and EC2, inventory scripts are also available for::

   BSD Jails
   DigitalOcean
   Google Compute Engine
   Linode
   OpenShift
   OpenStack Nova
   Red Hat's SpaceWalk
   Vagrant (not to be confused with the provisioner in vagrant, which is preferred)
   Zabbix

Sections on how to use these in more detail will be added over time, but by looking at the "plugins/" directory of the Ansible checkout
it should be very obvious how to use them.  The process for the AWS inventory script is the same.

If you develop an interesting inventory script that might be general purpose, please submit a pull request -- we'd likely be glad
to include it in the project.

.. _using_multiple_sources:

Using Multiple Inventory Sources
````````````````````````````````

If the location given to -i in Ansible is a directory (or as so configured in ansible.cfg), Ansible can use multiple inventory sources
at the same time.  When doing so, it is possible to mix both dynamic and statically managed inventory sources in the same ansible run.  Instant
hybrid cloud!

.. _static_groups_of_dynamic:

Static Groups of Dynamic Groups
```````````````````````````````

When defining groups of groups in the static inventory file, the child groups
must also be defined in the static inventory file, or ansible will return an
error. If you want to define a static group of dynamic child groups, define
the dynamic groups as empty in the static inventory file. For example::

    [tag_Name_staging_foo]

    [tag_Name_staging_bar]

    [staging:children]
    tag_Name_staging_foo
    tag_Name_staging_bar



.. seealso::

   :doc:`intro_inventory`
       All about static inventory files
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

