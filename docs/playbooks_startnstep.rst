从指定任务开始运行palybook以及分步运行playbook
===============================================

以下列出了几种方式来运行playbook.这对于测试或调试新的playbook很有帮助.


.. _start_at_task:

Start-at-task
`````````````

如果你想从指定的任务开始执行playbook,可以使用``--start-at``选项::

    ansible-playbook playbook.yml --start-at="install packages"

以上命令就会在名为"install packages"的任务开始执行你的playbook.

.. _step:

分步运行playbook
````````````````````````

我们也可以通过``--step``选项来交互式的执行playbook::

    ansible-playbook playbook.yml --step

这样ansible在每个任务前会自动停止,并询问是否应该执行该任务.

比如你有个名为``configure ssh``的任务,playbook执行到这里会停止并询问::

    Perform task: configure ssh (y/n/c):

"y"回答会执行该任务,"n"回答会跳过该任务,而"c"回答则会继续执行剩余的所有任务而不再询问你.

