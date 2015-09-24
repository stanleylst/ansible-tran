核心模块
------------

这些模块是 ansible 团队维护的核心模块,同样也是 ansible 自带的模块,在收到的的请求中,它们有比 "extras" 源更高的优先级

核心模块的源码托管在 Github 的 `ansible-modules-core <http://github.com/ansible/ansible-modules-core>`_ repo.

如果你确信你在核心模块上发现了一个 bug ,同时你使用的是最新的稳定版或者开发版本的 Ansible ,首先你需要看看  github.com/ansible/ansible-modules-core 上的 "issue tracker" ,确保你的 bug 还没有被提交.如果还没被提交, 非常感谢你的提交

你肯能更想去问问题,而不是提交 bug ,欢迎在 Ansible-project 的 google-group 里咨询 https://groups.google.com/forum/#!forum/ansible-project ,在 Ansible 的 #ansible_chanel 咨询也是可以的,它们位于 irc.freenode.net .开发方向的应该用类似的讨论组,位于 <https://groups.google.com/forum/#!forum/ansible-devel>`_

这些模块的文档更新可以直接编辑在模块自身里面,然后提交一个 pull 请求到源码,不过你需要找到源码树的 "DOCUMENTATION" 块
