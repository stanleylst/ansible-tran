额外模块
--------------

这些模块是当前ansible附带的,但是也可能在以后被分开.额外模块主要被社区人员维护.非核心模块仍然是完全可用的,但是在发出和拉取请求时可能收到稍微低的响应速率 

受欢迎的的 “extras” 模块将来可能会提升为核心模块

这些额外的模块托管在Github上的,`ansible-modules-extras <http://github.com/ansible/ansible-modules-extras>`_ repo.

如果你确信你在额外模块上发现了一个 bug ,同时你使用的是最新的稳定版或者开发版本的 Ansible ,首先你需要看看  github.com/ansible/ansible-modules-extras 上的 "issue tracker" ,确保你的 bug 还没有被提交.如果还没被提交, 非常感谢你的提交

你肯能更想去问问题,而不是提交 bug ,欢迎在 Ansible-project 的 google-group 里咨询 https://groups.google.com/forum/#!forum/ansible-project ,在 Ansible 的 #ansible_chanel 咨询也是可以的,它们位于 irc.freenode.net .开发方向的应该用类似的讨论组,位于 <https://groups.google.com/forum/#!forum/ansible-devel>`_

这些模块的文档更新可以直接编辑在模块自身里面,然后提交一个 pull 请求到源码,不过你需要找到源码树的 "DOCUMENTATION" 块

获取开发模块的更多们帮助,请阅读,:doc:`community`, :doc:`developing_test_pr` and :doc:`developing_modules`.

