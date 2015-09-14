委托,滚动更新,本地动作
==============================================

.. contents:: Topics

由于设计初衷是作为多用户,Anisible很擅长在某一个主机上代表另一个做事,或者参考远程主机做一些本地工作.

这个特性对于架设连续实现某些设施或者0暂停滚动升级,这里你可能会提到负载均衡或者监控系统.

更多的特性允许调试事情完成的顺序,和设置一批窗口,来确定多少机器在一次中滚动更新. 

这节会介绍所有这些特性.`详情案例参见 <http://github.com/ansible/ansible-examples/>`_.这里有很多案例来说明对于不同程序来实行,0暂停更新步骤

你也可以参考:doc:`modules`部分,很多模块例如 'ec2_elb', 'nagios', 'bigip_pool', 'netscaler' 的一些概念会在这里介绍.

你可能也想参考:doc:`playbooks_roles`,你可以找到类似'pre_task'和'post_task'的详细介绍和调用方式. 

.. _rolling_update_batch_size:

Rolling Update Batch Size
滚动更新批量尺寸
`````````````````````````

.. versionadded:: 0.7

默认来说,Anisble 可以使图参考某一个play来并行操作所有主机.对于滚动更新案例,
你可以定义Ansible可以在一个特定时间同时控制多少主机,使用''serial'' 关键词::

    - name: test play
      hosts: webservers
      serial: 3

在上面的例子,如果我们有100台主机,3 台主机定义在组'webservers'
可以在下面3个主机开始之前完全完成

这个''serial'' 关键词在Ansible 1.8 以后可以被定义为百分数,用来定义每一次操作一个play中百分之多少主机::

    - name: test play
      hosts: websevers
      serial: "30%"

如果主机数不能被passes数量整除,最后的pass将会包含提醒信息

.. note::
     不管多小的百分比,每个pass的主机数一定会大于等于1.
.. _maximum_failure_percentage:

最大失败百分比
``````````````````````````

.. versionadded:: 1.3

默认来说,Ansible 会持续执行行为只要在一个组中还有主机没有宕机. 
在有些情况下,例如之前提到的滚动更新,也许理想的情况是当一个失败数上线达到时主动宕掉这个play.为了达到这个目的,在
1.3版本中,你可以设置最大失败半分比::

    - hosts: webservers
      max_fail_percentage: 30
      serial: 10

在上面的例子中,如果在10个服务器中如果多余3个,其它的play就会主动宕掉.

.. note::

     这个百分比必须被超过,不仅仅是相等.例如如果serial值呗设置为4,并且你希望任务主动在2个系统失败时候放弃.那么这个百分比应该设置为49而不是50.

.. _delegation:

委任
``````````

.. versionadded:: 0.7

This isn't actually rolling update specific but comes up frequently in those cases.
这个虽然不属于滚动更新,但是在那些场景下经常会出现.

如果你想参考其它主机来在一个主机上执行一个任务,我们就可以使用'delegate_to'关键词在你要执行的任务上.
这个对于把节点放在一个负载均衡池里面活着从里面移除非常理想. 这个选项也对处理窗口中断非常有用.
使用'serial'关键词来控制一定数量的主机也是一个好想法::

    ---

    - hosts: webservers
      serial: 5

      tasks:

      - name: take out of load balancer pool
        command: /usr/bin/take_out_of_pool {{ inventory_hostname }}
        delegate_to: 127.0.0.1

      - name: actual steps would go here
        yum: name=acme-web-stack state=latest

      - name: add back to load balancer pool
        command: /usr/bin/add_back_to_pool {{ inventory_hostname }}
        delegate_to: 127.0.0.1


这些命令可以在127.0.0.1上面运行,这个运行Ansible的主机.这个也是一个简写的语法用在每一个任务基础（per-task basis）: 'local_action'.以上就是这样一个playbook.但是使用的是简化后的语法在172.0.0.1上面做代理::
    ---

    # ...

      tasks:

      - name: take out of load balancer pool
        local_action: command /usr/bin/take_out_of_pool {{ inventory_hostname }}

    # ...

      - name: add back to load balancer pool
        local_action: command /usr/bin/add_back_to_pool {{ inventory_hostname }}

A common pattern is to use a local action to call 'rsync' to recursively copy files to the managed servers.
Here is an example::

    ---
    # ...
      tasks:

      - name: recursively copy files from management server to target
        local_action: command rsync -a /path/to/files {{ inventory_hostname }}:/path/to/target/

注意你必须拥有不需要密码SSH密钥或者ssh-agent配置,不然的话rsync会需要询问密码.

.. _run_once:

Run Once
````````

.. versionadded:: 1.7

有时候你有这样的需求,在一个主机上面只执行一次一个任务.这样的配置可以配置"run_once"来实现::

    ---
    # ...

      tasks:

        # ...

        - command: /opt/application/upgrade_db.py
          run_once: true

        # ...

这样可以添加在"delegat_to"选项对中来定义要执行的主机::

        - command: /opt/application/upgrade_db.py
          run_once: true
          delegate_to: web01.example.org

当"run_once" 没有喝"delegate_to"一起使用,这个任务将会被清单指定的第一个主机.
在一组被play制定主机.例如 webservers[0], 如果play指定为 "hosts: webservers".

这个方法也很类似,虽然比使用条件更加简单粗暴,如下事例::

        - command: /opt/application/upgrade_db.py
          when: inventory_hostname == webservers[0]

.. _local_playbooks:

本地Playbooks
```````````````

在本地使用playbook有时候比ssh远程使用更加有用.可以通过把playbook放在crontab中,来确保一个系统的配置,可以很有用.
在OS installer 中运行一个playbook也很有用.例如Anaconda kickstart. 

要想在本地运行一个play,可以直接设置"host:" 与 "hosts:127.0.0.1", 然后使用下面的命令运行::

    ansible-playbook playbook.yml --connection=local

或者,一个本地连接也可以作为一个单独的playbook play应用在playbook中, 即便playbook中其他的plays使用默认远程
连接如下::

    - hosts: 127.0.0.1
      connection: local

.. seealso::

   :doc:`playbooks`
       An introduction to playbooks
   `Ansible Examples on GitHub <http://github.com/ansible/ansible-examples>`_
       Many examples of full-stack deployments
   `User Mailing List <http://groups.google.com/group/ansible-devel>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel


