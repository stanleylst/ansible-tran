Check Mode ("Dry Run")
======================

.. versionadded:: 1.1

.. contents:: Topics

当以 ``--check`` 参数来运行 ansible-playbook 时,将不会对远程的系统作出任何更改.相对的,任何带有检测功能的模块(这几乎包含了所有的主要核心模块,但这不要求所有的模块都需支持.)
只要支持 '检测模式' 将会报告它们会做出什么改变而不是直接进行改变.其他不支持检测模式的模块将既不响应也不提出相应的报告.

检测模式只是一种模拟.如果你的playbook是以先前命令的执行结果作为条件的话,那它可能对你就没有什么大用处了.
但是对于基于一次一节点的基础配置管理的使用情形来说是很有用.

Example::

    ansible-playbook foo.yml --check

.. _forcing_to_run_in_check_mode:

在测试模式下运行一个任务.
````````````````````````````

.. versionadded:: 1.3

有时候你甚至会想在检测模式中执行一个任务.为了达到这样的效果,
你需要在相应的任务上使用 `always_run` 子句.跟 `when` 子句一样,它的值是一个 Jinja2 表达式.
在一个简单的例子中,布尔值也会表达为一个适当的 YAML 值.

Example::

    tasks:

      - name: this task is run even in check mode
        command: /something/to/run --even-in-check-mode
        always_run: yes

友情提示,带有 `when` 子句的任务会返回false,该任务将会被跳过,即使它还被添加了会返回true的 `always_run` 子句.

.. _diff_mode:

Showing Differences with ``--diff``
```````````````````````````````````

.. versionadded:: 1.1

 对 ansible-playbook 来说 ``--diff`` 选项与 ``--check`` (详情参下)配合使用效果奇佳,不过它也可以单独使用.当提供了相应的标识后,当远程系统上任何模板文件的变化时,ansible-playbook CLI 将会报告文件上任何文本的变化
 (或者,如果使用了 ``--check`` 参数,将报告会发生的变化.).因为 diff 特性会产生大量的输出结果,所以它在一次检测一个主机时使用为佳,如::

    ansible-playbook foo.yml --check --diff --limit foo.example.com
