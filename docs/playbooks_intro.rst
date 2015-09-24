Playbooks 介绍
==================

.. _about_playbooks:

Playbooks 简介
```````````````

Playbooks 与 adhoc 相比,是一种完全不同的运用 ansible 的方式,是非常之强大的.

简单来说,playbooks 是一种简单的配置管理系统与多机器部署系统的基础.与现有的其他系统有不同之处,且非常适合于复杂应用的部署.

Playbooks 可用于声明配置,更强大的地方在于,在 playbooks 中可以编排有序的执行过程,甚至于做到在多组机器间,来回有序的执行特别指定的步骤.并且可以同步或异步的发起任务.

我们使用 adhoc 时,主要是使用 /usr/bin/ansible 程序执行任务.而使用 playbooks 时,更多是将之放入源码控制之中,用之推送你的配置或是用于确认你的远程系统的配置是否符合配置规范.

在如右的连接中: `ansible-examples repository <https://github.com/ansible/ansible-examples>`_ ,有一些整套的playbooks,它们阐明了上述的这些技巧.我们建议你在另一个标签页中打开它看看,配合本章节一起看.

即便学完 playbooks 这个章节,仍有许多知识点只是入门的级别,完成本章的学习后,可回到文档索引继续学习.



.. _playbook_language_example:

Playbook 语言的示例
`````````````````````````

Playbooks 的格式是YAML（详见::doc:`YAMLSyntax`）,语法做到最小化,意在避免 playbooks 成为一种编程语言或是脚本,但它也并不是一个配置模型或过程的模型.

playbook 由一个或多个 'plays' 组成.它的内容是一个以 'plays' 为元素的列表.

在 play 之中,一组机器被映射为定义好的角色.在 ansible 中,play 的内容,被称为 tasks,即任务.在基本层次的应用中,一个任务是一个对 ansible 模块的调用,这在前面章节学习过.

'plays' 好似音符,playbook 好似由 'plays' 构成的曲谱,通过 playbook,可以编排步骤进行多机器的部署,比如在 webservers 组的所有机器上运行一定的步骤,
然后在 database server 组运行一些步骤,最后回到 webservers 组,再运行一些步骤,诸如此类.

"plays" 算是一个体育方面的类比,你可以通过多个 plays 告诉你的系统做不同的事情,不仅是定义一种特定的状态或模型.你可以在不同时间运行不同的 plays.

对初学者,这里有一个 playbook,其中仅包含一个 play::

    ---
    - hosts: webservers
      vars:
        http_port: 80
        max_clients: 200
      remote_user: root
      tasks:
      - name: ensure apache is at the latest version
        yum: pkg=httpd state=latest
      - name: write the apache config file
        template: src=/srv/httpd.j2 dest=/etc/httpd.conf
        notify:
        - restart apache
      - name: ensure apache is running
        service: name=httpd state=started
      handlers:
        - name: restart apache
          service: name=httpd state=restarted


在下面,我们将分别讲解 playbook 语言的多个特性.



.. _playbook_basics:

playbook基础
`````````````

.. _playbook_hosts_and_users:

主机与用户
+++++++++++++++

你可以为 playbook 中的每一个 play,个别地选择操作的目标机器是哪些,以哪个用户身份去完成要执行的步骤（called tasks）.

`hosts` 行的内容是一个或多个组或主机的 patterns,以逗号为分隔符,详见 :doc:`intro_patterns` 章节.
 `remote_user` 就是账户名::

    ---
    - hosts: webservers
      remote_user: root

.. note::

	参数 `remote_user` 以前写做 `user`,在 Ansible 1.4 以后才改为 remote_user.主要为了不跟 `user` 模块混淆（user 模块用于在远程系统上创建用户）.
	
再者,在每一个 task 中,可以定义自己的远程用户::

    ---
    - hosts: webservers
      remote_user: root
      tasks:
        - name: test connection
          ping:
          remote_user: yourname

.. note::

	task 中的 `remote_user` 参数在 1.4 版本以后添加.


也支持从 sudo 执行命令::

    ---
    - hosts: webservers
      remote_user: yourname
      sudo: yes

同样的,你可以仅在一个 task 中,使用 sudo 执行命令,而不是在整个 play 中使用 sudo::

    ---
    - hosts: webservers
      remote_user: yourname
      tasks:
        - service: name=nginx state=started
          sudo: yes


你也可以登陆后,sudo 到不同的用户身份,而不是使用 root::

    ---
    - hosts: webservers
      remote_user: yourname
      sudo: yes
      sudo_user: postgres


如果你需要在使用 sudo 时指定密码,可在运行 `ansible-playbook` 命令时加上选项 ``--ask-sudo-pass`` (`-K`).
如果使用 sudo 时,playbook 疑似被挂起,可能是在 sudo prompt 处被卡住,这时可执行 `Control-C` 杀死卡住的任务,再重新运行一次.

.. important::

   当使用 `sudo_user` 切换到 非root 用户时,模块的参数会暂时写入 /tmp 目录下的一个随机临时文件.
   当命令执行结束后,临时文件立即删除.这种情况发生在普通用户的切换时,比如从 'bob' 切换到 'timmy',
   切换到 root 账户时,不会发生,如从 'bob' 切换到 'root',直接以普通用户或root身份登录也不会发生.
   如果你不希望这些数据在短暂的时间内可以被读取（不可写）,请避免在 `sudo_user` 中传递未加密的密码.
   其他情况下,'/tmp' 目录不被使用,这种情况不会发生.Ansible 也有意识的在日志中不记录密码参数.



.. _tasks_list:

Tasks 列表
++++++++++

每一个 play 包含了一个 task 列表（任务列表）.一个 task 在其所对应的所有主机上（通过 host pattern 匹配的所有主机）执行完毕之后,下一个 task 才会执行.有一点需要明白的是（很重要）,在一个 play 之中,所有 hosts 会获取相同的任务指令,这是 play 的一个目的所在,也就是将一组选出的 hosts 映射到 task.（注:此处翻译未必准确,暂时保留原文）

在运行 playbook 时（从上到下执行）,如果一个 host 执行 task 失败,这个 host 将会从整个 playbook 的 rotation 中移除.
如果发生执行失败的情况,请修正 playbook 中的错误,然后重新执行即可.

每个 task 的目标在于执行一个 moudle, 通常是带有特定的参数来执行.在参数中可以使用变量（variables）.

modules 具有"幂等"性,意思是如果你再一次地执行 moudle（译者注:比如遇到远端系统被意外改动,需要恢复原状）,moudle 
只会执行必要的改动,只会改变需要改变的地方.所以重复多次执行 playbook 也很安全.

对于 `command` module 和 `shell` module,重复执行 playbook,实际上是重复运行同样的命令.如果执行的命令类似于 'chmod' 或者 'setsebool' 这种命令,这没有任何问题.也可以使用一个叫做 'creates' 的 flag 使得这两个 module 变得具有"幂等"特性
（不是必要的）.

每一个 task 必须有一个名称 `name`,这样在运行 playbook 时,从其输出的任务执行信息中可以很好的辨别出是属于哪一个 task 的.
如果没有定义 `name`,‘action’ 的值将会用作输出信息中标记特定的 task.

如果要声明一个 task,以前有一种格式: "action: module options" （可能在一些老的 playbooks 中还能见到）.现在推荐使用更常见的格式:"module: options" ,本文档使用的就是这种格式.

下面是一种基本的 task 的定义,service moudle 使用 key=value 格式的参数,这也是大多数 module 使用的参数格式::

   tasks:
     - name: make sure apache is running
       service: name=httpd state=running

比较特别的两个 modudle 是  `command` 和 `shell` ,它们不使用 key=value 格式的参数,而是这样::

   tasks:
     - name: disable selinux
       command: /sbin/setenforce 0

使用 command module 和 shell module 时,我们需要关心返回码信息,如果有一条命令,它的成功执行的返回码不是0,
你或许希望这样做::

   tasks:
     - name: run this command and ignore the result
       shell: /usr/bin/somecommand || /bin/true

或者是这样::

   tasks:
     - name: run this command and ignore the result
       shell: /usr/bin/somecommand
       ignore_errors: True

如果 action 行看起来太长,你可以使用 space（空格） 或者 indent（缩进） 隔开连续的一行::

    tasks:
      - name: Copy ansible inventory file to client
        copy: src=/etc/ansible/hosts dest=/etc/ansible/hosts
                owner=root group=root mode=0644

在 action 行中可以使用变量.假设在 'vars' 那里定义了一个变量 'vhost' ,可以这样使用它::

   tasks:
     - name: create a virtual host file for {{ vhost }}
       template: src=somefile.j2 dest=/etc/httpd/conf.d/{{ vhost }}

这些变量在 tempates 中也是可用的,稍后会讲到.

在一个基础的 playbook 中,所有的 task 都是在一个 play 中列出,稍后将介绍一种更合理的安排 task 的方式:使用 'include:' 
指令.



.. _action_shorthand:

Action Shorthand
````````````````

.. versionadded:: 0.8

在 0.8 及以后的版本中,ansible 更喜欢使用如下的格式列出 modules::

    template: src=templates/foo.j2 dest=/etc/foo.conf

在早期的版本中,使用以下的格式::

    action: template src=templates/foo.j2 dest=/etc/foo.conf

早期的格式在新版本中仍然可用,并且没有计划将这种旧的格式弃用.



.. _handlers:

Handlers: 在发生改变时执行的操作
``````````````````````````````````````

上面我们曾提到过,module 具有"幂等"性,所以当远端系统被人改动时,可以重放 playbooks 达到恢复的目的.
playbooks 本身可以识别这种改动,并且有一个基本的 event system（事件系统）,可以响应这种改动.

（当发生改动时）'notify' actions 会在 playbook 的每一个 task 结束时被触发,而且即使有多个不同的 task 通知改动的发生,
'notify' actions 只会被触发一次.

举例来说,比如多个 resources 指出因为一个配置文件被改动,所以 apache 需要重新启动,但是重新启动的操作只会被执行一次.

这里有一个例子,当一个文件的内容被改动时,重启两个 services::

   - name: template configuration file
     template: src=template.j2 dest=/etc/foo.conf
     notify:
        - restart memcached
        - restart apache

'notify' 下列出的即是 handlers.

Handlers 也是一些 task 的列表,通过名字来引用,它们和一般的 task 并没有什么区别.Handlers 是由通知者进行 notify,
如果没有被 notify,handlers 不会执行.不管有多少个通知者进行了 notify,等到 play 中的所有 task 执行完成之后,handlers  也只会被执行一次.

这里是一个 handlers 的示例::

    handlers:
        - name: restart memcached
          service:  name=memcached state=restarted
        - name: restart apache
          service: name=apache state=restarted

Handlers 最佳的应用场景是用来重启服务,或者触发系统重启操作.除此以外很少用到了.
  
.. note::
   handlers 会按照声明的顺序执行

Roles 将在下一章节讲述.值得指出的是,handlers 会在 'pre_tasks', 'roles', 'tasks', 和 'post_tasks' 之间自动执行.
如果你想立即执行所有的 handler 命令,在1.2及以后的版本,你可以这样做::

    tasks:
       - shell: some tasks go here
       - meta: flush_handlers
       - shell: some other tasks

在以上的例子中,任何在排队等候的 handlers 会在执行到 'meta' 部分时,优先执行.这个技巧在有些时候也能派上用场.



.. _executing_a_playbook:

执行一个 playbook
````````````````````

既然现在你已经学习了 playbook 的语法,那要如何运行一个 playbook 呢？这很简单,这里的示例是并行的运行 playbook,并行的级别
是10（译者注:是10个并发的进程？）::

    ansible-playbook playbook.yml -f 10

	
	
.. _ansible-pull:

Ansible-Pull（拉取配置而非推送配置）
`````````````````````````````````````

我们可不可以将 ansible 的体系架构颠倒过来,让托管节点从一个 central location 做 check in 获取配置信息,而不是
推送配置信息到所有的托管节点？是可以的.

Ansible-pull 是一个小脚本,它从 git 上 checkout 一个关于配置指令的 repo,然后以这个配置指令来运行 ansible-playbook.

假设你对你的 checkout location 做负载均衡,ansible-pull 基本上可以无限的提升规模.

可执行 ``ansible-pull --help`` 获取详细的帮助信息.

也有一个叫做 clever playbook 的东西:  `clever playbook <https://github.com/ansible/ansible-examples/blob/master/language_features/ansible_pull.yml>`_ .
这个可以通过 crontab 来配置 ansible-pull（from push mode）.



.. _tips_and_tricks:

提示与技巧
```````````````

在 playbook 执行输出信息的底部,可以找到关于托管节点的信息.也可看到一般的失败信息,和严重的 "unreachable" 信息.
这两个是分开计数的.

如果你想看到执行成功的 modules 的输出信息,使用 ``--verbose`` flag（否则只有执行失败的才会有输出信息）.这在 0.5 及以后的版本中可用.

如果安装了 cowsay 软件包,ansible playbook 的输出已经进行了广泛的升级.可以尝试一下！

在执行一个 playbook 之前,想看看这个 playbook 的执行会影响到哪些 hosts,你可以这样做::

    ansible-playbook playbook.yml --list-hosts
   
.. seealso::

   :doc:`YAMLSyntax`
       Learn about YAML syntax
   :doc:`playbooks_best_practices`
       Various tips about managing playbooks in the real world
   :doc:`index`
       Hop back to the documentation index for a lot of special topics about playbooks
   :doc:`modules`
       Learn about available modules
   :doc:`developing_modules`
       Learn how to extend Ansible by writing your own modules
   :doc:`intro_patterns`
       Learn about how to select hosts
   `Github examples directory <https://github.com/ansible/ansible-examples>`_
       Complete end-to-end playbook examples
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups



