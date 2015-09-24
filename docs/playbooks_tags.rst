标签
====

如果你有一个大型的 playbook,那能够只运行其中特定部分的配置而无需运行整个 playbook
将会很有用.

plays 和 tasks 都因这个理由而支持 "tags:"

例::

    tasks:

        - yum: name={{ item }} state=installed
          with_items:
             - httpd
             - memcached
          tags:
             - packages

        - template: src=templates/src.j2 dest=/etc/foo.conf
          tags:
             - configuration

如果你只想运行一个非常大的 playbook 中的 "configuration" 和 "packages",你可以这样做::

    ansible-playbook example.yml --tags "configuration,packages"

另一方面,如果你只想执行 playbook 中某个特定任务 *之外* 的所有任务,你可以这样做::

    ansible-playbook example.yml --skip-tags "notification"

你同样也可以对 roles 应用 tags::

    roles:
      - { role: webserver, port: 5000, tags: [ 'web', 'foo' ] }

你同样也可以对基本的 include 语句使用 tag::

    - include: foo.yml tags=web,foo

以上这样也有对每个 include 语句中的单个任务进行标签的功能.

.. seealso::

   :doc:`playbooks`
       An introduction to playbooks
   :doc:`playbooks_roles`
       Playbook organization by roles
   `User Mailing List <http://groups.google.com/group/ansible-devel>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel
