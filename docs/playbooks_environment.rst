Setting the Environment (and Working With Proxies)
==================================================

.. versionadded:: 1.1

你完全有可能遇到一些更新包需要通过proxy才能正常获取,或者甚至一部分包需要通过proxy升级而另外一部分包则不需要通过proxy.或者可能你的某个脚本需要调用某个环境变量才能正常运行.

Ansible 使用 'environment' 关键字对于环境部署的配置非常简单容易,下面是一个使用案例::

    - hosts: all
      remote_user: root

      tasks:

        - apt: name=cobbler state=installed
          environment:
            http_proxy: http://proxy.example.com:8080

The environment can also be stored in a variable, and accessed like so::

    - hosts: all
      remote_user: root

      # here we make a variable named "proxy_env" that is a dictionary
      vars:
        proxy_env:
          http_proxy: http://proxy.example.com:8080

      tasks:

        - apt: name=cobbler state=installed
          environment: proxy_env

While just proxy settings were shown above, any number of settings can be supplied.  The most logical place
to define an environment hash might be a group_vars file, like so::

    ---
    # file: group_vars/boston

    ntp_server: ntp.bos.example.com
    backup: bak.bos.example.com
    proxy_env:
      http_proxy: http://proxy.bos.example.com:8080
      https_proxy: http://proxy.bos.example.com:8080

.. seealso::

   :doc:`playbooks`
       An introduction to playbooks
   `User Mailing List <http://groups.google.com/group/ansible-devel>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel


