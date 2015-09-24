简介
============

模块(也被称为 "task plugins" 或 "library plugins")是在 Ansible 中实际在执行的.它们就
是在每个 playbook 任务中被执行的.你也可以仅仅通过 'ansible' 命令来运行它们.

让我们回顾一下我们是如何通过命令行来执行三个不同的模块::

    ansible webservers -m service -a "name=httpd state=started"
    ansible webservers -m ping
    ansible webservers -m command -a "/sbin/reboot -t now"

每个模块都能接收参数. 几乎所有的模块都接受键值对(``key=value``)参数,空格分隔.一些模块
不接收参数,只需在命令行输入相关的命令就能调用.

在 playbook 中, Ansible 模块以类似的方式执行::

    - name: reboot the servers
      action: command /sbin/reboot -t now

也可以简写成::

    - name: reboot the servers
      command: /sbin/reboot -t now

另一种给模块传递参数的方式是使用 ymal 语法,这也被称为 'complex args' ::

    - name: restart webserver
      service:
        name: httpd
        state: restarted

无论你是使用命令行还是 playbooks 所有模块都会返回以 JSON 格式组织的数据.一般来说,对此你
无需知道太多.但如果你在编写你自己的模块,那你需要在意,这意味着你不需要以特定的语言来编写
你的模块 -- 你可以自行选择.

模块努力使自身幂等,这意味着它们会尽可能避免对系统做出改动除非那是必须的.当使用 Ansible
playbooks 时,这些模块能够触发 'change events',以这种形式通知 'handlers' 去运行附加任务.

每个模块的文档能够通过命令行的 ansible-doc 工具来获取::

    ansible-doc yum

列出所有已安装的模块文档::

    ansible-doc -l


.. seealso::

   :doc:`intro_adhoc`
       Examples of using modules in /usr/bin/ansible
   :doc:`playbooks`
       Examples of using modules with /usr/bin/ansible-playbook
   :doc:`developing_modules`
       How to write your own modules
   :doc:`developing_api`
       Examples of using modules with the Python API
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel
