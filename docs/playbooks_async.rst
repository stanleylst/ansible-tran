异步操作和轮询
================================


默认情况下playbook中的任务执行时会一直保持连接,直到该任务在每个节点都执行完毕.有时这是不必要的,比如有些操作运行时间比SSH超时时间还要长.

解决该问题最简单的方式是一起执行它们,然后轮询直到任务执行完毕.

你也可以对执行时间非常长（有可能遭遇超时）的操作使用异步模式.

为了异步启动一个任务,可以指定其最大超时时间以及轮询其状态的频率.如果你没有为 `poll` 指定值,那么默认的轮询频率是10秒钟::

    ---

    - hosts: all
      remote_user: root

      tasks:

      - name: simulate long running op (15 sec), wait for up to 45 sec, poll every 5 sec
        command: /bin/sleep 15
        async: 45
        poll: 5

.. note::

   `async` 并没有默认值,如果你没有指定 `async` 关键字,那么任务会以同步的方式运行,这是Ansible的默认行为.

另外,如果你不需要等待任务执行完毕,你可以指定 `poll` 值为0而启用 "启动并忽略" ::

    ---

    - hosts: all
      remote_user: root

      tasks:

      - name: simulate long running op, allow to run for 45 sec, fire and forget
        command: /bin/sleep 15
        async: 45
        poll: 0

.. note::

   对于要求排它锁的操作,如果你需要在其之后对同一资源执行其它任务,那么你不应该对该操作使用"启动并忽略".比如yum事务.

.. note::

   ``--forks`` 参数值过大会更快的触发异步任务.也会加快轮询的效率.

当你想对 "启动并忽略" 做个变种,改为"启动并忽略,稍后再检查",你可以使用以下方式执行任务::

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

   如果 ``async:`` 值太小,可能会导致 "稍后检查" 任务执行失败,因为 ``async_status::`` 的临时状态文件还未被写入信息,而"稍后检查"任务就试图读取此文件.


.. seealso::

   :doc:`playbooks`
       An introduction to playbooks
   `User Mailing List <http://groups.google.com/group/ansible-devel>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

