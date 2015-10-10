最佳实践
================

这里有些给使用和编写 Ansible playbook 的贴士.

你能在我们的 `ansible-example repository <https://github.com/ansible/ansible-examples>`_.找到展示这些最佳实践的 playbook 样例.(注意: 这些示例用的也许不是最新版的中所有特性,但它们仍旧是极佳的参考.)


.. contents:: Topics

.. _content_organization:

Content Organization
++++++++++++++++++++++

接下来的章节将向你展示一种组织 playbook 内容方式.

你对 Ansible 的使用应该符合你的需求而不是我们的,所以请随意根据你的需求来组织修改接下来的示例.

有件事绝对是你想要做的,那就是使用 "roles" 组织特性.它作为主要的 playbook 的主要部分被文档化.详情参见 :doc:`playbooks_roles`. 你绝对应该使用 roles.
roles 是极好的. 快去使用 roles！ roles！ 重要的事情要重复说！roles 是极好的.(译者:..老外也知道重要的事情重复三遍啊！~~~)

.. _directory_layout:

Directory Layout
`````````````````

顶层目录结构应当包括下列文件和目录::

    production                # inventory file for production servers 关于生产环境服务器的清单文件
    stage                     # inventory file for stage environment 关于 stage 环境的清单文件

    group_vars/
       group1                 # here we assign variables to particular groups 这里我们给特定的组赋值
       group2                 # ""
    host_vars/
       hostname1              # if systems need specific variables, put them here 如果系统需要特定的变量,把它们放置在这里.
       hostname2              # ""

    library/                  # if any custom modules, put them here (optional) 如果有自定义的模块,放在这里(可选)
    filter_plugins/           # if any custom filter plugins, put them here (optional) 如果有自定义的过滤插件,放在这里(可选)

    site.yml                  # master playbook 主 playbook
    webservers.yml            # playbook for webserver tier Web 服务器的 playbook
    dbservers.yml             # playbook for dbserver tier 数据库服务器的 playbook

    roles/
        common/               # this hierarchy represents a "role" 这里的结构代表了一个 "role"
            tasks/            #
                main.yml      #  <-- tasks file can include smaller files if warranted
            handlers/         #
                main.yml      #  <-- handlers file
            templates/        #  <-- files for use with the template resource
                ntp.conf.j2   #  <------- templates end in .j2
            files/            #
                bar.txt       #  <-- files for use with the copy resource
                foo.sh        #  <-- script files for use with the script resource
            vars/             #
                main.yml      #  <-- variables associated with this role
            defaults/         #
                main.yml      #  <-- default lower priority variables for this role
            meta/             #
                main.yml      #  <-- role dependencies

        webtier/              # same kind of structure as "common" was above, done for the webtier role
        monitoring/           # ""
        fooapp/               # ""

.. note:  If you find yourself having too many top level playbooks (for instance you have a playbook you wrote for a specific hotfix, etc), it may make sense to have a playbooks/ directory instead.  This can be a good idea as you get larger.  If you do this, configure your roles_path in ansible.cfg to find your roles location.

.. note: 如果你发现你的 playbook有过多的

.. _use_dynamic_inventory_with_clouds:

Use Dynamic Inventory With Clouds
```````````````````````````````````

如果你正在使用云服务,你不应该在一个静态文件管理你的清单.详见 :doc:`intro_dynamic_inventory`.

这不仅适用于云环境 -- 如果你的基础设施中还有其他系统维护着一系列标准系统,使用 动态清单 会是个好主意.

.. _stage_vs_prod:

How to Differentiate  Stage vs Production
`````````````````````````````````````````

If managing static inventory, it is frequently asked how to differentiate different types of environments.  The following example
shows a good way to do this.  Similar methods of grouping could be adapted to dynamic inventory (for instance, consider applying the AWS
tag "environment:production", and you'll get a group of systems automatically discovered named "ec2_tag_environment_production".

如果你管理着静态清单,如何区分不同的环境类型是个常见的问题.接下来的示例会做一个很好地说明.

Let's show a static inventory example though.  Below, the *production* file contains the inventory of all of your production hosts.

It is suggested that you define groups based on purpose of the host (roles) and also geography or datacenter location (if applicable)::

    # file: production

    [atlanta-webservers]
    www-atl-1.example.com
    www-atl-2.example.com

    [boston-webservers]
    www-bos-1.example.com
    www-bos-2.example.com

    [atlanta-dbservers]
    db-atl-1.example.com
    db-atl-2.example.com

    [boston-dbservers]
    db-bos-1.example.com

    # webservers in all geos
    [webservers:children]
    atlanta-webservers
    boston-webservers

    # dbservers in all geos
    [dbservers:children]
    atlanta-dbservers
    boston-dbservers

    # everything in the atlanta geo
    [atlanta:children]
    atlanta-webservers
    atlanta-dbservers

    # everything in the boston geo
    [boston:children]
    boston-webservers
    boston-dbservers

.. _groups_and_hosts:

Group And Host Variables
````````````````````````

本章节内容基于前一章节示例.


分组有利于组织结构,但不是所有的分组都是有益的.你也可以给他们赋值!比如说亚特兰大有它自己的网络时间协议,
所以当配置 ntp.conf 时,我们就该使用它.让我们现在设置它们::

    ---
    # file: group_vars/atlanta
    ntp: ntp-atlanta.example.com
    backup: backup-atlanta.example.com

Variables aren't just for geographic information either!  Maybe the webservers have some configuration that doesn't make sense for the database servers::

    ---
    # file: group_vars/webservers
    apacheMaxRequestsPerChild: 3000
    apacheMaxClients: 900

If we had any default values, or values that were universally true, we would put them in a file called group_vars/all::

    ---
    # file: group_vars/all
    ntp: ntp-boston.example.com
    backup: backup-boston.example.com

We can define specific hardware variance in systems in a host_vars file, but avoid doing this unless you need to::

    ---
    # file: host_vars/db-bos-1.example.com
    foo_agent_port: 86
    bar_agent_port: 99

Again, if we are using dynamic inventory sources, many dynamic groups are automatically created.  So a tag like "class:webserver" would load in
variables from the file "group_vars/ec2_tag_class_webserver" automatically.

.. _split_by_role:

Top Level Playbooks Are Separated By Role
```````````````````````````````````````````

在 site.yml 中,我们包含了一个定义了整个基础设施的 playbook.注意这个 playbook 是非常短的,
因为它仅仅包含了其他 playbooks.记住, playbook 不过就是一系列的 `plays`::

    ---
    # file: site.yml
    - include: webservers.yml
    - include: dbservers.yml

在诸如 like webservers.yml 的文件中(同样也在顶层结构),我们仅仅将 Web 服务器组与对应的 role 行为做映射.同样值得注意的是这也非常的短小精悍.例如::

    ---
    # file: webservers.yml
    - hosts: webservers
      roles:
        - common
        - webtier

理念是我们能够通过 "运行"(running) site.yml 来选择整个基础设施的配置.或者我们能够通过运行其子集 webservers.yml 来配置.
这与 Ansible 的 "--limit" 类似,而且相对的更为显式::

   ansible-playbook site.yml --limit webservers
   ansible-playbook webservers.yml

.. _role_organization:

Task And Handler Organization For A Role
````````````````````````````````````````

接下来的示例任务文件展示了一个 role 是如何工作的.我们这里的普通 role 仅仅用来配置 NTP,但是如果我们想的话,它可以做更多::

    ---
    # file: roles/common/tasks/main.yml

    - name: be sure ntp is installed
      yum: pkg=ntp state=installed
      tags: ntp

    - name: be sure ntp is configured
      template: src=ntp.conf.j2 dest=/etc/ntp.conf
      notify:
        - restart ntpd
      tags: ntp

    - name: be sure ntpd is running and enabled
      service: name=ntpd state=running enabled=yes
      tags: ntp

这是个处理文件样例.作为一种审核,它只有当特定的任务报告发生变化时会被触发,并在每个 play 结束时运行::

    ---
    # file: roles/common/handlers/main.yml
    - name: restart ntpd
      service: name=ntpd state=restarted

详情请参阅 :doc:`playbooks_roles`.

.. _organization_examples:

What This Organization Enables (Examples)
`````````````````````````````````````````

我们在前文分享了我们基础的组织结构.

那这种结构适用于何种应用场景？ 很多！若我想重新配置整个基础设施,如此即可::

    ansible-playbook -i production site.yml

那只重新配置所有的 NTP 呢？太容易了.::

    ansible-playbook -i production site.yml --tags ntp

只重新配置我的 Web 服务器呢？::

    ansible-playbook -i production webservers.yml

只重新配置我在波士顿的 Web服务器呢?::

    ansible-playbook -i production webservers.yml --limit boston

前10台 和 接下来的10台呢？

    ansible-playbook -i production webservers.yml --limit boston[0-10]
    ansible-playbook -i production webservers.yml --limit boston[10-20]

当然,只使用基础的 ad-hoc 也是 OK 的啦.::

    ansible boston -i production -m ping
    ansible boston -i production -m command -a '/sbin/reboot'

这里还有些有用的命令你需要知道(版本至少 1.1 或更高)::

    # confirm what task names would be run if I ran this command and said "just ntp tasks"
    ansible-playbook -i production webservers.yml --tags ntp --list-tasks

    # confirm what hostnames might be communicated with if I said "limit to boston"
    ansible-playbook -i production webservers.yml --limit boston --list-hosts

.. _dep_vs_config:

Deployment vs Configuration Organization
````````````````````````````````````````

The above setup models a typical configuration topology.  When doing multi-tier deployments, there are going
to be some additional playbooks that hop between tiers to roll out an application.  In this case, 'site.yml'
may be augmented by playbooks like 'deploy_exampledotcom.yml' but the general concepts can still apply.


Consider "playbooks" as a sports metaphor -- you don't have to just have one set of plays to use against your infrastructure
all the time -- you can have situational plays that you use at different times and for different purposes.

Ansible allows you to deploy and configure using the same tool, so you would likely reuse groups and just
keep the OS configuration in separate playbooks from the app deployment.

.. _stage_vs_production:

Stage vs Production
+++++++++++++++++++

如前所述,通过使用不同的清单文件来分离你的 stage 和 生产环境是个好方法.你可以通过 -i 来指定.把它们放在同一个文件中会有惊喜哦！
在部署到生产环境之前,先在 stage 环境中做测试是个好主意.你的环境不必保持同样的大小,你可以通过 分组变量来对不同的环境进行控制.

.. _rolling_update:

Rolling Updates
+++++++++++++++

请理解 'serial' 关键字.你会在批量升级中使用它来控制升级机器的数量.

See :doc:`playbooks_delegation`.

.. _mention_the_state:

Always Mention The State
++++++++++++++++++++++++

parameter in your playbooks to make it clear, especially as some modules support additional states.
对于很多模块来说 'state' 参数是可选的.无论是 'state=present' 亦或 'state=absent' ,你最好在 playbook 中显式指定该参数,毕竟有些模块是支持附加的 'state' 参数.

.. _group_by_roles:

Group By Roles
++++++++++++++

在这条贴士中,我们某种程度上在重复自己,但这是值得的.一个系统可能被分成多分组.详情请查阅 :doc:`intro_inventory` 和 :doc:`intro_patterns`.
在样例中,分组名之后的 *webservers* 和 *dbservers* ,它们因为是很重要的概念所以反复出现.(译者:恩,重要的事情要重复三遍！)一个系统可以出现在多个分组中.


通过给 role 赋予特定的变量,这允许 playbooks 能基于角色来锁定机器.

See :doc:`playbooks_roles`.

.. _os_variance:

Operating System and Distribution Variance
++++++++++++++++++++++++++++++++++++++++++++

当处理在不同操作系统间参数值不同的参数时,使用 group_by 模块是个好主意.

这使宿主机的动态分组有了匹配的标准,即使该分组尚未在清单文件中被定义 ::

   ---

   # talk to all hosts just so we can learn about them
   - hosts: all
     tasks:
        - group_by: key=os_{{ ansible_distribution }}

   # now just on the CentOS hosts...

   - hosts: os_CentOS
     gather_facts: False
     tasks:
        - # tasks that only happen on CentOS go here

这会抛出所有基于操作系统名的分组.

如果需要对特定分组做设定,这也是可以的.例::

    ---
    # file: group_vars/all
    asdf: 10

    ---
    # file: group_vars/os_CentOS
    asdf: 42

在上述的例子中, CentOS 的机器获取的 asdf 的值为 42,但其他机器获得是 '10'.这不止可以用于设置变量,也可以将特定的 role 应用于特定的操作系统.

相对的,如果只需要变量::

    - hosts: all
      tasks:
        - include_vars: "os_{{ ansible_distribution }}.yml"
        - debug: var=asdf

这将根据操作系统名来拉取相应的值.

.. _ship_modules_with_playbooks:

Bundling Ansible Modules With Playbooks
+++++++++++++++++++++++++++++++++++++++

如果一个 playbook 有一个与它 YMAL 文件相关的 "./library" 目录,该目录可以用于添加 Ansible 模块,它会被自动添加到 Ansible 模块的路径中.这是一个将
playbook 与其模块放置在一起的方式.如下面的目录结构样例所展示::

.. _whitespace:

Whitespace and Comments
+++++++++++++++++++++++

鼓励使用空格来分隔内容,用 '#' 来写注释.

.. _name_tasks:

Always Name Tasks
+++++++++++++++++

虽然推荐提供关于为什么要这么做的描述,但是直接给一个给定任务命名也是可以的.名字会在 playbook 运行时显示.

.. _keep_it_simple:

Keep It Simple
++++++++++++++

当你能简单的搞定某事时,就简单的搞定.不要试图一次性使用 Ansible 的所有的特性.仅仅使用对你有用的即可.
比如说你基本上不会需要一次性使用 ``vars`` , ``vars_files`` , ``vars_prompt`` 和 ``--extra-vars`` 同时还是用一个外部的节点配置文件.

如果你感觉任务很复杂时,它可能真的很复杂,这也许是个简化它的好机会.

.. _version_control:

Version Control
+++++++++++++++

请使用版本控制.保持你的 playbook 和 清单文件 在 git(或其他版本控制系统)中,并将你的修改做提交.
这样你就有审计轨迹来描述什么时候以及为什么你做了这样的修改.

.. seealso::

   :doc:`YAMLSyntax`
       Learn about YAML syntax
   :doc:`playbooks`
       Review the basic playbook features
   :doc:`modules`
       Learn about available modules
   :doc:`developing_modules`
       Learn how to extend Ansible by writing your own modules
   :doc:`intro_patterns`
       Learn about how to select hosts
   `GitHub examples directory <https://github.com/ansible/ansible/tree/devel/examples/playbooks>`_
       Complete playbook files from the github project source
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups

