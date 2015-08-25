Playbooks 介绍
==================

.. _about_playbooks:

Playbooks 简介
```````````````

Playbooks 与 adhoc 相比，是一种完全不同的运用 ansible 的方式，是非常之强大的。

简单来说，playbooks 是一种简单的配置管理系统与多机器部署系统的基础。与现有的其他系统有不同之处，且非常适合于复杂应用的部署。

Playbooks 可用于声明配置，更强大的地方在于，在 playbooks 中可以编排有序的执行过程，甚至于做到在多组机器间，来回有序的执行特别指定的步骤。并且可以同步或异步的发起任务。

我们使用 adhoc 时，主要是使用 /usr/bin/ansible 程序执行任务。而使用 playbooks 时，更多是将之放入源码控制之中，用之推送你的配置或是用于确认你的远程系统的配置是否符合配置规范。

在如右的连接中: `ansible-examples repository <https://github.com/ansible/ansible-examples>`_ ，有一些整套的playbooks，它们阐明了上述的这些技巧。我们建议你在另一个标签页中打开它看看，配合本章节一起看。

即便学完 playbooks 这个章节，仍有许多知识点只是入门的级别，完成本章的学习后，可回到文档索引继续学习。



.. _playbook_language_example:

Playbook 语言的示例
`````````````````````````

Playbooks 的格式是YAML（详见：:doc:`YAMLSyntax`），语法做到最小化，意在避免 playbooks 成为一种编程语言或是脚本，但它也并不是一个配置模型或过程的模型。

playbook 由一个或多个 'plays' 组成。它的内容是一个以 'plays' 为元素的列表。

在 play 之中，一组机器被映射为定义好的角色。在 ansible 中，play 的内容，被称为 tasks，即任务。在基本层次的应用中，一个任务是一个对 ansible 模块的调用，这在前面章节学习过。

'plays' 好似音符，playbook 好似由 'plays' 构成的曲谱，通过 playbook，可以编排步骤进行多机器的部署，比如在 webservers 组的所有机器上运行一定的步骤，
然后在 database server 组运行一些步骤，最后回到 webservers 组，再运行一些步骤，诸如此类。

"plays" 算是一个体育方面的类比，你可以通过多个 plays 告诉你的系统做不同的事情，不仅是定义一种特定的状态或模型。你可以在不同时间运行不同的 plays。

对初学者，这里有一个 playbook，其中仅包含一个 play::

    ---
    - hosts: webservers
      vars:
        http_port: 80
        max_clients: 200
      remote_user: root
      tasks:
      - name: ensure apache is at the latest version
        yum: pkg=httpd state=latest
      - name: write the apache config file
        template: src=/srv/httpd.j2 dest=/etc/httpd.conf
        notify:
        - restart apache
      - name: ensure apache is running
        service: name=httpd state=started
      handlers:
        - name: restart apache
          service: name=httpd state=restarted


在下面，我们将分别讲解 playbook 语言的多个特性。



.. _playbook_basics:

playbook基础
`````````````

.. _playbook_hosts_and_users:

主机与用户
+++++++++++++++

你可以为 playbook 中的每一个 play，个别地选择操作的目标机器是哪些，以哪个用户身份去完成要执行的步骤（called tasks）。

`hosts` 行的内容是一个或多个组或主机的 patterns，以逗号为分隔符，详见 :doc:`intro_patterns` 章节。
 `remote_user` 就是账户名::

    ---
    - hosts: webservers
      remote_user: root

.. note::

	参数 `remote_user` 以前写做 `user`，在 Ansible 1.4 以后才改为 remote_user。主要为了不跟 `user` 模块混淆（user 模块用于在远程系统上创建用户）。
	
再者，在每一个 task 中，可以定义自己的远程用户::

    ---
    - hosts: webservers
      remote_user: root
      tasks:
        - name: test connection
          ping:
          remote_user: yourname

.. note::

	task 中的 `remote_user` 参数在 1.4 版本以后添加。


也支持从 sudo 执行命令::

    ---
    - hosts: webservers
      remote_user: yourname
      sudo: yes

同样的，你可以仅在一个 task 中，使用 sudo 执行命令，而不是在整个 play 中使用 sudo::

    ---
    - hosts: webservers
      remote_user: yourname
      tasks:
        - service: name=nginx state=started
          sudo: yes


你也可以登陆后，sudo 到不同的用户身份，而不是使用 root::

    ---
    - hosts: webservers
      remote_user: yourname
      sudo: yes
      sudo_user: postgres


如果你需要在使用 sudo 时指定密码，可在运行 `ansible-playbook` 命令时加上选项 ``--ask-sudo-pass`` (`-K`)。
如果使用 sudo 时，playbook 疑似被挂起，可能是在 sudo prompt 处被卡住，这时可执行 `Control-C` 杀死卡住的任务，再重新运行一次。

.. important::

   当使用 `sudo_user` 切换到 非root 用户时，模块的参数会暂时写入 /tmp 目录下的一个随机临时文件。
   当命令执行结束后，临时文件立即删除。这种情况发生在普通用户的切换时，比如从 'bob' 切换到 'timmy'，
   切换到 root 账户时，不会发生，如从 'bob' 切换到 'root'，直接以普通用户或root身份登录也不会发生。
   如果你不希望这些数据在短暂的时间内可以被读取（不可写），请避免在 `sudo_user` 中传递未加密的密码。
   其他情况下，'/tmp' 目录不被使用，这种情况不会发生。Ansible 也有意识的在日志中不记录密码参数。
   
   
.. _tasks_list:

Tasks list
++++++++++

Each play contains a list of tasks.  Tasks are executed in order, one
at a time, against all machines matched by the host pattern,
before moving on to the next task.  It is important to understand that, within a play,
all hosts are going to get the same task directives.  It is the purpose of a play to map
a selection of hosts to tasks.

When running the playbook, which runs top to bottom, hosts with failed tasks are
taken out of the rotation for the entire playbook.  If things fail, simply correct the playbook file and rerun.

The goal of each task is to execute a module, with very specific arguments.
Variables, as mentioned above, can be used in arguments to modules.

Modules are 'idempotent', meaning if you run them
again, they will make only the changes they must in order to bring the
system to the desired state.  This makes it very safe to rerun
the same playbook multiple times.  They won't change things
unless they have to change things.

The `command` and `shell` modules will typically rerun the same command again,
which is totally ok if the command is something like
'chmod' or 'setsebool', etc.  Though there is a 'creates' flag available which can
be used to make these modules also idempotent.

Every task should have a `name`, which is included in the output from
running the playbook.   This is output for humans, so it is
nice to have reasonably good descriptions of each task step.  If the name
is not provided though, the string fed to 'action' will be used for
output.

Tasks can be declared using the legacy "action: module options" format, but 
it is recommended that you use the more conventional "module: options" format.
This recommended format is used throughout the documentation, but you may
encounter the older format in some playbooks.

Here is what a basic task looks like. As with most modules,
the service module takes key=value arguments::

   tasks:
     - name: make sure apache is running
       service: name=httpd state=running

The `command` and `shell` modules are the only modules that just take a list
of arguments and don't use the key=value form.  This makes
them work as simply as you would expect::

   tasks:
     - name: disable selinux
       command: /sbin/setenforce 0

The command and shell module care about return codes, so if you have a command
whose successful exit code is not zero, you may wish to do this::

   tasks:
     - name: run this command and ignore the result
       shell: /usr/bin/somecommand || /bin/true

Or this::

   tasks:
     - name: run this command and ignore the result
       shell: /usr/bin/somecommand
       ignore_errors: True


If the action line is getting too long for comfort you can break it on
a space and indent any continuation lines::

    tasks:
      - name: Copy ansible inventory file to client
        copy: src=/etc/ansible/hosts dest=/etc/ansible/hosts
                owner=root group=root mode=0644

Variables can be used in action lines.   Suppose you defined
a variable called 'vhost' in the 'vars' section, you could do this::

   tasks:
     - name: create a virtual host file for {{ vhost }}
       template: src=somefile.j2 dest=/etc/httpd/conf.d/{{ vhost }}

Those same variables are usable in templates, which we'll get to later.

Now in a very basic playbook all the tasks will be listed directly in that play, though it will usually
make more sense to break up tasks using the 'include:' directive.  We'll show that a bit later.



.. _action_shorthand:

Action Shorthand
````````````````

.. versionadded:: 0.8

Ansible prefers listing modules like this in 0.8 and later::

    template: src=templates/foo.j2 dest=/etc/foo.conf

You will notice in earlier versions, this was only available as::

    action: template src=templates/foo.j2 dest=/etc/foo.conf

The old form continues to work in newer versions without any plan of deprecation.



.. _handlers:

Handlers: Running Operations On Change
``````````````````````````````````````

As we've mentioned, modules are written to be 'idempotent' and can relay  when
they have made a change on the remote system.   Playbooks recognize this and
have a basic event system that can be used to respond to change.

These 'notify' actions are triggered at the end of each block of tasks in a playbook, and will only be
triggered once even if notified by multiple different tasks.

For instance, multiple resources may indicate
that apache needs to be restarted because they have changed a config file,
but apache will only be bounced once to avoid unnecessary restarts.

Here's an example of restarting two services when the contents of a file
change, but only if the file changes::

   - name: template configuration file
     template: src=template.j2 dest=/etc/foo.conf
     notify:
        - restart memcached
        - restart apache

The things listed in the 'notify' section of a task are called
handlers.

Handlers are lists of tasks, not really any different from regular
tasks, that are referenced by name.  Handlers are what notifiers
notify.  If nothing notifies a handler, it will not run.  Regardless
of how many things notify a handler, it will run only once, after all
of the tasks complete in a particular play.

Here's an example handlers section::

    handlers:
        - name: restart memcached
          service:  name=memcached state=restarted
        - name: restart apache
          service: name=apache state=restarted

Handlers are best used to restart services and trigger reboots.  You probably
won't need them for much else.

.. note::
   Notify handlers are always run in the order written.

Roles are described later on.  It's worthwhile to point out that handlers are
automatically processed between 'pre_tasks', 'roles', 'tasks', and 'post_tasks'
sections.  If you ever want to flush all the handler commands immediately though,
in 1.2 and later, you can::

    tasks:
       - shell: some tasks go here
       - meta: flush_handlers
       - shell: some other tasks

In the above example any queued up handlers would be processed early when the 'meta'
statement was reached.  This is a bit of a niche case but can come in handy from
time to time.



.. _executing_a_playbook:

Executing A Playbook
````````````````````

Now that you've learned playbook syntax, how do you run a playbook?  It's simple.
Let's run a playbook using a parallelism level of 10::

    ansible-playbook playbook.yml -f 10

	
	
.. _ansible-pull:

Ansible-Pull
````````````

Should you want to invert the architecture of Ansible, so that nodes check in to a central location, instead
of pushing configuration out to them, you can.

Ansible-pull is a small script that will checkout a repo of configuration instructions from git, and then
run ansible-playbook against that content.

Assuming you load balance your checkout location, ansible-pull scales essentially infinitely.

Run ``ansible-pull --help`` for details.

There's also a `clever playbook <https://github.com/ansible/ansible-examples/blob/master/language_features/ansible_pull.yml>`_ available to configure ansible-pull via a crontab from push mode.



.. _tips_and_tricks:

Tips and Tricks
```````````````

Look at the bottom of the playbook execution for a summary of the nodes that were targeted
and how they performed.   General failures and fatal "unreachable" communication attempts are
kept separate in the counts.

If you ever want to see detailed output from successful modules as well as unsuccessful ones,
use the ``--verbose`` flag.  This is available in Ansible 0.5 and later.

Ansible playbook output is vastly upgraded if the cowsay
package is installed.  Try it!

To see what hosts would be affected by a playbook before you run it, you
can do this::

    ansible-playbook playbook.yml --list-hosts

.. seealso::

   :doc:`YAMLSyntax`
       Learn about YAML syntax
   :doc:`playbooks_best_practices`
       Various tips about managing playbooks in the real world
   :doc:`index`
       Hop back to the documentation index for a lot of special topics about playbooks
   :doc:`modules`
       Learn about available modules
   :doc:`developing_modules`
       Learn how to extend Ansible by writing your own modules
   :doc:`intro_patterns`
       Learn about how to select hosts
   `Github examples directory <https://github.com/ansible/ansible-examples>`_
       Complete end-to-end playbook examples
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups



