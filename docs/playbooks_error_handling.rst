Playbooks 中的错误处理
===========================

.. contents:: Topics

Ansible 通常默认会确保检测模块和命令的返回码并且会快速失败 -- 专注于一个错误除非你另作打算.

有时一条命令会返回 0 但那不是报错.有时命令不会总是报告它 '改变' 了远程系统.本章节描述了
如何将 Ansible 处理输出结果和错误处理的默认行为改变成你想要的.

.. _ignoring_failed_commands:

忽略错误的命令
````````````````````````

.. versionadded:: 0.6

通常情况下, 当出现失败时 Ansible 会停止在宿主机上执行.有时候,你会想要继续执行下去.为此
你需要像这样编写任务::

    - name: this will not be counted as a failure
      command: /bin/false
      ignore_errors: yes

注意上面的系统仅仅处理那个特定的任务,所以当你在使用一个未定义的变量时, Ansible 仍然会报
错,需要使用者进行处理.

.. _controlling_what_defines_failure:

控制对失败的定义
````````````````````````````````

.. versionadded:: 1.4

假设一条命令的错误码毫无意义只有它的输出结果能告诉你什么出了问题,比如说字符串 "FAILED" 出
现在输出结果中.

在 Ansible 1.4及之后的版本中提供了如下的方式来指定这样的特殊行为::

    - name: this command prints FAILED when it fails
      command: /usr/bin/example-command -x -y -z
      register: command_result
      failed_when: "'FAILED' in command_result.stderr"

在 Ansible 1.4 之前的版本能通过如下方式完成::

    - name: this command prints FAILED when it fails
      command: /usr/bin/example-command -x -y -z
      register: command_result
      ignore_errors: True

    - name: fail the play if the previous command did not succeed
      fail: msg="the command failed"
      when: "'FAILED' in command_result.stderr"

.. _override_the_changed_result:

覆写更改结果
`````````````````````````````

.. versionadded:: 1.3

When a shell/command or other module runs it will typically report
"changed" status based on whether it thinks it affected machine state.
当一个 shell或命令或其他模块运行时,它们往往都会在它们认为其影响机器状态时报告 "changed"
状态

有时你可以通过返回码或是输出结果来知道它们其实并没有做出任何更改.你希望覆写结果的
 "changed" 状态使它不会出现在输出的报告或不会触发其他处理程序::

    tasks:

      - shell: /usr/bin/billybass --mode="take me to the river"
        register: bass_result
        changed_when: "bass_result.rc != 2"

      # this will never report 'changed' status
      - shell: wall 'beep'
        changed_when: False


.. seealso::

   :doc:`playbooks`
       An introduction to playbooks
   :doc:`playbooks_best_practices`
       Best practices in playbooks
   :doc:`playbooks_conditionals`
       Conditional statements in playbooks
   :doc:`playbooks_variables`
       All about variables
   `User Mailing List <http://groups.google.com/group/ansible-devel>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel
