Playbook Roles and Include Statements
=====================================

.. contents:: Topics

介绍
````````````````

当 playbook 文件越来越大的时候(你可以跳出来去学习 playbooks 了),最后一定会有文件重用时候,此刻就需要我们来重新组织 playbooks 了.

从最基本来讲, task files 请允许我们拆分配置策略到多个小文件. Task 可以从其它文件中读取 tasks. 因为 handler 也是tasks, 所以你也可以在在 'handlers:' 区域引用 handler 文件.

你可以查阅 :doc:`playbooks` 来复习该章节内容.

Playbooks 也可以引用其它 playbooks 文件中的命令条目.当所有文件均读取完毕后, 所有的命令条目将被插入到一个 playbook 中组合成一条长的命令列表.

当你开始思考 -- tasks, handlers, variables等 -- 开始形成大的想法概念,当你开始创造一些东西,而非模仿某些东西. It's no longer "apply this handful of THINGS to these hosts" ,你决定 "这些 hosts 是 dbservers" 或者 这些 hosts 是 webservers". 在编程语言中,我们称之为"封装".举个例子,你会开车但不需要知道发动机工作原理. 

Roles 在 Ansible中起到的宗旨是把配置文件整合到一起并最大程度保证其干净整洁,可重用 -- 他允许我们把重点放在大局上只有在需要的时候才再深入了解.

了解 includes 的对深入 roles 有重要意义,但我们最终的目标是理解 roles -- roles是非常伟大的产品,所以当我们写 playbooks 时一定要使用 roles.

阅读 `ansible-examples <https://github.com/ansible/ansible-examples>` 获取更多实例. 你可以打开单独的页面进行深入学习.


Task Include Files 和鼓励重用机制
````````````````````````````````````````

猜想你希望在不同 tasks 之间plays 和 playbooks 可以重复调用. include files可以达成目的. 系统通过使用 include task 来完美实现 role 定义. 记住, playbook 中的 play 最终目的是映射系统群到多 roles中. 我们来举个例子吧...

只简单包括 tasks 的 task 文件如下示例::

    ---
    # possibly saved as tasks/foo.yml

    - name: placeholder foo
      command: /bin/foo

    - name: placeholder bar
      command: /bin/bar

Include 指令类似如下,可以像普通 tasks 命令一样在 playbook 中混合使用::

   tasks:

     - include: tasks/foo.yml

你也可以传输变量到 includes 指令, 我们称之为 'parameterized include'.

例如,如何分发多个 wordpress 实例,我可以包涵所有 wordpress 命令到一个 wordpress.yml 文件,按如下方式使用::

   tasks:
     - include: wordpress.yml wp_user=timmy
     - include: wordpress.yml wp_user=alice
     - include: wordpress.yml wp_user=bob

如果你使用的是 Ansible 1.4以上版本(包括1.4), include 语法简化了匹配 roles, 同时允许传递参数列表和字典::
   
    tasks:
     - { include: wordpress.yml, wp_user: timmy, ssh_keys: [ 'keys/one.txt', 'keys/two.txt' ] }

使用任意一种语法, 变量传递均可以在 included 文件中被使用. 我们将在 :doc:`playbooks_variables` 详细讨论. 你可以这样引用他们::

   {{ wp_user }}

(除了明确声明定义参数,所有 vars 区块定义的变量在这里同样适用.)

从1.0开始, ansible 还支持另外一种变量传参到 include files 的方式-结构化变量,方式如下::

    tasks:

      - include: wordpress.yml
        vars:
            wp_user: timmy
            ssh_keys:
              - keys/one.txt
              - keys/two.txt

Playbooks 也同样可以 include 引用其它 playbooks,但这部分内容将在另外章节介绍.

.. note::

   截止1.0版本,task include 声明可以在任意层级目录使用.在这之前,变量只能同层级目录引用,所以 task includes 不能引用其实包含有 task includes 引用的task文件.

Includes 功能也可以被用在用 handlers 区域,例如,如果你希望定义如何重启apache,你只需要定义一个playbook,只需要做一次.编辑类似如下样例的 handers.yml::

   ---
   # this might be in a file like handlers/handlers.yml
   - name: restart apache
     service: name=apache state=restarted

然后像如下方式在 main playbook 的询问引用play即可::

   handlers:
     - include: handlers/handlers.yml

Includes也可以在常规不包含 included 的tasks和handlers文件中混合引用.
Includes常被用作将一个playbook文件中的命令导入到另外一个playbook.这种方式允许我们定义由其它playbooks组成的顶层playbook(top-level playbook).

For example::

    - name: this is a play at the top level of a file
      hosts: all
      remote_user: root

      tasks:

      - name: say hi
        tags: foo
        shell: echo "hi..."

    - include: load_balancers.yml
    - include: webservers.yml
    - include: dbservers.yml

注意: 引用playbook到其它playbook时,变量替换功能将失效不可用.

.. note::

   你不能有条件的指定位置的 include 文件,就像在你使用 'vars_files' 时一样.
   如果你发展你必须这么做,那请重新规划调整 playbook 的class/role 编排.这样
   说其实是想明确告诉你不要妄想 include 指定位置的file. 所有被包含在 play 
   中的主机都将执行相同的tasks.('*when*'提供了一些指定条件来跳过tasks)

.. _roles:

Roles
`````

.. versionadded:: 1.2

Now that you have learned about tasks and handlers, what is the best way to organize your playbooks?
The short answer is to use roles!  Roles are ways of automatically loading certain vars_files, tasks, and
handlers based on a known file structure.  Grouping content by roles also allows easy sharing of roles with other users.

Roles are just automation around 'include' directives as described above, and really don't contain much
additional magic beyond some improvements to search path handling for referenced files.  However, that can be a big thing!

Example project structure::

    site.yml
    webservers.yml
    fooservers.yml
    roles/
       common/
         files/
         templates/
         tasks/
         handlers/
         vars/
         defaults/
         meta/
       webservers/
         files/
         templates/
         tasks/
         handlers/
         vars/
         defaults/
         meta/

In a playbook, it would look like this::

    ---
    - hosts: webservers
      roles:
         - common
         - webservers

This designates the following behaviors, for each role 'x':

- If roles/x/tasks/main.yml exists, tasks listed therein will be added to the play
- If roles/x/handlers/main.yml exists, handlers listed therein will be added to the play
- If roles/x/vars/main.yml exists, variables listed therein will be added to the play
- If roles/x/meta/main.yml exists, any role dependencies listed therein will be added to the list of roles (1.3 and later)
- Any copy tasks can reference files in roles/x/files/ without having to path them relatively or absolutely
- Any script tasks can reference scripts in roles/x/files/ without having to path them relatively or absolutely
- Any template tasks can reference files in roles/x/templates/ without having to path them relatively or absolutely
- Any include tasks can reference files in roles/x/tasks/ without having to path them relatively or absolutely
   
In Ansible 1.4 and later you can configure a roles_path to search for roles.  Use this to check all of your common roles out to one location, and share
them easily between multiple playbook projects.  See :doc:`intro_configuration` for details about how to set this up in ansible.cfg.

.. note::
   Role dependencies are discussed below.

If any files are not present, they are just ignored.  So it's ok to not have a 'vars/' subdirectory for the role,
for instance.

Note, you are still allowed to list tasks, vars_files, and handlers "loose" in playbooks without using roles,
but roles are a good organizational feature and are highly recommended.  If there are loose things in the playbook,
the roles are evaluated first.

Also, should you wish to parameterize roles, by adding variables, you can do so, like this::

    ---

    - hosts: webservers
      roles:
        - common
        - { role: foo_app_instance, dir: '/opt/a',  port: 5000 }
        - { role: foo_app_instance, dir: '/opt/b',  port: 5001 }

While it's probably not something you should do often, you can also conditionally apply roles like so::

    ---

    - hosts: webservers
      roles:
        - { role: some_role, when: "ansible_os_family == 'RedHat'" }

This works by applying the conditional to every task in the role.  Conditionals are covered later on in
the documentation.

Finally, you may wish to assign tags to the roles you specify. You can do so inline:::

    ---

    - hosts: webservers
      roles:
        - { role: foo, tags: ["bar", "baz"] }


If the play still has a 'tasks' section, those tasks are executed after roles are applied.

If you want to define certain tasks to happen before AND after roles are applied, you can do this::

    ---

    - hosts: webservers

      pre_tasks:
        - shell: echo 'hello'

      roles:
        - { role: some_role }

      tasks:
        - shell: echo 'still busy'

      post_tasks:
        - shell: echo 'goodbye'

.. note::
   If using tags with tasks (described later as a means of only running part of a playbook),  
   be sure to also tag your pre_tasks and post_tasks and pass those along as well, especially if the pre
   and post tasks are used for monitoring outage window control or load balancing.

Role Default Variables
``````````````````````

.. versionadded:: 1.3

Role default variables allow you to set default variables for included or dependent roles (see below). To create
defaults, simply add a `defaults/main.yml` file in your role directory. These variables will have the lowest priority
of any variables available, and can be easily overridden by any other variable, including inventory variables.

Role Dependencies
`````````````````

.. versionadded:: 1.3

Role dependencies allow you to automatically pull in other roles when using a role. Role dependencies are stored in the
`meta/main.yml` file contained within the role directory. This file should contain 
a list of roles and parameters to insert before the specified role, such as the following in an example
`roles/myapp/meta/main.yml`::

    ---
    dependencies:
      - { role: common, some_parameter: 3 }
      - { role: apache, port: 80 }
      - { role: postgres, dbname: blarg, other_parameter: 12 }

Role dependencies can also be specified as a full path, just like top level roles::

    ---
    dependencies:
       - { role: '/path/to/common/roles/foo', x: 1 }

Role dependencies can also be installed from source control repos or tar files (via `galaxy`) using comma separated format of path, an optional version (tag, commit, branch etc) and optional friendly role name (an attempt is made to derive a role name from the repo name or archive filename). Both through the command line or via a requirements.yml passed to ansible-galaxy.


Roles dependencies are always executed before the role that includes them, and are recursive. By default, 
roles can also only be added as a dependency once - if another role also lists it as a dependency it will
not be run again. This behavior can be overridden by adding `allow_duplicates: yes` to the `meta/main.yml` file.
For example, a role named 'car' could add a role named 'wheel' to its dependencies as follows::

    ---
    dependencies:
    - { role: wheel, n: 1 }
    - { role: wheel, n: 2 }
    - { role: wheel, n: 3 }
    - { role: wheel, n: 4 }

And the `meta/main.yml` for wheel contained the following::

    ---
    allow_duplicates: yes
    dependencies:
    - { role: tire }
    - { role: brake }

The resulting order of execution would be as follows::

    tire(n=1)
    brake(n=1)
    wheel(n=1)
    tire(n=2)
    brake(n=2)
    wheel(n=2)
    ...
    car

.. note::
   Variable inheritance and scope are detailed in the :doc:`playbooks_variables`.

Embedding Modules In Roles
``````````````````````````

This is an advanced topic that should not be relevant for most users.

If you write a custom module (see :doc:`developing_modules`) you may wish to distribute it as part of a role.  Generally speaking, Ansible as a project is very interested
in taking high-quality modules into ansible core for inclusion, so this shouldn't be the norm, but it's quite easy to do.

A good example for this is if you worked at a company called AcmeWidgets, and wrote an internal module that helped configure your internal software, and you wanted other
people in your organization to easily use this module -- but you didn't want to tell everyone how to configure their Ansible library path.

Alongside the 'tasks' and 'handlers' structure of a role, add a directory named 'library'.  In this 'library' directory, then include the module directly inside of it.

Assuming you had this::

    roles/
       my_custom_modules/
           library/
              module1
              module2

The module will be usable in the role itself, as well as any roles that are called *after* this role, as follows::


    - hosts: webservers
      roles:
        - my_custom_modules
        - some_other_role_using_my_custom_modules
        - yet_another_role_using_my_custom_modules

This can also be used, with some limitations, to modify modules in Ansible's core distribution, such as to use development versions of modules before they are released
in production releases.  This is not always advisable as API signatures may change in core components, however, and is not always guaranteed to work.  It can be a handy
way of carrying a patch against a core module, however, should you have good reason for this.  Naturally the project prefers that contributions be directed back
to github whenever possible via a pull request.

Ansible Galaxy
``````````````

`Ansible Galaxy <http://galaxy.ansible.com>`_ is a free site for finding, downloading, rating, and reviewing all kinds of community developed Ansible roles and can be a great way to get a jumpstart on your automation projects.

You can sign up with social auth, and the download client 'ansible-galaxy' is included in Ansible 1.4.2 and later.

Read the "About" page on the Galaxy site for more information.

.. seealso::

   :doc:`galaxy`
       How to share roles on galaxy, role management
   :doc:`YAMLSyntax`
       Learn about YAML syntax
   :doc:`playbooks`
       Review the basic Playbook language features
   :doc:`playbooks_best_practices`
       Various tips about managing playbooks in the real world
   :doc:`playbooks_variables`
       All about variables in playbooks
   :doc:`playbooks_conditionals`
       Conditionals in playbooks
   :doc:`playbooks_loops`
       Loops in playbooks
   :doc:`modules`
       Learn about available modules
   :doc:`developing_modules`
       Learn how to extend Ansible by writing your own modules
   `GitHub Ansible examples <https://github.com/ansible/ansible-examples>`_
       Complete playbook files from the GitHub project source
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups

