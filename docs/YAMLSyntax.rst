YAML 语法
===========

这个页面提供一个正确的 YAML 语法的基本概述, 它被用来描述一个 playbooks(我们的配置管理语言).

我们使用 YAML 是因为它像 XML 或 JSON 是一种利于人们读写的数据格式. 此外在大多数变成语言中有使用 YAML 的库.

你可能希望读 :doc:`playbooks` 实践中如何使用的.


基本的 YAML
-----------

对于 Ansible, 每一个 YAML 文件都是从一个列表开始. 列表中的每一项都是一个键值对, 通常它们被称为一个 "哈希" 或 "字典". 所以, 我们需要知道如何在 YAML 中编写列表和字典.

YAML 还有一个小的怪癖. 所有的 YAML 文件(无论和 Ansible 有没有关系)开始行都应该是 ``---``.  这是 YAML 格式的一部分, 表明一个文件的开始.

列表中的所有成员都开始于相同的缩进级别, 并且使用一个 ``"- "`` 作为开头(一个横杠和一个空格)::

    ---
    # 一个美味水果的列表
    - Apple
    - Orange
    - Strawberry
    - Mango

一个字典是由一个简单的 ``键: 值`` 的形式组成(这个冒号后面必须是一个空格)::

    ---
    # 一位职工的记录
    name: Example Developer
    job: Developer
    skill: Elite

字典也可以使用缩进形式来表示, 如果你喜欢这样的话::

    ---
    # 一位职工的记录
    {name: Example Developer, job: Developer, skill: Elite}

.. _truthiness:

Ansible并不是太多的使用这种格式, 但是你可以通过以下格式来指定一个布尔值(true/fase)::

    ---
    create_key: yes
    needs_agent: no
    knows_oop: True
    likes_emacs: TRUE
    uses_cvs: false

让我们把目前所学到的 YAML 例子组合在一起. 这些在 Ansible 中什么也干不了, 但这些格式将会给你感觉::

    ---
    # 一位职工记录
    name: Example Developer
    job: Developer
    skill: Elite
    employed: True
    foods:
        - Apple
        - Orange
        - Strawberry
        - Mango
    languages:
        ruby: Elite
        python: Elite
        dotnet: Lame

这就是你开始编写 `Ansible` playbooks 所需要知道的所有 YAML 语法.

Gotchas
-------

尽管 YAML 通常是友好的, 但是下面将会导致一个 YAML 语法错误::

    foo: somebody said I should put a colon here: so I did

你需要使用引号来包裹任何包含冒号的哈希值, 像这样::

    foo: "somebody said I should put a colon here: so I did"

然后这个冒号将会被结尾.

此外, Ansible 使用 "{{ var }}" 来引用变量. 如果一个值以 "{" 开头, YAML 将认为它是一个字典, 所以我们必须引用它, 像这样::

    foo: "{{ variable }}"


.. seealso::

   :doc:`playbooks`
       Learn what playbooks can do and how to write/run them.
   `YAMLLint <http://yamllint.com/>`_
       YAML Lint (online) helps you debug YAML syntax if you are having problems
   `Github examples directory <https://github.com/ansible/ansible-examples>`_
       Complete playbook files from the github project source
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

