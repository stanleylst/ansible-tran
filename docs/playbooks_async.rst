Asynchronous Actions and Polling
================================


默认情况下,在 playbook 块中的任务意味着 SSH 连接会保持着直至每个节点都完成任务.
这也许不是一直是你想要,你也许会想要任务的运行时间长于 SSH 的超时时间.


最容易的实现方法是一次启动所有的任务然后不停地轮询直至所有的任务都完成.


你也会想要在执行容易超时的任务时使用异步模式.


要想使一个任务异步执行,你需要指定它的最长运行时间以及对它状态的轮询频率.如果你
不指定 poll 的值,那么默认下每 10 秒会查询一次. `poll`::

    ---

    - hosts: all
      remote_user: root

      tasks:

      - name: simulate long running op (15 sec), wait for up to 45 sec, poll every 5 sec
        command: /bin/sleep 15
        async: 45
        poll: 5

.. note::
   异步的执行时间没有设置默认值.如果你设置 'async' 的默认值,那么 Ansible 默认就会同步执行该任务.

另外,如果你不需要等待任务的完成,你可以通过设定 poll 的值为 0 即可实现"发射后不管" ::

    ---

    - hosts: all
      remote_user: root

      tasks:

      - name: simulate long running op, allow to run for 45 sec, fire and forget
        command: /bin/sleep 15
        async: 45
        poll: 0

.. note::
   你不应该将任何要求排它锁的任务设置为"发射后不管",诸如 yum 操作.
   如果你希望稍后对同样的资源执行 playbook 中的其他任务,这将产生冲突.

.. note::
   给 ``--forks`` 选项设置一个更高的值会使异步任务启动的更快.这也会增加轮询的效率.

如果你想要是一个任务执行"发射后不管"的变种,即"发射后暂不管,稍后检查",你可以以如下的方式实现::

      --- 
      # Requires ansible 1.8+
      - name: 'YUM - fire and forget task'
        yum: name=docker-io state=installed
        async: 1000
        poll: 0
        register: yum_sleeper

      - name: 'YUM - check on fire and forget task'
        async_status: jid={{ yum_sleeper.ansible_job_id }}
        register: job_result
        until: job_result.finished
        retries: 30

.. note::
   如果 ``async:`` 设置的值不够高,这会造成"check on it later"的任务执行失败.
   因为用来检验 ``async_status:`` 临时状态文件还未被写入.

.. seealso::

   :doc:`playbooks`
       An introduction to playbooks
   `User Mailing List <http://groups.google.com/group/ansible-devel>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

