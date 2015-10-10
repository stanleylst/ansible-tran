.. _inventory:

Inventory文件
=================

.. contents:: Topics

Ansible 可同时操作属于一个组的多台主机,组和主机之间的关系通过 inventory 文件配置.
默认的文件路径为 /etc/ansible/hosts

除默认文件外,你还可以同时使用多个 inventory 文件(后面会讲到),也可以从动态源,或云上拉取 inventory 配置信息.详见 :doc:`intro_dynamic_inventory`.


.. _inventoryformat:

主机与组
++++++++++++++++

/etc/ansible/hosts 文件的格式与windows的ini配置文件类似::

    mail.example.com

    [webservers]
    foo.example.com
    bar.example.com

    [dbservers]
    one.example.com
    two.example.com
    three.example.com

方括号[]中是组名,用于对系统进行分类,便于对不同系统进行个别的管理.


一个系统可以属于不同的组,比如一台服务器可以同时属于 webserver组 和 dbserver组.这时属于两个组的变量都可以为这台主机所用,至于变量的优先级关系将于以后的章节中讨论.


如果有主机的SSH端口不是标准的22端口,可在主机名之后加上端口号,用冒号分隔.SSH 配置文件中列出的端口号不会在 paramiko 连接中使用,会在 openssh 连接中使用.

端口号不是默认设置时,可明确的表示为::

    badwolf.example.com:5309

假设你有一些静态IP地址,希望设置一些别名,但不是在系统的 host 文件中设置,又或者你是通过隧道在连接,那么可以设置如下::

    jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50
	

在这个例子中,通过 "jumper" 别名,会连接 192.168.1.50:5555.记住,这是通过 inventory 文件的特性功能设置的变量.
一般而言,这不是设置变量(描述你的系统策略的变量)的最好方式.后面会说到这个问题.


一组相似的 hostname , 可简写如下::

    [webservers]
    www[01:50].example.com


数字的简写模式中,01:50 也可写为 1:50,意义相同.你还可以定义字母范围的简写模式::

    [databases]
    db-[a:f].example.com


对于每一个 host,你还可以选择连接类型和连接用户名::

   [targets]

   localhost              ansible_connection=local
   other1.example.com     ansible_connection=ssh        ansible_ssh_user=mpdehaan
   other2.example.com     ansible_connection=ssh        ansible_ssh_user=mdehaan


所有以上讨论的对于 inventory 文件的设置是一种速记法,后面我们会讨论如何将这些设置保存为 'host_vars' 目录中的独立的文件.


.. _host_variables:

主机变量
++++++++++++++


前面已经提到过,分配变量给主机很容易做到,这些变量定义后可在 playbooks 中使用::

   [atlanta]
   host1 http_port=80 maxRequestsPerChild=808
   host2 http_port=303 maxRequestsPerChild=909

.. _group_variables:

组的变量
+++++++++++++++

也可以定义属于整个组的变量::

   [atlanta]
   host1
   host2

   [atlanta:vars]
   ntp_server=ntp.atlanta.example.com
   proxy=proxy.atlanta.example.com

.. _subgroups:

把一个组作为另一个组的子成员
+++++++++++++++++++++++++++++++++++++


可以把一个组作为另一个组的子成员,以及分配变量给整个组使用.
这些变量可以给 /usr/bin/ansible-playbook 使用,但不能给 /usr/bin/ansible 使用::


   [atlanta]
   host1
   host2

   [raleigh]
   host2
   host3

   [southeast:children]
   atlanta
   raleigh

   [southeast:vars]
   some_server=foo.southeast.example.com
   halon_system_timeout=30
   self_destruct_countdown=60
   escape_pods=2

   [usa:children]
   southeast
   northeast
   southwest
   northwest


如果你需要存储一个列表或hash值,或者更喜欢把 host 和 group 的变量分开配置,请看下一节的说明.

.. _splitting_out_vars:

分文件定义 Host 和 Group 变量
++++++++++++++++++++++++++++++++++++++++++


在 inventory 主文件中保存所有的变量并不是最佳的方式.还可以保存在独立的文件中,这些独立文件与 inventory 文件保持关联.
不同于 inventory 文件(INI 格式),这些独立文件的格式为 YAML.详见 :doc:`YAMLSyntax` .

假设 inventory 文件的路径为::

    /etc/ansible/hosts


假设有一个主机名为 'foosball', 主机同时属于两个组,一个是 'raleigh', 另一个是 'webservers'.
那么以下配置文件(YAML 格式)中的变量可以为 'foosball' 主机所用.依次为 'raleigh' 的组变量,'webservers' 的组变量,'foosball' 的主机变量::

    /etc/ansible/group_vars/raleigh
    /etc/ansible/group_vars/webservers
    /etc/ansible/host_vars/foosball


举例来说,假设你有一些主机,属于不同的数据中心,并依次进行划分.每一个数据中心使用一些不同的服务器.比如 ntp 服务器, database 服务器等等.
那么 'raleigh' 这个组的组变量定义在文件 '/etc/ansible/group_vars/raleigh' 之中,可能类似这样::

    ---
    ntp_server: acme.example.org
    database_server: storage.example.org


这些定义变量的文件不是一定要存在,因为这是可选的特性.


还有更进一步的运用,你可以为一个主机,或一个组,创建一个目录,目录名就是主机名或组名.目录中的可以创建多个文件,
文件中的变量都会被读取为主机或组的变量.如下 'raleigh' 组对应于 /etc/ansible/group_vars/raleigh/ 目录,其下有两个文件
db_settings 和 cluster_settings, 其中分别设置不同的变量::

    /etc/ansible/group_vars/raleigh/db_settings
    /etc/ansible/group_vars/raleigh/cluster_settings


'raleigh' 组下的所有主机,都可以使用 'raleigh' 组的变量.当变量变得太多时,分文件定义变量更方便我们进行管理和组织.
还有一个方式也可参考,详见 :doc:`Ansible Vault<playbooks_vault>` 关于组变量的部分.
注意,分文件定义变量的方式只适用于 Ansible 1.4 及以上版本.


Tip: Ansible 1.2 及以上的版本中,group_vars/ 和 host_vars/ 目录可放在 inventory 目录下,或是 playbook 目录下.
如果两个目录下都存在,那么 playbook 目录下的配置会覆盖 inventory 目录的配置.


Tip: 把你的 inventory 文件 和 变量 放入 git repo 中,以便跟踪他们的更新,这是一种非常推荐的方式.

.. _behavioral_parameters:

Inventory 参数的说明
+++++++++++++++++++++++++++++++++++++++

如同前面提到的,通过设置下面的参数,可以控制 ansible 与远程主机的交互方式,其中一些我们已经讲到过::

    ansible_ssh_host
	  将要连接的远程主机名.与你想要设定的主机的别名不同的话,可通过此变量设置.
	  
    ansible_ssh_port
	  ssh端口号.如果不是默认的端口号,通过此变量设置.
	  
    ansible_ssh_user
	  默认的 ssh 用户名
	  
    ansible_ssh_pass
	  ssh 密码(这种方式并不安全,我们强烈建议使用 --ask-pass 或 SSH 密钥)
	  
    ansible_sudo_pass
	  sudo 密码(这种方式并不安全,我们强烈建议使用 --ask-sudo-pass)
	  
    ansible_sudo_exe (new in version 1.8)
	  sudo 命令路径(适用于1.8及以上版本)
	  
    ansible_connection
	  与主机的连接类型.比如:local, ssh 或者 paramiko. Ansible 1.2 以前默认使用 paramiko.1.2 以后默认使用 'smart','smart' 方式会根据是否支持 ControlPersist, 来判断'ssh' 方式是否可行.
	  
    ansible_ssh_private_key_file
	  ssh 使用的私钥文件.适用于有多个密钥,而你不想使用 SSH 代理的情况.
	  
    ansible_shell_type
	  目标系统的shell类型.默认情况下,命令的执行使用 'sh' 语法,可设置为 'csh' 或 'fish'.
	  
    ansible_python_interpreter
	  目标主机的 python 路径.适用于的情况: 系统中有多个 Python, 或者命令路径不是"/usr/bin/python",比如  \*BSD, 或者 /usr/bin/python
	  不是 2.X 版本的 Python.我们不使用 "/usr/bin/env" 机制,因为这要求远程用户的路径设置正确,且要求 "python" 可执行程序名不可为 python以外的名字(实际有可能名为python26).
	  
	  与 ansible_python_interpreter 的工作方式相同,可设定如 ruby 或 perl 的路径....
	  

一个主机文件的例子::

  some_host         ansible_ssh_port=2222     ansible_ssh_user=manager
  aws_host          ansible_ssh_private_key_file=/home/example/.ssh/aws.pem
  freebsd_host      ansible_python_interpreter=/usr/local/bin/python
  ruby_module_host  ansible_ruby_interpreter=/usr/bin/ruby.1.9.3


.. seealso::

   :doc:`intro_dynamic_inventory`
       Pulling inventory from dynamic sources, such as cloud providers
   :doc:`intro_adhoc`
       Examples of basic commands
   :doc:`playbooks`
       Learning ansible's configuration management language
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

