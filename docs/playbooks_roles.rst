Playbook 角色(Roles) 和 Include 语句
=====================================

.. contents:: Topics

简介
````````````

当我们刚开始学习运用 playbook 时，可能会把 playbook 写成一个很大的文件，到后来可能你会希望这些文件是可以方便去重用的，所以需要重新去组织这些文件。

基本上，使用 include 语句引用 task 文件的方法，可允许你将一个配置策略分解到更小的文件中。使用 include 语句引用 tasks 是将 tasks 从其他文件拉取过来。因为 handlers 也是 tasks，所以你也可以使用 include 语句去引用 handlers 文件。handlers 文件来自 'handlers:' section。

如果你想复习一下这些概念的话，请参见 :doc:`playbooks` 。

Playbook 同样可以使用 include 引用其他 playbook 文件中的 play。这时被引用的 play 会被插入到当前的 playbook 中，当前的 playbook 中就有了一个更长的的 play 列表。

当你开始思考这些概念：tasks, handlers, variables 等等，是否可以将它们抽象为一个更大的概念呢。我们考虑的不再是"将这些 tasks，handlers，variables 等等应用到这些 hosts 中"，而是有了更抽象的概念，比如："这些 hosts 是 dbservers" 或者 "那些 hosts 是 webservers"（译者注：dbserver，webservers 即是"角色"）。这种思考方式在编程中被称为"封装"，将其中具体的功能封装了起来。举个例子，你会开车但并不需要知道引擎的工作原理（译者注：同样的道理，我们只需要知道"这些 hosts 是 dbservers"，而不需要知道其中有哪些 task，handlers 等）。

Roles 的概念来自于这样的想法：通过 include 包含文件并将它们组合在一起，组织成一个简洁、可重用的抽象对象。这种方式可使你将注意力更多地放在大局上，只有在需要时才去深入了解细节。

我们将从理解如何使用 include 开始，这样你会更容易理解 roles 的概念。但我们的终极目标是让你理解 roles，roles 是一个很棒的东西，每次你写 playbook 的时候都应该使用它。

在 `ansible-examples <https://github.com/ansible/ansible-examples>`_ 中有很多实例，如果你希望深入学习可以在单独的页面打开它。


Task Include Files And Encouraging Reuse
````````````````````````````````````````

假如你希望在多个 play 或者多个 playbook 中重用同一个 task 列表，你可以使用 include files 做到这一点。
当我们希望为系统定义一个角色时，使用 include 去包含 task 列表是一种很好用的方法。需要记住的是，一个 play 所要达成
的目标是将一组系统映射为多个角色。下面我们来看看具体是如何做的：

一个 task include file 由一个普通的 task 列表所组成，像这样::

    ---
    # possibly saved as tasks/foo.yml

    - name: placeholder foo
      command: /bin/foo

    - name: placeholder bar
      command: /bin/bar

Include 指令看起来像下面这样，在一个 playbook 中，Include 指令可以跟普通的 task 混合在一起使用::

   tasks:

     - include: tasks/foo.yml

你也可以给 include 传递变量。我们称之为 '参数化的 include'。

举个例子，如果我们要部署多个 wordpress 实例，我们可将所有的 wordpress task 写在一个 wordpress.yml 文件中，
然后像下面这样使用 wordpress.yml 文件::

   tasks:
     - include: wordpress.yml wp_user=timmy
     - include: wordpress.yml wp_user=alice
     - include: wordpress.yml wp_user=bob

如果你运行的是 Ansible 1.4 及以后的版本，include 语法可更为精简，这种写法同样允许传递列表和字典参数::

    tasks:
     - { include: wordpress.yml, wp_user: timmy, ssh_keys: [ 'keys/one.txt', 'keys/two.txt' ] }

使用上述任意一种语法格式传递变量给 include files 之后，这些变量就可以在 include 包含的文件中使用了。
关于变量的详细使用方法请查看 :doc:`playbooks_variables` 。变量可以这样去引用:: 

   {{ wp_user }}

(除了显式传递的参数，所有在 vars section 中定义的变量也可在这里使用)

从 1.0 版开始，Ansible 支持另一种传递变量到 include files 的语法，这种语法支持结构化的变量::

    tasks:

      - include: wordpress.yml
        vars:
            wp_user: timmy
            some_list_variable:
              - alpha
              - beta
              - gamma

在 Playbooks 中可使用 include 包含其他 playbook，我们将在稍后的章节介绍这个用法。

.. note::
	从 1.0 版开始，task include 语句可以在任意层次使用。在这之前，include 语句
	只能在单个层次使用，所以在之前版本中由 include 所包含的文件，其中不能再有 include 
	包含出现。

Include 语句也可以用在 'handlers' section 中，比如，你希望定义一个重启 apache 的 handler，
你只需要定义一次，然后便可在所有的 playbook 中使用这个 handler。你可以创建一个 handlers.yml
文件如下::

   ---
   # this might be in a file like handlers/handlers.yml
   - name: restart apache
     service: name=apache state=restarted

然后在你的主 playbook 文件中，在一个 play 的最后使用 include 包含 handlers.yml::

   handlers:
     - include: handlers/handlers.yml

Include 语句可以和其他非 include 的 tasks 和 handlers 混合使用。

Include 语句也可用来将一个 playbook 文件导入另一个 playbook 文件。这种方式允许你定义一个
顶层的 playbook，这个顶层 playbook 由其他 playbook 所组成。

举个例子::

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

注意：当你在 playbook 中引用其他 playbook 时，不能使用变量替换。

.. note::
   You can not conditionally path the location to an include file,
   like you can with 'vars_files'.  If you find yourself needing to do
   this, consider how you can restructure your playbook to be more
   class/role oriented.  This is to say you cannot use a 'fact' to
   decide what include file to use.  All hosts contained within the
   play are going to get the same tasks.  ('*when*' provides some
   ability for hosts to conditionally skip tasks).

.. _roles:

Roles
`````

.. versionadded:: 1.2

你现在已经学过 tasks 和 handlers，那怎样组织 playbook 才是最好的方式呢？简单的回答就是：使用 roles ! 
Roles 基于一个已知的文件结构，去自动的加载某些 vars_files，tasks 以及 handlers。基于 roles 对内容进行分组，使得我们可以容易地与其他用户分享 roles 。

一个项目的结构如下::

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

一个 playbook 如下::

    ---
    - hosts: webservers
      roles:
         - common
         - webservers

这个 playbook 为一个角色 'x' 指定了如下的行为：

- 如果 roles/x/tasks/main.yml 存在, 其中列出的 tasks 将被添加到 play 中
- 如果 roles/x/handlers/main.yml 存在, 其中列出的 handlers 将被添加到 play 中
- 如果 roles/x/vars/main.yml 存在, 其中列出的 variables 将被添加到 play 中
- 如果 roles/x/meta/main.yml 存在, 其中列出的 "角色依赖" 将被添加到 roles 列表中 (1.3 and later)
- 所有 copy tasks 可以引用 roles/x/files/ 中的文件，不需要指明文件的路径。
- 所有 script tasks 可以引用 roles/x/files/ 中的脚本，不需要指明文件的路径。
- 所有 template tasks 可以引用 roles/x/templates/ 中的文件，不需要指明文件的路径。
- 所有 include tasks 可以引用 roles/x/tasks/ 中的文件，不需要指明文件的路径。

在 Ansible 1.4 及之后版本，你可以为"角色"的搜索设定 roles_path 配置项。使用这个配置项将所有的 common 角色 check out 到一个位置，以便在多个 playbook 项目中可方便的共享使用它们。查看 :doc:`intro_configuration` 详细了解设置这个配置项的细节，该配置项是在 ansible.cfg 中配置。

.. note::
   稍后将讨论"角色依赖"的概念。

如果 roles 目录下有文件不存在，这些文件将被忽略。比如 roles 目录下面缺少了 'vars/' 目录，这也没关系。

注意：你仍然可以在 playbook 中松散地列出 tasks，vars_files 以及 handlers，这种方式仍然可用，但 roles 是一种很好的具有组织性的功能特性，我们强烈建议使用它。如果你在 playbook 中同时使用 roles 和 tasks，vars_files 或者 handlers，roles 将优先执行。

而且，如果你愿意，也可以使用参数化的 roles，这种方式通过添加变量来实现，比如::

    ---

    - hosts: webservers
      roles:
        - common
        - { role: foo_app_instance, dir: '/opt/a',  port: 5000 }
        - { role: foo_app_instance, dir: '/opt/b',  port: 5001 }

当一些事情不需要频繁去做时，你也可以为 roles 设置触发条件，像这样::

    ---

    - hosts: webservers
      roles:
        - { role: some_role, when: "ansible_os_family == 'RedHat'" }

它的工作方式是：将条件子句应用到 role 中的每一个 task 上。关于"条件子句"的讨论参见本文档后面的章节。

最后，你可能希望给 roles 分配指定的 tags。比如::

    ---

    - hosts: webservers
      roles:
        - { role: foo, tags: ["bar", "baz"] }

如果 play 仍然包含有 'tasks' section，这些 tasks 将在所有 roles 应用完成之后才被执行。

如果你希望定义一些 tasks，让它们在 roles 之前以及之后执行，你可以这样做::

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
	如果对 tasks 应用了 tags（tags 是一种实现部分运行 playbook 的机制，将在后面的章节讨论），需确保给 pre_tasks 以及 post_tasks 也同样应用 tags，并且将它们一并传递。特别是当 pre_tasks 和 post_tasks 被用来监视 "停止窗口控制" 或者 "负载均衡" 时要确保这样做。


角色默认变量(Role Default Variables)
````````````````````````````````````

.. versionadded:: 1.3

角色默认变量允许你为 included roles 或者 dependent roles(见下) 设置默认变量。要创建默认变量，只需在 roles 目录下添加 `defaults/main.yml` 文件。这些变量在所有可用变量中拥有最低优先级，可能被其他地方定义的变量(包括 inventory 中的变量)所覆盖。


角色依赖(Role Dependencies)
``````````````````````````

.. versionadded:: 1.3

"角色依赖" 使你可以自动地将其他 roles 拉取到现在使用的 role 中。"角色依赖" 保存在 roles 目录下的 `meta/main.yml` 文件中。这个文件应包含一列 roles 和 为之指定的参数，下面是在 `roles/myapp/meta/main.yml` 文件中的示例::

    ---
    dependencies:
      - { role: common, some_parameter: 3 }
      - { role: apache, port: 80 }
      - { role: postgres, dbname: blarg, other_parameter: 12 }

"角色依赖" 可以通过绝对路径指定，如同顶级角色的设置::

    ---
    dependencies:
       - { role: '/path/to/common/roles/foo', x: 1 }

"角色依赖" 也可以通过源码控制仓库或者 tar 文件指定，使用逗号分隔：路径、一个可选的版本（tag, commit, branch 等等）、一个可选友好角色名（尝试从源码仓库名或者归档文件名中派生出角色名）::

    ---
    dependencies:
      - { role: 'git+http://git.example.com/repos/role-foo,v1.1,foo' }
      - { role: '/path/to/tar/file.tgz,,friendly-name' }

"角色依赖" 总是在 role （包含"角色依赖"的role）之前执行，并且是递归地执行。默认情况下，作为 "角色依赖" 被添加的 role 只能被添加一次，如果另一个 role 将一个相同的角色列为 "角色依赖" 的对象，它不会被重复执行。但这种默认的行为可被修改，通过添加 `allow_duplicates: yes` 到  `meta/main.yml` 文件中。
比如，一个 role 名为 'car'，它可以添加名为 'wheel' 的 role 到它的 "角色依赖" 中::

    ---
    dependencies:
    - { role: wheel, n: 1 }
    - { role: wheel, n: 2 }
    - { role: wheel, n: 3 }
    - { role: wheel, n: 4 }

wheel 角色的 `meta/main.yml` 文件包含如下内容::

    ---
    allow_duplicates: yes
    dependencies:
    - { role: tire }
    - { role: brake }

最终的执行顺序是这样的::

    tire(n=1)
    brake(n=1)
    wheel(n=1)
    tire(n=2)
    brake(n=2)
    wheel(n=2)
    ...
    car

.. note::
	关于变量继承和范围的详细讨论，请查看 :doc:`playbooks_variables`。

在 Roles 中嵌入模块
``````````````````````````

这是一个高级话题，应该只有少数的 Ansible 用户关心这一话题。

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

`Ansible Galaxy <http://galaxy.ansible.com>`_ 是一个自由网站，网站提供所有类型的由社区开发的 roles，这对于实现你的自动化项目是一个很好的参考。网站提供这些 roles 的排名、查找以及下载。

Ansible 1.4.2 及以后的版本已包含 Ansible Galaxy 的下载客户端 'ansible-galaxy'。

阅读 Galaxy 站点的 "About" 页面获取更多信息。

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

