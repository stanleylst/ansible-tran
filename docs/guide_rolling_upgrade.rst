持续交付与滚动升级
========================================

.. _lamp_introduction:

介绍
````````````

持续交付是频繁对软件应用程序持续更新的概念.

这个想法使在大量频繁的更新面前, 你不必等待在一个指定的特殊时间点, 并且使你的组织在响应过程中变得更好.

一些 Ansible 用户每小时都在部署更新给他们的最终用户甚至更加频繁 -- 每时每刻都有代码修改的批准. 要实现这一点, 你需要工具能在零停机的时间内快速的应用这些更新.

本文档详细介绍了如何现实这一目标, 使用 Ansible playbooks 作为一个完整例子的模板: lamp_haproxy. 这个例子使用了大量的 Ansible 特性: roles, templates 和 group variables, 并且它还配备了一个业务流程的 playbook 可以做到零停机滚动升级 web 应用程序栈.

.. note::

   `点击这里查看最新版本的 playbook 例子 
   <https://github.com/ansible/ansible-examples/tree/master/lamp_haproxy>`_.

这个 playbooks 基于 CentOS 部署 Apache, PHP, MySQL, Nagios, 和 HAProxy 这些服务.

在这里我们不去讨论如何运行这些 playbooks. 阅读包含在 github 项目中关于这个例子的 README 信息. 相反的, 我们将进一步观察这些 playbook 并且去解释它们.

.. _lamp_deployment:

部署网站
```````````````

让我们首先使用 ``site.yml``. 这是我们网站部署的 playbook. 它被用来部署我们最初的网站以及推送更新到所有的服务器::

    ---
    # 这个 playbook 在这个网站上部署整个应用程序.

    # 应用通用的配置到所有的主机上
    - hosts: all

      roles:
      - common

    # 配置和部署数据库服务器.
    - hosts: dbservers
      
      roles:
      - db

    # 配置和部署 web 服务器. 注意这里我们包含了两个 roles, 这个 'base-apache' role 用来简单设置 Apache, 而 'web' 则包含了我们的 web 应用程序.
      
    - hosts: webservers
      
      roles:
      - base-apache
      - web

    # 配置和部署 load balancer(s).
    - hosts: lbservers
        
      roles:
      - haproxy

    # 配置和部署 Nagios 监控节点(s).
    - hosts: monitoring
    
      roles:
      - base-apache
      - nagios

.. note::

   如果你不熟悉 playbooks 和 plays, 你应该回顾 :doc:`playbooks`.

在这个 palybook 我们有 5 个 plays. 首先第一个目标 ``all`` (所有)主机和适用于所有主机的 ``common`` role. 这是整个网站要做的事像 yum 仓库的配置, 防火墙的配置, 和其他任何需要适用于所有服务器的配置.

接下来的这四个 plays 将运行于指定的主机组并特定的角色应用于这些服务器. 随着对 Nagios monitoring, 数据库角色, 和 web应用程序的应用, 我们可以通过 ``base-apache`` 角色安装和配置一个基本的 Apache. 这是 Nagios 主机和 web 应用程序所需要的.

.. _lamp_roles:

可重用的: Roles
```````````````````````

关于 roles 你现在应该有一点了解以及它们是如何工作的. Roles 是组织: tasks, handlers, templates, 和 files, 到可重用的组件中的方法.

这个例子有 6 个 roles: ``common``, ``base-apache``, ``db``, ``haproxy``, ``nagios``, 和 ``web``.
你如何组织你的 roles 是由你和你的应用程序所决定, 但是大部分网站都将适用一个或多个共同的 roles, 和一些列关于应用程序特定的 roles 来安装和配置这个网站的特定部分. 

Roles 可以用变量和依赖关系, 你可以通过参数来调整它们的行为.
你可以在 :doc:`playbooks_roles` 章节中阅读更多关于 roles

.. _lamp_group_variables:

配置: Group Variables
``````````````````````````````

Group variables 是应用在服务器组上的. 通过设置和修改参数将他们应用在 templates 中来定义 playbooks 的行为. 他们被存储在和你的 inventory 相同目录下名为 ``group_vars`` 的目录中.
下面是 lamp_haproxy 的 ``group_vars/all`` 文件内容. 正如你所期望的, 这些变量将会应用到 inventory 中的所有服务器上::

   ---
   httpd_port: 80
   ntpserver: 192.168.1.2

这是一个 YAML 文件, 并且你可以创建列表和字典等更加复杂的变量结构. 在这种情况下, 我们只设置了两个变量, 一个做为 web server 的端口, 一个作为我们服务器所使用的时间同步 NTP 服务的地址. 

这是另外一个 group variables 文件. 这个 ``group_vars/dbservers`` 适用于在 ``dbservers`` 组中的主机::

   ---
   mysqlservice: mysqld
   mysql_port: 3306
   dbuser: root
   dbname: foodb
   upassword: usersecret

如果你看了这个例子, 你会发现对于 ``webservers`` 组合 ``lbservers`` 组的 group variables 十分相似.

这些变量可以用于任何地方. 你可以在 playbooks 中使用它们, 像这样, 在 ``roles/db/tasks/main.yml``::

   - name: Create Application Database
     mysql_db: name={{ dbname }} state=present

   - name: Create Application DB User
     mysql_user: name={{ dbuser }} password={{ upassword }}
                 priv=*.*:ALL host='%' state=present

你也可以在 templates 中使用这些变量, 想这样, 在 ``roles/common/templates/ntp.conf.j2``::

   driftfile /var/lib/ntp/drift

   restrict 127.0.0.1
   restrict -6 ::1

   server {{ ntpserver }}

   includefile /etc/ntp/crypto/pw

   keys /etc/ntp/keys

你可以看到这些变量替换的语法 {{ and }} 和 templates 中的变量是相同的. 这种花括号格式是采用的jinj2语法, 你在对于内部的数据做各种操作及应用不同的过滤器. 在 templates, 你也可以使用循环和 if 语句来处理更加复杂的情况, 想这样, 在 ``roles/common/templates/iptables.j2``::

   {% if inventory_hostname in groups['dbservers'] %}
   -A INPUT -p tcp  --dport 3306 -j  ACCEPT
   {% endif %}

这是用来判断, 名为 (``inventory_hostname``) 的机器是否存在于组 ``dbservers``. 如果这样的话, 该机器将会添加一条 目标端口为 3306 的 iptables 允许规则.

这有一些其他的例子, 来自相同的模板::

   {% for host in groups['monitoring'] %}
   -A INPUT -p tcp -s {{ hostvars[host].ansible_default_ipv4.address }} --dport 5666 -j ACCEPT
   {% endfor %}

这里循环了一个组名为 ``monitoring`` 中的所有主机, 并且配置了源地址为所有监控主机的 IPV4 地址目标端口为 5666 的 iptables 允许规则到当前主机上, 正因为如此 Nagios 才可以监控这些主机.

你可以学到更多关于 Jinja2 的功能 `here <http://jinja.pocoo.org/docs/>`_, 并且你可以读到更多关于 Ansible 所有的变量在这个 :doc:`playbooks_variables` 章节

.. _lamp_rolling_upgrade:

滚动升级
```````````````````

现在你有了一个全面的网站包含 web servers, 一个 load balancer, 和 monitoring. 如何更新它? 这就是 Ansible 的特殊功能发挥作用. 尽管一些应用程序使用'业务流程'来编排命令执行的逻辑, Ansible将指挥编排这些机器, 并且拥有一个相当复杂的引擎.

Ansible 有能力在一次操作中协调多种应用程序, 使在进行更新升级我们的 web 应用程序时更加实现零停机时间. 这是一个单独的 playbook, 叫做 ``roleing_upgrade.yml``.

看这个 playbook, 你可以看到它是由两个 plays 组成. 首先第一个看起来十分简单像这样::

   - hosts: monitoring
     tasks: []

这里要做什么, 为什么没有 tasks? 你可能知道 Ansible 在运行之前会从服务上收集 "facts". 这些 facts 是很多种有用的信息: 网络信息, OS/发行版本, 配置. 在我们的方案中, 在更新之前我们需要了解关于所有监控服务器的环境信息, 因此这个简单的 paly 将会在我们的所监控的服务器上强制收集 fact 信息. 你有时会见到这种模式, 这是一个有用的技巧.

接下来的部分是更新 play. 第一部分看起来是这样::

   - hosts: webservers
     user: root
     serial: 1

我们仅仅是像通常一样在 ``webservers`` 组中定义了 play. 这个 ``serial`` 关键字告诉 Ansible 每次操作多少服务器. 如果它没有被指定, Ansible 默认根据配置文件中 "forks" 限制指定的值进行并发操作. 但是对于零停机时间的更新, 你可能不希望一次操作多个主机. 如果你仅仅有少数的 web 服务器, 你可能希望设置 ``serial`` 为 1, 在同一时间只执行一台主机. 如果你有 100 台, 你可以设置 ``serial`` 为 10, 同一时间执行 10 台.

下面是更新 play 接下来的部分::

  pre_tasks:
  - name: disable nagios alerts for this host webserver service
    nagios: action=disable_alerts host={{ inventory_hostname }} services=webserver
    delegate_to: "{{ item }}"
    with_items: groups.monitoring

  - name: disable the server in haproxy
    shell: echo "disable server myapplb/{{ inventory_hostname }}" | socat stdio /var/lib/haproxy/stats
    delegate_to: "{{ item }}"
    with_items: groups.lbservers

这个 ``pre_tasks`` 关键字仅仅是让在 roles 调用前列出运行的 tasks. 这段时间将十分有用. 如果你看到这些 tasks 的名称, 你会发现我们禁用了 Nagios 的报警并且将当前更新的服务器从 HAProxy load balancing pool 中移除.

参数``delegate_to`` 和 ``with_items`` 一起来使用, 因为 Ansible 循环每一个 monitoring 服务器和 load balancer, 并且针对循环的值在 monitoring 或 load balancing 上操作(delegate 代表操作). 从编程方面来说, 外部的循环是 web 服务器列表, 内部的循环是 monitoring 服务器列表.

请注意 HAProxy 的步骤看起来有点复杂. 我们使用它作为例子是因为它是免费的, 但如果你有(例如)一个 F5 或 Netscaler 在你的基础设施上(或者你有一个 AWS 弹性 IP 的设置?), 你可以使用 Ansible 的模块而不是直接和他们进行交互. 你也可能希望使用其他的 monitoring 模块来代替 nagios, 但是这仅仅是展示了在任务开始前的部分 -- 把服务从监控中移除并且轮换它们.

下一步重新简单的使正确的角色应用在 web 服务器上. 这将导致一些名为 ``web`` 和 ``base-apache`` 的配置管理角色应用到 web 服务器上, 包含一个更新 web 应用程序自身代码. 我们不需要这样做 -- 我们仅需要将其修改为纯碎的更新 web 程序, 但是这是一个很好的例子关于如何通过 roles 来重用这些任务::

  roles:
  - common
  - base-apache
  - web

最后, 在 ``post_tasks`` 部分, 我们反向的改变 Nagios 的配置并且将 web 服务器重新添加到 load balancing pool::

  post_tasks:
  - name: Enable the server in haproxy
    shell: echo "enable server myapplb/{{ inventory_hostname }}" | socat stdio /var/lib/haproxy/stats
    delegate_to: "{{ item }}"
    with_items: groups.lbservers

  - name: re-enable nagios alerts
    nagios: action=enable_alerts host={{ inventory_hostname }} services=webserver
    delegate_to: "{{ item }}"
    with_items: groups.monitoring

再一次说明, 如果你在使用一个 Netscaler 或 F5 或 Elastic 的负载均衡器, 你仅仅需要替换为适合的模块对象.

.. _lamp_end_notes:

管理其他的负载均衡
`````````````````````````````

在这个例子中, 我们使用了简单的 HAProxy 负载均衡到后端的 web 服务器. 它是非常容易配置和管理的. 正如我们所提到的, Ansible 已经为其他的负载均衡器像 Citrix NetScaler, F5 BigIP, Amazon Elastic Load Balancers 等提供了内建的支持.阅读更多信息 :doc:`modules`

对于其他的负载均衡器, 如果公开一个负载均衡时, 你可能需要向它们发送 shell 命令 (像上面我们对 HAProxy 一样), 或者调用一些 API. 你可以越多更多关于 local actions 在这个 :doc:`playbooks_delegation` 章节中. 对于一些硬件的开发将更加有趣, 他们没有一个核心模块, 所以你可以使用更好的模块将他们封装起来!

.. _lamp_end_to_end:

持续交付结束
``````````````````````````````

现在你有一个自动化的方式来部署更新你的应用程序, 你将如何将他们绑定在一起? 许多组织使用持续集成的工具像 `Jenkins <http://jenkins-ci.org/>`_ 或 `Atlassian Bamboo <https://www.atlassian.com/software/bamboo>`_ 来完成开发, 测试, 发布, 和部署这样的流程步骤. 你也可以使用这些工具像 `Gerrit <https://code.google.com/p/gerrit/>`_ 来添加一个 code review 的步骤来审查提交的应用程序的本身或者 Ansible playbooks.

根据你的环境, 你可能会部署到一个测试环境, 在这个环境中运行一些集成测试, 然后自动部署到生产环境. 你可以保持他们的简单性仅按需来进行滚动升级到测试或者指定的生产环境中. 这些你都随你决定.

与持续集成工具的结合, 你可以通过 ``ansible-playbook`` 命令行工具很容易的触发 playbook 的运行, 或者, 如果你使用 :doc:`tower`, ``tower-cli`` 或者内置的 REST API. (这个 tower-cli 命令的 'joblaunch' 将通过 REST API 远程产生一个 job 这非常棒).

Ansible 对于如何组合多层应用程序在任务编排和持续交付给客户的最终目标上给了你很好的主意. 你可以使用滚动升级的思路来扩展一些应用程序之间的不同部分; 也许向前端 web 服务器添加后端应用服务, 例如, 使用 MongoDB 或 Riak 来替换 SQL 数据库. Ansible 可以给你在复杂的环境中轻松完成常见的自动化操作.

.. seealso::

   `lamp_haproxy example <https://github.com/ansible/ansible-examples/tree/master/lamp_haproxy>`_
       The lamp_haproxy example discussed here.
   :doc:`playbooks`
       An introduction to playbooks
   :doc:`playbooks_roles`
       An introduction to playbook roles
   :doc:`playbooks_variables`
       An introduction to Ansible variables
   `Ansible.com: Continuous Delivery <http://www.ansible.com/ansible-continuous-delivery>`_
       An introduction to Continuous Delivery with Ansible


