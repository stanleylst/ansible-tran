.. _dynamic_inventory:

动态 Inventory
=================

.. contents:: Topics

配置管理系统的用户经常会有一种需求，即在不同的软件系统中保存 inventory。Ansible 提供一种基于文本的系统(详见 :doc:`intro_inventory` )，
但如果你想使用其他的方式保存呢？

一些常见的例子如：从云端拉取 inventory, LDAP(Lightweight Directory Access Protocol，轻量级目录访问协议)，`Cobbler <http://cobbler.github.com>`_, 
或者是一份昂贵的企业版的 CMDB(配置管理数据库) 软件。

Ansible 通过外部 inventory 系统支持以上的选择。插件目录包已经含有一些选项 -- 包括 EC2/Eucalyptus, Rackspace Cloud, and OpenStack, 稍后会详细介绍它们。


:doc: `tower` 也提供了一个数据库来存储 inventory , 支持 web 或 REST 访问。Tower 与所有你使用的 Ansible 动态 inventory 源保持同步，也提供一个
图形化的 inventory 编辑器。有了记录着你的所有主机的数据库记录，便可以关联过去的事件历史，可以看到在上一次 playbook 运行时，哪一个出现了运行失败的情况。

更多关于如何编写你自己的动态 inventory 源的信息，请参见 :doc:`developing_inventory`.

.. _cobbler_example:

示例：外部 Inventory 脚本之 Cobbler
``````````````````````````````````````````````

可以预料的是，很多 Ansible 用户在管理一定的，合理的数量的物理硬件时，可能也是 `Cobbler <http://cobbler.github.com>`_ 的用户。
(注释: Cobbler 最初由 Michael DeHaan 编写，现在项目主导人是 James Cammarata, 他目前在 Ansible 公司工作).

Cobbler 除了主要用于操作系统的 kickoff 安装，管理 DHCP 和 DNS, 它也有一个通用层，允许它为多种配置管理系统(甚至是同时的)表示数据。
所以也被一些管理员称为是 轻量级的 CMDB.


将 Ansible 的 inventory 与 Cobbler 联系起来的方法:  将脚本 `script <https://raw.github.com/ansible/ansible/devel/plugins/inventory/cobbler.py>`_ 拷贝到 /etc/ansible, 通过 `chmod +x` 赋予可执行权限。现在使用 Ansible 之前，cobblerd 进程需要先运行起来。现在使用 Ansible 需要加上  ``-i`` 选项 (e.g. ``-i /etc/ansible/cobbler.py``). 这个脚本会与 Cobbler 通信， 使用 Cobbler 的 XMLRPC API。


首先，直接运行 ``/etc/ansible/cobbler.py`` ，测试是否能正常运行。你应该看到一些 JSON 格式的输出数据，但是里面可能还没有具体的内容。


让我们探索一下它能做什么。在 cobbler 中，假设一个场景如下::

    cobbler profile add --name=webserver --distro=CentOS6-x86_64
    cobbler profile edit --name=webserver --mgmt-classes="webserver" --ksmeta="a=2 b=3"
    cobbler system edit --name=foo --dns-name="foo.example.com" --mgmt-classes="atlanta" --ksmeta="c=4"
    cobbler system edit --name=bar --dns-name="bar.example.com" --mgmt-classes="atlanta" --ksmeta="c=5"

上面这个例子中, system 中的 'foo.example.com' 将直接被 ansible 寻址, 但在使用组 'webserver' 或 'atlanta' 时也将被寻址. 因为 Ansible使用的是 SSH，所以我们可以而且只能通过'foo.example.com' 来connect system foo,如果只是 'foo' 则找不到.类似的,如果你尝试使用 "ansible foo" 也无法找到 system...但是 "ansible 'foo*'" 是可以的,因为 system DNS name 是以 foo 开头的.

该脚本不仅提供了主机和组信息. 额外的,作为奖励,当 'setup' 模块运行的时候(当使用 playbooks 时会自动运行), 'a','b','c' 变量会自动填充到模块::

    # file: /srv/motd.j2
    Welcome, I am templated with a value of a={{ a }}, b={{ b }}, and c={{ c }}

可以像如下方式运行::

    ansible webserver -m setup
    ansible webserver -m template -a "src=/tmp/motd.j2 dest=/etc/motd"

.. note::

   'webserver' 来自cobbler, 配置文件中的变量也一样. 你可以像往常一样在 Ansible中声明变量,但是如果引用自外部inventory脚本的变量名和声名的脚本名称冲突一样,那么你声明的变量将会被外部inventory脚本中的变量值所覆盖.

所以,在应用如上示例的的模板时(motd.j2),会导致system 'foo' 被写入 /etc/motd 中::

    Welcome, I am templated with a value of a=2, b=3, and c=4

还有 system 'bar' (bar.example.com)::

    Welcome, I am templated with a value of a=2, b=3, and c=5

从技术上来讲,虽然没有非常好的理由推荐如下方式,但它确实能正常工作::

    ansible webserver -m shell -a "echo {{ a }}"

换而言之,你可以在 arguments/actions 中同样使用那些变量.

.. _aws_example:

Example: AWS EC2 External Inventory Script
``````````````````````````````````````````

If you use Amazon Web Services EC2, maintaining an inventory file might not be the best approach, because hosts may come and go over time, be managed by external applications, or you might even be using AWS autoscaling. For this reason, you can use the `EC2 external inventory  <https://raw.github.com/ansible/ansible/devel/plugins/inventory/ec2.py>`_ script.

You can use this script in one of two ways. The easiest is to use Ansible's ``-i`` command line option and specify the path to the script after
marking it executable::

    ansible -i ec2.py -u ubuntu us-east-1d -m ping

The second option is to copy the script to `/etc/ansible/hosts` and `chmod +x` it. You will also need to copy the `ec2.ini  <https://raw.githubusercontent.com/ansible/ansible/devel/plugins/inventory/ec2.ini>`_ file to `/etc/ansible/ec2.ini`. Then you can run ansible as you would normally.

To successfully make an API call to AWS, you will need to configure Boto (the Python interface to AWS). There are a `variety of methods <http://docs.pythonboto.org/en/latest/boto_config_tut.html>`_ available, but the simplest is just to export two environment variables::

    export AWS_ACCESS_KEY_ID='AK123'
    export AWS_SECRET_ACCESS_KEY='abc123'

You can test the script by itself to make sure your config is correct::

    cd plugins/inventory
    ./ec2.py --list

After a few moments, you should see your entire EC2 inventory across all regions in JSON.

Since each region requires its own API call, if you are only using a small set of regions, feel free to edit ``ec2.ini`` and list only the regions you are interested in. There are other config options in ``ec2.ini`` including cache control, and destination variables.

At their heart, inventory files are simply a mapping from some name to a destination address. The default ``ec2.ini`` settings are configured for running Ansible from outside EC2 (from your laptop for example) -- and this is not the most efficient way to manage EC2.

If you are running Ansible from within EC2, internal DNS names and IP addresses may make more sense than public DNS names. In this case, you can modify the ``destination_variable`` in ``ec2.ini`` to be the private DNS name of an instance. This is particularly important when running Ansible within a private subnet inside a VPC, where the only way to access an instance is via its private IP address. For VPC instances, `vpc_destination_variable` in ``ec2.ini`` provides a means of using which ever `boto.ec2.instance variable <http://docs.pythonboto.org/en/latest/ref/ec2.html#module-boto.ec2.instance>`_ makes the most sense for your use case.

The EC2 external inventory provides mappings to instances from several groups:

Global
  All instances are in group ``ec2``.

Instance ID
  These are groups of one since instance IDs are unique.
  e.g.
  ``i-00112233``
  ``i-a1b1c1d1``

Region
  A group of all instances in an AWS region.
  e.g.
  ``us-east-1``
  ``us-west-2``

Availability Zone
  A group of all instances in an availability zone.
  e.g.
  ``us-east-1a``
  ``us-east-1b``

Security Group
  Instances belong to one or more security groups. A group is created for each security group, with all characters except alphanumerics, dashes (-) converted to underscores (_). Each group is prefixed by ``security_group_``
  e.g.
  ``security_group_default``
  ``security_group_webservers``
  ``security_group_Pete_s_Fancy_Group``

Tags
  Each instance can have a variety of key/value pairs associated with it called Tags. The most common tag key is 'Name', though anything is possible. Each key/value pair is its own group of instances, again with special characters converted to underscores, in the format ``tag_KEY_VALUE``
  e.g.
  ``tag_Name_Web``
  ``tag_Name_redis-master-001``
  ``tag_aws_cloudformation_logical-id_WebServerGroup``

When the Ansible is interacting with a specific server, the EC2 inventory script is called again with the ``--host HOST`` option. This looks up the HOST in the index cache to get the instance ID, and then makes an API call to AWS to get information about that specific instance. It then makes information about that instance available as variables to your playbooks. Each variable is prefixed by ``ec2_``. Here are some of the variables available:

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

Both ``ec2_security_group_ids`` and ``ec2_security_group_names`` are comma-separated lists of all security groups. Each EC2 tag is a variable in the format ``ec2_tag_KEY``.

To see the complete list of variables available for an instance, run the script by itself::

    cd plugins/inventory
    ./ec2.py --host ec2-12-12-12-12.compute-1.amazonaws.com

Note that the AWS inventory script will cache results to avoid repeated API calls, and this cache setting is configurable in ec2.ini.  To
explicitly clear the cache, you can run the ec2.py script with the ``--refresh-cache`` parameter::

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

