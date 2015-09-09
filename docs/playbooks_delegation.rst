Delegation, Rolling Updates, and Local Actions
==============================================

.. contents:: Topics

由于设计初衷是作为多用户，Anisible很擅长在某一个主机上代表另一个做事，或者参考远程主机做一些本地工作。

这个特性对于架设连续实现某些设施或者0暂停滚动升级，这里你可能会提到负载均衡或者监控系统。

更多的特性允许调试事情完成的顺序，和设置一批窗口，来确定多少机器在一次中滚动更新。 

这节会介绍所有这些特性。`详情案例参见 <http://github.com/ansible/ansible-examples/>`_。这里有很多案例来说明对于不同程序来实行，0暂停更新步骤

你也可以参考:doc:`modules`部分，很多模块例如 'ec2_elb', 'nagios', 'bigip_pool', 'netscaler' 的一些概念会在这里介绍。

你可能也想参考:doc:`playbooks_roles`，你可以找到类似'pre_task'和'post_task'的详细介绍和调用方式。 

.. _rolling_update_batch_size:

Rolling Update Batch Size
滚动更新批量尺寸
`````````````````````````

.. versionadded:: 0.7

默认来说，Anisble 可以使图参考某一个play来并行操作所有主机。对于滚动更新案例，
你可以定义Ansible可以在一个特定时间同时控制多少主机，使用''serial'' 关键词::

    - name: test play
      hosts: webservers
      serial: 3

在上面的例子，如果我们有100台主机，3 台主机定义在组'webservers'
可以在下面3个主机开始之前完全完成

这个''serial'' 关键词在Ansible 1.8 以后可以被定义为百分数，用来定义每一次操作一个play中百分之多少主机::

    - name: test play
      hosts: websevers
      serial: "30%"

如果主机数不能被passes数量整除，最后的pass将会包含提醒信息

.. 注意::
     不管多小的百分比，每个pass的主机数一定会大于等于1.
.. _maximum_failure_percentage:

最大失败百分比
``````````````````````````

.. versionadded:: 1.3

默认来说，Ansible 会持续执行行为只要在一个组中还有主机没有宕机。 
在有些情况下，例如之前提到的滚动更新，也许理想的情况是当一个失败数上线达到时主动宕掉这个play。为了达到这个目的，在
1.3版本中，你可以设置最大失败半分比::

    - hosts: webservers
      max_fail_percentage: 30
      serial: 10

在上面的例子中，如果在10个服务器中如果多余3个，其它的play就会主动宕掉。

.. 注意::

     这个百分比必须被超过，不仅仅是相等。例如如果serial值呗设置为4，并且你希望任务主动在2个系统失败时候放弃。那么这个百分比应该设置为49而不是50.

.. _delegation:

Delegation
``````````

.. versionadded:: 0.7

This isn't actually rolling update specific but comes up frequently in those cases.

If you want to perform a task on one host with reference to other hosts, use the 'delegate_to' keyword on a task.
This is ideal for placing nodes in a load balanced pool, or removing them.  It is also very useful for controlling
outage windows.  Using this with the 'serial' keyword to control the number of hosts executing at one time is also
a good idea::

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


These commands will run on 127.0.0.1, which is the machine running Ansible. There is also a shorthand syntax that you can use on a per-task basis: 'local_action'. Here is the same playbook as above, but using the shorthand syntax for delegating to 127.0.0.1::

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

Note that you must have passphrase-less SSH keys or an ssh-agent configured for this to work, otherwise rsync
will need to ask for a passphrase.

.. _run_once:

Run Once
````````

.. versionadded:: 1.7

In some cases there may be a need to only run a task one time and only on one host. This can be achieved
by configuring "run_once" on a task::

    ---
    # ...

      tasks:

        # ...

        - command: /opt/application/upgrade_db.py
          run_once: true

        # ...

This can be optionally paired with "delegate_to" to specify an individual host to execute on::

        - command: /opt/application/upgrade_db.py
          run_once: true
          delegate_to: web01.example.org

When "run_once" is not used with "delegate_to" it will execute on the first host, as defined by inventory,
in the group(s) of hosts targeted by the play. e.g. webservers[0] if the play targeted "hosts: webservers".

This approach is similar, although more concise and cleaner than applying a conditional to a task such as::

        - command: /opt/application/upgrade_db.py
          when: inventory_hostname == webservers[0]

.. _local_playbooks:

Local Playbooks
```````````````

It may be useful to use a playbook locally, rather than by connecting over SSH.  This can be useful
for assuring the configuration of a system by putting a playbook on a crontab.  This may also be used
to run a playbook inside an OS installer, such as an Anaconda kickstart.

To run an entire playbook locally, just set the "hosts:" line to "hosts:127.0.0.1" and then run the playbook like so::

    ansible-playbook playbook.yml --connection=local

Alternatively, a local connection can be used in a single playbook play, even if other plays in the playbook
use the default remote connection type::

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


