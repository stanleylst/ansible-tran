测试策略
==================

.. _testing_intro:

Ansible Playbooks 的集成测试
``````````````````````````````````````````

很多时候, 人们问, "我怎样才能最好的将 Ansible playbooks 和测试结合在一起?" 这有很多选择. Ansible 的设计实际上是一个"fail-fast"有序系统, 因此它可以很容易地嵌入到 Ansible playbooks. 在这一章节, 我们将讨论基础设施的集成测试及合适的测试等级.

.. note:: 这是一个关于测试你部署应用程序的章节, 不是如何测试开发的 Ansible 模块. 对于那些内容, 请移步开发区域.

通过将某种程度的测试部署合并到部署工作流中, 当代码运行在生产环境中这将减少意外的产生, 在许多情况下, 测试可以避免在生产中因为更新失败而导致的迁移整个安装. 因为它是基于推送的, 它可以很容易的运行在 localhost 或者测试服务器上. Ansible 允许你添加尽可能多的检查在你的升级流程中.

正确的测试等级
``````````````````````````

Ansible 资源是期望状态的模块. 因此测试服务是否处于运行, 包是否已经安装, 或其他这样的事情它不是必要的. Ansible 确保这些系统中的这些声明是真实的. 相反, 在你的 playbooks 中 assert 这些事情.

.. code-block:: yaml

   tasks:
     - service: name=foo state=started enabled=yes

如果你认为该服务可能没有启动, 最好的事情就是要求它处于启动状态. 如果这个服务启动失败, Ansible 将适当的抛出. (这不应该和服务是否正在做一些功能性的事情混淆, 而我们应该更多的展示如何做这些事).

Check 模块作为主要测试
``````````````````````````

在上面的设置中, `--check` 模块在 Ansible 中可以作为一层测试. 如果在一个现有的系统部署 playbook, 使用 `--check` 选项 `ansible` 命令将会报告出 Ansible 使系统进入一个期望状态所做的任何更改. 

这可以让你知道前面任何需要不如到给定系统的信息. 一般的脚本和命令不运行在检查模式, 所以如果你想要某些步骤总是在检查模式下执行, 例如调用 script 模块, 添加 'always_run' 标记::


   roles:
     - webserver

   tasks:
     - script: verify.sh
       always_run: True

用于测试的模块
```````````````````````````````````

某些 playbook 模块对于测试特别友好. 下面的例子保证端口处于打开状态::

   tasks:

     - wait_for: host={{ inventory_hostname }} port=22
       delegate_to: localhost
      
这是使用 URI 模块来确保 web service 有正确的返回::

   tasks:

     - action: uri url=http://www.example.com return_content=yes
       register: webpage

     - fail: msg='service is not happy'
       when: "'AWESOME' not in webpage.content"

可以很容易的将任意(语言)的脚本推送到远程主机上, 如果这个脚本有一个非零的返回码, 它将自动失效::

   tasks:

     - script: test_script1
     - script: test_script2 --parameter value --parameter2 value

如果使用 roles(你应该这样做, roles 是伟大的!), 脚本模块可以推送 role 下的 'files/' 目录下的脚本

添加 assert 模块, 它可以很容易的验证各种真理::

   tasks:

      - shell: /usr/bin/some-command --parameter value
        register: cmd_result

      - assert:
          that:
            - "'not ready' not in cmd_result.stderr"
            - "'gizmo enabled' in cmd_result.stdout"

如果你觉得需要测试通过 Ansible 设置的文件是否存在, 'stat' 模块是一个不错的选择::

   tasks:

      - stat: path=/path/to/something
        register: p

      - assert:
          that:
            - p.stat.exists and p.stat.isdir


如上所处, 哪些没必要检查的东西如命令的返回码. Ansible 自动检查它们.
如果检查用户存在, 考虑使用 user 模块使其存在.

Ansible 是一个 fail-fast 系统, 所以当创建用户失败, 它将停止 playbook 的运行. 你不必检查它背后的原因.

测试的生命周期
`````````````````

如果将你的应用程序的基本验证写入了你的 playbooks 中, 在你每次部署的适合他们都将运行.

因此部署到本地开发的虚拟机和临时的环境都将根据你的生产环境的部署计划来验证这一切.

你的工作流可能是这样::

    - 使用相同的 playbook 在开发过程中嵌入测试
    - 使用 playbook 部署一个临时环境(使用相同的playbooks)来模拟生产
    - 运行一个由 QA 团建编写的集成测试用例
    - 使用相同的总和测试部署到生产.

如果你是一个产品服务, 一些像集成测试系列需要通过你的 QA 团队来编写. 这将包含诸如测试用例或自动化 API 测试, 这些通常不是嵌入到 Ansible 的 playbooks 中的.

然而, 它包含基本的健康的检查使 playbooks 有意义, 而且在某些情况下它可能会相对于远程节点运行一些 QA 的子集合. 这是下一节所涵盖的内容.

结合滚动更新测试
````````````````````````````````````````

如果你已经读到 :doc:`playbooks_delegation` 滚动更新的扩展好处可以迅速变得明显, 你可以使用 playbook 运行的成功或失败来决定是否增加机器到负载均衡器中. 

这是嵌入测试的显著结果::

    ---

    - hosts: webservers
      serial: 5

      pre_tasks:

        - name: take out of load balancer pool
          command: /usr/bin/take_out_of_pool {{ inventory_hostname }}
          delegate_to: 127.0.0.1

      roles:

         - common
         - webserver
         - apply_testing_checks

      post_tasks:
  
        - name: add back to load balancer pool
          command: /usr/bin/add_back_to_pool {{ inventory_hostname }}
          delegate_to: 127.0.0.1

在上述过程中, "task out of the pool" 和 "add back" 的步骤将会代替 Ansible 调用负载均衡模块或对应的 shell 命令. 您还可以使用监控模块对机器进行创建和关闭中断的窗口.

然而, 你可以从上面看出测试作为入口 -- 如果"apply_testing_checks"这一步不执行, 这个机器将不会被添加到池中.

阅读关于"max_fail_percentage"的代表章节, 你可以控制有多少失败的测试后停止程序的滚动更新.

这种方式也可以被修改为先在测试机器上执行测试步骤然后在远程机器执行测试的步骤::

    ---

    - hosts: webservers
      serial: 5

      pre_tasks:

        - name: take out of load balancer pool
          command: /usr/bin/take_out_of_pool {{ inventory_hostname }}
          delegate_to: 127.0.0.1

      roles:

         - common
         - webserver

      tasks:
         - script: /srv/qa_team/app_testing_script.sh --server {{ inventory_hostname }}
           delegate_to: testing_server

      post_tasks:

        - name: add back to load balancer pool
          command: /usr/bin/add_back_to_pool {{ inventory_hostname }}
          delegate_to: 127.0.0.1

在上面的例子中, 从测试服务器上执行一个脚本紧接着将一个远程的节点添加到 pool 中.

在出现问题时, 解决一些服务器不能使用 Ansible 自动生成的重试文件重复部署这些服务器.


实现连续部署
```````````````````````````````

如果需要, 上述技术可以扩展到启用连续部署中.

这个工作流可能像这样::

    - 编写和使用自动部署本地开发虚拟机
    - 有一个 CI 系统像 Jenkins, 来将每一次的代码变更部署到临时环境中
    - 这个部署任务调用测试脚本, 参考通过/失败来确定每一次的部署是否进行 build
    - 如果部署任务成功, 它将在生产环境中运行相同的部署 playbook

一些 Ansible 用户使用上述方式, 在一个小时内多次部署使它们所有的基础设施不下线. 如果你想达到那种水平, 一个自动 QA 系统是至关重要的.

如果你仍然在大量使用人工 QA, 你仍然需要决定手动部署是否是最好的, 但它仍然可以帮助滚动更新前的一部分工作, 包括基本的健康检查使用模块 'script', 'stat', 'uri', 和 'assert'.

结尾
``````````

Ansible 相信你应该不需要另一个框架来验证你的基础设施是正确的. 这种情况是因为 Ansible 是基于顺序的系统, 处理失败后将立即在主机上引发错误, 并阻止该主机进一步的配置. 这迫使 Ansible 在运行结束后将错误作为摘要显示在顶端.

然而, Ansible 作为一个多层编排系统, 它可以很轻松的将测试合并到 playbook 中运行完毕, 使用 tasks 或 roles. 当使用滚动更新时, 测试步骤可以决定是否要把一台服务器添加到负载均衡池中.

最后, 因为 Ansible 错误会通过所有的方式进行传播以及 Ansible 程序本身的返回码, Ansible 默认运行在一个简单的推送模式, 如果你想使用它作为部署系统, 持续集成/持续交付道路上的组成部分, Ansible 是作为构建环境的最好的阶段, 如上面部分的介绍.

重点不应该放在基础设施测试上, 而是在应用程序的测试, 所以我们强烈鼓励你和你的 QA 团队商量出对于每一次部署的开发虚拟机什么样的测试是有意义的, 并将他们希望对每个部署的临时环境的测试进行排序. Ansible 描述了资源应该所处的状态, 所以你不需要考虑这些. 如果存在你需要确定的东西, 使用 stat/assert 这些伟大的模块来实现你的目的, 这将是最棒的.

总之, 测试是一个组织非常明确的事情. 每一个人都应该这样做, 但是这些要根据你要部署什么以及谁在使用它们来确定最适合的方案 -- 但每个人肯定都会从一个更加强大和可靠的部署系统中受益.

.. seealso::

   :doc:`modules`
       All the documentation for Ansible modules
   :doc:`playbooks`
       An introduction to playbooks
   :doc:`playbooks_delegation`
       Delegation, useful for working with loud balancers, clouds, and locally executed steps.
   `User Mailing List <http://groups.google.com/group/ansible-project>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

