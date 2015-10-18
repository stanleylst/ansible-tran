共同的返回值
====================

.. contents:: Topics

Ansible模块通常返回一个数据结构将其注册到变量中, 或者直接作为`ansible`程序的输出. 这里我们记录了所有模块的共同值, 每一个模块可以任意返回他们所独有的值. 因为这些文档的存在人们可以通过ansible-doc和https://docs.ansible.com看到.

.. _facts:

Facts
`````

一些模块返回'facts'(例如 setup), 这些是通过一个'ansible_facts'作为key和内部一些自动收集的值直接作为当前主机的变量并且他们不需要注册这些数据


.. _status:

Status
``````

每一个模块都必须返回一个status, 来表示这个模块是成功的,是否有任何改变或没有. 当因为用户的条件(when: )或在检查模式下运行时发现该模块不支持, Ansible自己将会返回一个status并跳过这个模块.


.. _other:

其他的共同返回
````````````````````

通常在失败或者成功时返回一个'msg', 这被用来解释执行失败的原因或者关于执行的过程说明
一些模块, 特别是那些执行shell或者commands指令, 将返回stdout和stderr, 如果ansible发现输出结果, 它将追加一条线, 这在输出上仅仅是一个列表或一条线.

.. seealso::

   :doc:`modules`
       Learn about available modules
   `GitHub Core modules directory <https://github.com/ansible/ansible-modules-core/tree/devel>`_
       Browse source of core modules
   `Github Extras modules directory <https://github.com/ansible/ansible-modules-extras/tree/devel>`_
       Browse source of extras modules.
   `Mailing List <http://groups.google.com/group/ansible-devel>`_
       Development mailing list
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel
