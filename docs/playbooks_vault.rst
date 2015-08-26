Vault
=====

.. contents:: Topics

Ansible 1.5的新版本中, "Vault" 作为 ansible 的一项新功能可将例如passwords,keys等敏感数据文件进行加密,而非存放在明文的 playbooks 或 roles 中. 这些 vault 文件可以分散存放也可以集中存放.

通过`ansible-vault` 来编辑文件,经常用到的命令如 `--ask-vault-pass` , `--vault-password-file` . 这里,你可以在 ansible.cfg 中定义密码文件所在位置,这个选项就不需要在命令行中指定标志了.

.. _what_can_be_encrypted_with_vault:

Vault可以加密些什么
````````````````````````````

vault 可以加密任何 Ansible 使用的结构化数据文件. 甚至可以包括 "group_vars/" 或 "host_vars/" inventory 变量, "include_vars" 或 "vars_files" 加载的变量, 通过 ansible-playbook 命令行使用 "-e @file.yml" 或 "-e @file.json" 命令传输的变量文件. Role 变量和所有默认的变量都可以被 vault 加密.

因为 Ansible tasks, handlers等都是数据文件, 所有的这些均可以被 vault 加密. 如果你不喜欢你使用的变量被泄漏,你可以将整个 task 文件部分加密. 然后,这个工作量比较大而且可能给你的同事带来不便哦 :)

.. _creating_files:

创建加密文件
````````````````````````

执行如下命令,创建加密文件::

   ansible-vault create foo.yml

首先你将被提示输出密码, 经过Vault加密过的文件如需查看需同时输入密码后才能进行.

提供密码后, 工具将加载你定义的 $EDITOR 的编辑工具默认是 vim, 一旦你关闭了编辑会话框,生成后的文件将会是加密文件.

默认加密方式是 AES (基于共享密钥)

.. _editing_encrypted_files:

Editing加密文件
```````````````````````

编辑加密文件,使用 `ansible-vault edit` . 该命令会先加密文件为临时文件并允许你编辑这个文件,当完成编辑后会保存回你所命名的文件并删除临时文件::

   ansible-vault edit foo.yml

.. _rekeying_files:

密钥更新加密文件
````````````````````````

如果你希望变更密码,使用如下 命令::

    ansible-vault rekey foo.yml bar.yml baz.yml

如上命令可以同时批量修改多个文件的组织密码并重新设置新密码.

.. _encrypting_files:

加密普通文件
````````````````````````````

如果你希望加密一个已经存在的文件,使用 `ansible-vault encrypt` . 该命令也可同时批量操作多个文件::
 
   ansible-vault encrypt foo.yml bar.yml baz.yml

.. _decrypting_files:

解密已加密文件
``````````````````````````

如果不希望继续加密一个已经加密过的文件,通过 `ansible-vault decrypt`  你可以永久解密. 命令将解密并保存到硬盘上,这样你不用再使用 `ansible-vault edit` 来编辑文件了::

    ansible-vault decrypt foo.yml bar.yml baz.yml

.. _viewing_files:

查阅已加密文件
```````````````````````

*Available since Ansible 1.8*

如果你不希望通过编辑的方式来查看文件, `ansible-vault view`  可以满足你的需要::

    ansible-vault view foo.yml bar.yml baz.yml

.. _running_a_playbook_with_vault:

在Vault下运行Playbook
`````````````````````````````

执行 vault 加密后的playbook文件,最少需要提交如下两个标志之一. 交互式的指定 vault 的密码文件::

    ansible-playbook site.yml --ask-vault-pass

该提示被用来解密(仅在内存中)任何 vault 加密访问过的文件. 目前这些文件中所有的指令请求将被使用相同的密码加密.

另外,密码也可以定义在一个文件或者一个脚本中,但是需要 Ansible 1.7 以上的版本才能支持. 当使用该功能时,一定要确认密码文件的权限是安全的以确保没有人可以随意访问或者变更密码文件::

    ansible-playbook site.yml --vault-password-file ~/.vault_pass.txt

    ansible-playbook site.yml --vault-password-file ~/.vault_pass.py

密码存储一行一个

如果你使用的是脚本而不是普通文件,确保脚本是可执行的,这样密码可以输出至标准设备.如果你的脚本需要提示输入数据,那提示可以被发送到标准错误.

如果你是从持续集成系统(例如Jenkins)中使用 Ansible 的话上面的这种情况你会用的到.

(`--vault-password-file` 参数可以在 :ref:`ansible-pull` 命令中被使用,尽管这将需要分发keys到对应的节点上,所以 这些了解这些隐性问题后 --  vault 更倾向使用 push 方式)




