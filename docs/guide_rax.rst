Rackspace 云指南
=====================

.. _introduction:

介绍
````````````

.. 注意:: 这部分文档仍在建设中. 我们在添加更多关于 Rackspace 模块更多例子的同时讲述他们是如何在一起工作的. 一旦完成, 他们将会被添加到 Rackspace Cloud 实例中 `ansible-examples <https://github.com/ansible/ansible-examples/>`_.

Ansible 包含一些与 Rackspace Cloud 交互的核心模块.

本节的目的是说明在 Rackspace Cloud 的环境下如何使用 Ansible 模块(和使用 inventory scripts).

使用其他模块的先决条件是最少的. 除 Ansible 之外, 所有的模块依赖 pyrax 1.5 或更高版本. 你需要将这个 Python 模块安装在执行主机上.

pyrax 在一些操作系统的包仓库中是不存在的, 所以你可能需要通过 pip 安装:

.. code-block:: bash

    $ pip install pyrax

下面的步骤将会一直从控制机器通过 Rackspace Cloud API 执行, 所以将 localhost 添加到 inventory 文件中是有意义的. (在未来 Ansible 可能不在依赖这一步):

.. code-block:: ini

    [localhost]
    localhost ansible_connection=local

在 playbook 中, 我们将会使用下面典型的模式:

.. code-block:: yaml

    - hosts: localhost
      connection: local
      gather_facts: False
      tasks:

.. _credentials_file:

凭证文件
````````````````

这个 `rax.py` inventory 脚本和所有 `rax` 模块均支持一种标准的 `pyrax` 凭证文件, 它看起来像这样:

.. code-block:: ini

    [rackspace_cloud]
    username = myraxusername
    api_key = d41d8cd98f00b204e9800998ecf8427e

设置环境变量 RAX_CREDS_FILE 到凭证文件的路径, 这将帮助 Ansible 找到它并加载这些信息.

更多关于凭证文件的信息可以参考这里
https://github.com/rackspace/pyrax/blob/master/docs/getting_started.md#authenticating


.. _virtual_environment:

在 Python 的虚拟环境中运行(可选)
++++++++++++++++++++++++++++++++++++++++++++++++++++

大多数用户不喜欢使用虚拟环境, 但是有些用户喜欢, 特别是一些 Python 开发者.

当 Ansible 被安装到 Python 的虚拟环境时, 相比较默认安装到全局环境中, 需要有一些特殊考虑. Ansible 假定, 除非有其他明确的指定, python 二进制可执行文件为 /usr/bin/python. 这是通过模块中解释器一行确定的, 然而可以使用 inventory 变量 'ansible_python_interpreter' 来重新指定, Ansible 将使用指定的路径去寻找 Python. 使用 Python 虚拟环境解析器, 这可能是模块在 'localhost' 运行或者通过 'local_action' 来运行的原因. 通过设置 inventory, 模块将会在虚拟环境中执行并且拥有单独的虚拟包, 特别是 pyrax. 如果使用虚拟环境, 你可能需要修改你本地 inventory 来定义这个虚拟位置, 像下面一样:

.. code-block:: ini

    [localhost]
    localhost ansible_connection=local ansible_python_interpreter=/path/to/ansible_venv/bin/python

.. 注意::

    pyrax 可以被安装到全局的 Python 包作用域下或在一个虚拟的环境中. 这里没有特殊的考虑, 只需要记住安装 pyrax.

.. _provisioning:

配置
````````````

现在到了有趣的部分.

这个 'rax' 模块在 Rackspace Cloud 中具有提供 instances 的能力. 典型的配置任务将通过你的 Ansible 控制服务器(在我们的例子中, localhost)请求 Rackspace cloud API. 这是因为这几个原因:

    - 避免 pyrax 库安装在远程节点
    - 无需加密和分发凭证到远程节点
    - 快且简单

.. 注意::

   与 Rackspace-related 相关的认证模块是通过指定你的用户名和 API key 到环境变量或者将他们以参数的方式传递给模块, 或者通过指定凭证文件的路径.

下面是一个在 ad-hoc 模式下配置 instance 的简单实例:

.. code-block:: bash

    $ ansible localhost -m rax -a "name=awx flavor=4 image=ubuntu-1204-lts-precise-pangolin wait=yes" -c local

这些内容转换成 playbook 像下面一样, 假设参数定义在变量中:

.. code-block:: yaml

    tasks:
      - name: Provision a set of instances
        local_action:
            module: rax
            name: "{{ rax_name }}"
            flavor: "{{ rax_flavor }}"
            image: "{{ rax_image }}"
            count: "{{ rax_count }}"
            group: "{{ group }}"
            wait: yes
        register: rax

rax 模块返回节点创建 instance 的数据, 像 IP 地址, 主机名, 和登陆密码. 通过注册返回值的步骤, 可以使用它动态添加到主机的 inventory 中(临时在内存中). 这有利于在新建的 instance 上进行配置操作. 在下面的示例中, 将会使用上面成功创建的服务器的信息, 通过每个节点的主机名, IP 地址, 和 root 密码动态添加到一个名为 raxhosts 组中.

.. code-block:: yaml

    - name: Add the instances we created (by public IP) to the group 'raxhosts'
      local_action:
          module: add_host 
          hostname: "{{ item.name }}"
          ansible_ssh_host: "{{ item.rax_accessipv4 }}"
          ansible_ssh_pass: "{{ item.rax_adminpass }}"
          groups: raxhosts
      with_items: rax.success
      when: rax.action == 'create'

现在使用已经创建的主机组, 接下来将会使用下面的 playbook 配置 raxhosts 组中的服务器

.. code-block:: yaml

    - name: Configuration play
      hosts: raxhosts
      user: root
      roles:
        - ntp
        - webserver

上面的方法将提供的主机配置在一起. 这并不总是你想要了, 那么让我们进入下一章节.

.. _host_inventory:

主机 Inventory
``````````````

一旦你的节点被创建启动, 你很可能会多次和他们进行通讯. 最好的方法是通过 "rax" inventory 插件, 动态查询 Rackspace Cloud 告诉 Ansible 哪些节点需要被管理. 你可能会使用 Ansible 启动的这些 event 来管理其他的工具, 包含 Rackspace 云用户接口. 这个 inventory 插件可以通过元数据, 区域, OS, 配置等来进行分组. 在 "rax" 中高度推荐使用元数据, 它可以很容易的在主机组和 roles 之间排序. 如果你不想使用 "rax.py" 这个动态 inventory 脚本, 你仍然可以选择手动管理你的 INI inventory 文件, 尽管这是不被推荐的.

Ansible 可以使用多个动态 inventory 插件和 INI 数据文件. 仅仅需要将他们放在一个目录下, 并确保脚本添加了执行权限, INI 文件则不需要.

.. _raxpy:

rax.py
++++++

使用 rackspace 动态 inventory 脚本, 复制 ``rax.py`` 到你的 inventory 目录下并且赋予执行权限. 你可以为 ``rax.py`` 指定一个凭证文件利用 ``RAX_CREDS_FILE`` 环境变量.

.. 注意:: 如果 Ansible 已经被安装在全局中, 动态 inventory 脚本(例如 ``rax.py``) 将被保存在 ``/usr/share/ansible/inventory``. 如果被安装到虚拟环境中, 这个 inventory 脚本将会被安装到 ``$VIRTUALENV/share/inventory``.

.. 注意:: :doc:`tower`用户需要注意这个动态的 inventory 已经被 Tower 内部支持, 所以你所要做的就是提供你的 Rackspace Cloud 凭证, 它将很快的执行这些步骤::

    $ RAX_CREDS_FILE=~/.raxpub ansible all -i rax.py -m setup

``rax.py`` 也接收 ``RAX_REGION`` 环境变量, 其中可以包含单个区域或者用逗号隔开的区域列表.

当使用 ``rax.py``, 你将不需要在 inventory 中定义 'localhost'.

正如前面所提到的, 你将经常在主机循环之外运行这些模块, 并且需要定义 'localhost'. 这里推荐这样做, 创建一个 ``inventory`` 目录, 并且将 ``rax.py`` 和包含 ``localhost`` 的文件放在这个目录下.

执行 ``ansible`` 或 ``ansible_playbook`` 并且指定一个包含 ``inventory`` 的目录而不是一个文件, ansible 将会读取这个目录下的所有文件.

让我们测试下我们的 inventory 脚本是否可以和 Reckspace Cloud 通信.

.. code-block:: bash

    $ RAX_CREDS_FILE=~/.raxpub ansible all -i inventory/ -m setup

假设所有的属性配置都是正确的, 这个 ``rax.py`` inventory 脚本将会输入类似于下面的信息, 这些将会被用作 inventory 和变量.

.. code-block:: json

    {
        "ORD": [
            "test"
        ],
        "_meta": {
            "hostvars": {
                "test": {
                    "ansible_ssh_host": "1.1.1.1",
                    "rax_accessipv4": "1.1.1.1",
                    "rax_accessipv6": "2607:f0d0:1002:51::4",
                    "rax_addresses": {
                        "private": [
                            {
                                "addr": "2.2.2.2",
                                "version": 4
                            }
                        ],
                        "public": [
                            {
                                "addr": "1.1.1.1",
                                "version": 4
                            },
                            {
                                "addr": "2607:f0d0:1002:51::4",
                                "version": 6
                            }
                        ]
                    },
                    "rax_config_drive": "",
                    "rax_created": "2013-11-14T20:48:22Z",
                    "rax_flavor": {
                        "id": "performance1-1",
                        "links": [
                            {
                                "href": "https://ord.servers.api.rackspacecloud.com/111111/flavors/performance1-1",
                                "rel": "bookmark"
                            }
                        ]
                    },
                    "rax_hostid": "e7b6961a9bd943ee82b13816426f1563bfda6846aad84d52af45a4904660cde0",
                    "rax_human_id": "test",
                    "rax_id": "099a447b-a644-471f-87b9-a7f580eb0c2a",
                    "rax_image": {
                        "id": "b211c7bf-b5b4-4ede-a8de-a4368750c653",
                        "links": [
                            {
                                "href": "https://ord.servers.api.rackspacecloud.com/111111/images/b211c7bf-b5b4-4ede-a8de-a4368750c653",
                                "rel": "bookmark"
                            }
                        ]
                    },
                    "rax_key_name": null,
                    "rax_links": [
                        {
                            "href": "https://ord.servers.api.rackspacecloud.com/v2/111111/servers/099a447b-a644-471f-87b9-a7f580eb0c2a",
                            "rel": "self"
                        },
                        {
                            "href": "https://ord.servers.api.rackspacecloud.com/111111/servers/099a447b-a644-471f-87b9-a7f580eb0c2a",
                            "rel": "bookmark"
                        }
                    ],
                    "rax_metadata": {
                        "foo": "bar"
                    },
                    "rax_name": "test",
                    "rax_name_attr": "name",
                    "rax_networks": {
                        "private": [
                            "2.2.2.2"
                        ],
                        "public": [
                            "1.1.1.1",
                            "2607:f0d0:1002:51::4"
                        ]
                    },
                    "rax_os-dcf_diskconfig": "AUTO",
                    "rax_os-ext-sts_power_state": 1,
                    "rax_os-ext-sts_task_state": null,
                    "rax_os-ext-sts_vm_state": "active",
                    "rax_progress": 100,
                    "rax_status": "ACTIVE",
                    "rax_tenant_id": "111111",
                    "rax_updated": "2013-11-14T20:49:27Z",
                    "rax_user_id": "22222"
                }
            }
        }
    }

.. _standard_inventory:

标准的 Inventory
++++++++++++++++++

当使用标准的 ini 格式的 inventory文件(相对于 inventory 插件), 它仍然可以从 Rackspace API 检索和发现 hostvar 信息.

这可以使用像下面 inventory 格式来实现类似于 ``rax_facts`` 的功能:

.. code-block:: ini

    [test_servers]
    hostname1 rax_region=ORD
    hostname2 rax_region=ORD

.. code-block:: yaml

    - name: Gather info about servers
      hosts: test_servers
      gather_facts: False
      tasks:
        - name: Get facts about servers
          local_action:
            module: rax_facts
            credentials: ~/.raxpub
            name: "{{ inventory_hostname }}"
            region: "{{ rax_region }}"
        - name: Map some facts
          set_fact:
            ansible_ssh_host: "{{ rax_accessipv4 }}"

虽然你不需要知道它是如何工作的, 了解返回的变量这也将是有趣的.

这个 ``rax_facts`` 模块提供像下面内容的 facts, 这将匹配 ``rax.py`` inventory 脚本::

.. code-block:: json

    {
        "ansible_facts": {
            "rax_accessipv4": "1.1.1.1",
            "rax_accessipv6": "2607:f0d0:1002:51::4",
            "rax_addresses": {
                "private": [
                    {
                        "addr": "2.2.2.2",
                        "version": 4
                    }
                ],
                "public": [
                    {
                        "addr": "1.1.1.1",
                        "version": 4
                    },
                    {
                        "addr": "2607:f0d0:1002:51::4",
                        "version": 6
                    }
                ]
            },
            "rax_config_drive": "",
            "rax_created": "2013-11-14T20:48:22Z",
            "rax_flavor": {
                "id": "performance1-1",
                "links": [
                    {
                        "href": "https://ord.servers.api.rackspacecloud.com/111111/flavors/performance1-1",
                        "rel": "bookmark"
                    }
                ]
            },
            "rax_hostid": "e7b6961a9bd943ee82b13816426f1563bfda6846aad84d52af45a4904660cde0",
            "rax_human_id": "test",
            "rax_id": "099a447b-a644-471f-87b9-a7f580eb0c2a",
            "rax_image": {
                "id": "b211c7bf-b5b4-4ede-a8de-a4368750c653",
                "links": [
                    {
                        "href": "https://ord.servers.api.rackspacecloud.com/111111/images/b211c7bf-b5b4-4ede-a8de-a4368750c653",
                        "rel": "bookmark"
                    }
                ]
            },
            "rax_key_name": null,
            "rax_links": [
                {
                    "href": "https://ord.servers.api.rackspacecloud.com/v2/111111/servers/099a447b-a644-471f-87b9-a7f580eb0c2a",
                    "rel": "self"
                },
                {
                    "href": "https://ord.servers.api.rackspacecloud.com/111111/servers/099a447b-a644-471f-87b9-a7f580eb0c2a",
                    "rel": "bookmark"
                }
            ],
            "rax_metadata": {
                "foo": "bar"
            },
            "rax_name": "test",
            "rax_name_attr": "name",
            "rax_networks": {
                "private": [
                    "2.2.2.2"
                ],
                "public": [
                    "1.1.1.1",
                    "2607:f0d0:1002:51::4"
                ]
            },
            "rax_os-dcf_diskconfig": "AUTO",
            "rax_os-ext-sts_power_state": 1,
            "rax_os-ext-sts_task_state": null,
            "rax_os-ext-sts_vm_state": "active",
            "rax_progress": 100,
            "rax_status": "ACTIVE",
            "rax_tenant_id": "111111",
            "rax_updated": "2013-11-14T20:49:27Z",
            "rax_user_id": "22222"
        },
        "changed": false
    }


使用案例
`````````

本节涵盖了一些特定案例外及额外的使用案例.

.. _network_and_server:

网络和服务器
++++++++++++++++++

创建一个独立的云网络并且创建一台服务器

.. code-block:: yaml
   
    - name: Build Servers on an Isolated Network
      hosts: localhost
      connection: local
      gather_facts: False
      tasks:
        - name: Network create request
          local_action:
            module: rax_network
            credentials: ~/.raxpub
            label: my-net
            cidr: 192.168.3.0/24
            region: IAD
            state: present
            
        - name: Server create request
          local_action:
            module: rax
            credentials: ~/.raxpub
            name: web%04d.example.org
            flavor: 2
            image: ubuntu-1204-lts-precise-pangolin
            disk_config: manual
            networks:
              - public
              - my-net
            region: IAD
            state: present
            count: 5
            exact_count: yes
            group: web
            wait: yes
            wait_timeout: 360
          register: rax

.. _complete_environment:

完整的环境
++++++++++++++++++++

使用服务器建立一个完整的 web 服务环境, 自定义网络和负载均衡, 安装 nginx 并且创建自定义的 index.html

.. code-block:: yaml
   
    ---
    - name: Build environment
      hosts: localhost
      connection: local
      gather_facts: False
      tasks:
        - name: Load Balancer create request
          local_action:
            module: rax_clb
            credentials: ~/.raxpub
            name: my-lb
            port: 80
            protocol: HTTP
            algorithm: ROUND_ROBIN
            type: PUBLIC
            timeout: 30
            region: IAD
            wait: yes
            state: present
            meta:
              app: my-cool-app
          register: clb
    
        - name: Network create request
          local_action:
            module: rax_network
            credentials: ~/.raxpub
            label: my-net
            cidr: 192.168.3.0/24
            state: present
            region: IAD
          register: network
    
        - name: Server create request
          local_action:
            module: rax
            credentials: ~/.raxpub
            name: web%04d.example.org
            flavor: performance1-1
            image: ubuntu-1204-lts-precise-pangolin
            disk_config: manual
            networks:
              - public
              - private
              - my-net
            region: IAD
            state: present
            count: 5
            exact_count: yes
            group: web
            wait: yes
          register: rax
    
        - name: Add servers to web host group
          local_action:
            module: add_host
            hostname: "{{ item.name }}"
            ansible_ssh_host: "{{ item.rax_accessipv4 }}"
            ansible_ssh_pass: "{{ item.rax_adminpass }}"
            ansible_ssh_user: root
            groups: web
          with_items: rax.success
          when: rax.action == 'create'
    
        - name: Add servers to Load balancer
          local_action:
            module: rax_clb_nodes
            credentials: ~/.raxpub
            load_balancer_id: "{{ clb.balancer.id }}"
            address: "{{ item.rax_networks.private|first }}"
            port: 80
            condition: enabled
            type: primary
            wait: yes
            region: IAD
          with_items: rax.success
          when: rax.action == 'create'
    
    - name: Configure servers
      hosts: web
      handlers:
        - name: restart nginx
          service: name=nginx state=restarted
    
      tasks:
        - name: Install nginx
          apt: pkg=nginx state=latest update_cache=yes cache_valid_time=86400
          notify:
            - restart nginx
    
        - name: Ensure nginx starts on boot
          service: name=nginx state=started enabled=yes
    
        - name: Create custom index.html
          copy: content="{{ inventory_hostname }}" dest=/usr/share/nginx/www/index.html
                owner=root group=root mode=0644

.. _rackconnect_and_manged_cloud:

RackConnect 和 Managed Cloud
+++++++++++++++++++++++++++++

当使用 RackConnect version 2 或者 Rackspace Managed Cloud, Rackspace 将在成功创建的服务器上自动执行这些任务. 如果你在 RackConnect 或 Managed Cloud 自动执行之前执行了, 你可能会获得错误或者不可用的服务器.

这些例子展示了创建服务器并且确保 Rackspace 自动执行完成之前将会继续执行这些任务.

为了简单, 这些例子将会被连接起来, 但是都只需要使用 RackConnect. 当仅使用 Managed Cloud, RackConnect 将会忽略这部分.

RackConnect 部分只适用于 RackConnect 版本 2.

.. _using_a_control_machine:

使用一台控制服务器
***********************

.. code-block:: yaml

    - name: Create an exact count of servers
      hosts: localhost
      connection: local
      gather_facts: False
      tasks:
        - name: Server build requests
          local_action:
            module: rax
            credentials: ~/.raxpub
            name: web%03d.example.org
            flavor: performance1-1
            image: ubuntu-1204-lts-precise-pangolin
            disk_config: manual
            region: DFW
            state: present
            count: 1
            exact_count: yes
            group: web
            wait: yes
          register: rax
    
        - name: Add servers to in memory groups
          local_action:
            module: add_host
            hostname: "{{ item.name }}"
            ansible_ssh_host: "{{ item.rax_accessipv4 }}"
            ansible_ssh_pass: "{{ item.rax_adminpass }}"
            ansible_ssh_user: root
            rax_id: "{{ item.rax_id }}"
            groups: web,new_web
          with_items: rax.success
          when: rax.action == 'create'
    
    - name: Wait for rackconnect and managed cloud automation to complete
      hosts: new_web
      gather_facts: false
      tasks:
        - name: Wait for rackconnnect automation to complete
          local_action:
            module: rax_facts
            credentials: ~/.raxpub
            id: "{{ rax_id }}"
            region: DFW
          register: rax_facts
          until: rax_facts.ansible_facts['rax_metadata']['rackconnect_automation_status']|default('') == 'DEPLOYED'
          retries: 30
          delay: 10
    
        - name: Wait for managed cloud automation to complete
          local_action:
            module: rax_facts
            credentials: ~/.raxpub
            id: "{{ rax_id }}"
            region: DFW
          register: rax_facts
          until: rax_facts.ansible_facts['rax_metadata']['rax_service_level_automation']|default('') == 'Complete'
          retries: 30
          delay: 10
    
    - name: Base Configure Servers
      hosts: web
      roles:
        - role: users
    
        - role: openssh
          opensshd_PermitRootLogin: "no"
    
        - role: ntp

.. _using_ansible_pull:

利用 Ansible Pull
******************

.. code-block:: yaml

    ---
    - name: Ensure Rackconnect and Managed Cloud Automation is complete
      hosts: all
      connection: local
      tasks:
        - name: Check for completed bootstrap
          stat:
            path: /etc/bootstrap_complete
          register: bootstrap
    
        - name: Get region
          command: xenstore-read vm-data/provider_data/region
          register: rax_region
          when: bootstrap.stat.exists != True
    
        - name: Wait for rackconnect automation to complete
          uri:
            url: "https://{{ rax_region.stdout|trim }}.api.rackconnect.rackspace.com/v1/automation_status?format=json"
            return_content: yes
          register: automation_status
          when: bootstrap.stat.exists != True
          until: automation_status['automation_status']|default('') == 'DEPLOYED'
          retries: 30
          delay: 10
    
        - name: Wait for managed cloud automation to complete
          wait_for:
            path: /tmp/rs_managed_cloud_automation_complete
            delay: 10
          when: bootstrap.stat.exists != True
    
        - name: Set bootstrap completed
          file:
            path: /etc/bootstrap_complete
            state: touch
            owner: root
            group: root
            mode: 0400
    
    - name: Base Configure Servers
      hosts: all
      connection: local
      roles:
        - role: users
    
        - role: openssh
          opensshd_PermitRootLogin: "no"
    
        - role: ntp

.. _using_ansible_pull_with_xenstore:

利用 Ansible 拉取 XenStore
********************************

.. code-block:: yaml

    ---
    - name: Ensure Rackconnect and Managed Cloud Automation is complete
      hosts: all
      connection: local
      tasks:
        - name: Check for completed bootstrap
          stat:
            path: /etc/bootstrap_complete
          register: bootstrap

        - name: Wait for rackconnect_automation_status xenstore key to exist
          command: xenstore-exists vm-data/user-metadata/rackconnect_automation_status
          register: rcas_exists
          when: bootstrap.stat.exists != True
          failed_when: rcas_exists.rc|int > 1
          until: rcas_exists.rc|int == 0
          retries: 30
          delay: 10

        - name: Wait for rackconnect automation to complete
          command: xenstore-read vm-data/user-metadata/rackconnect_automation_status
          register: rcas
          when: bootstrap.stat.exists != True
          until: rcas.stdout|replace('"', '') == 'DEPLOYED'
          retries: 30
          delay: 10

        - name: Wait for rax_service_level_automation xenstore key to exist
          command: xenstore-exists vm-data/user-metadata/rax_service_level_automation
          register: rsla_exists
          when: bootstrap.stat.exists != True
          failed_when: rsla_exists.rc|int > 1
          until: rsla_exists.rc|int == 0
          retries: 30
          delay: 10

        - name: Wait for managed cloud automation to complete
          command: xenstore-read vm-data/user-metadata/rackconnect_automation_status
          register: rsla
          when: bootstrap.stat.exists != True
          until: rsla.stdout|replace('"', '') == 'DEPLOYED'
          retries: 30
          delay: 10

        - name: Set bootstrap completed
          file:
            path: /etc/bootstrap_complete
            state: touch
            owner: root
            group: root
            mode: 0400
    
    - name: Base Configure Servers
      hosts: all
      connection: local
      roles:
        - role: users
    
        - role: openssh
          opensshd_PermitRootLogin: "no"
    
        - role: ntp

.. _advanced_usage:

高级用法
``````````````

.. _awx_autoscale:

Tower 中的自动伸缩
++++++++++++++++++++++

:doc:`tower` 中包含一个非常好的功能 自动伸缩. 在这种模式下, 一个简单的 curl 脚本可以调用定义的 URL, 通过这个请求, 服务器将会被 "dial out" 或者配置一个新的服务器并启动. 这对于临时节点的控制是非常伟大的. 查看 Tower 文档获取更多细节.

在 Tower 上使用回调的方式覆盖 Pull 模式的好处在于, 任务的结果被集中的存放, 避免了主机之间信息共享

.. _pending_information:

Rackspace Cloud 中的流程
++++++++++++++++++++++++++++++++++++

Ansible 是一个强大的编排工具, 搭配 rax 模块使你有机会完成复杂任务的部署和配置. 这里的关键是自动配置的基础设施, 就像一个环境中任何的服务软件. 复杂的部署以前可能需要手动配置负载均衡器或手动配置服务器. 利用 Ansible 和 rax 模块, 可以使其他节点参照当前运行的一些节点来部署, 或者一个集群的应用程序依赖于具有公共元数据的节点数量. 例如, 人们可以完成下列情况:

* 将服务器从云负载均衡器中一个一个的删除, 更新, 验证并且返回一个负载均衡池
* 对一个已存在的线上环境进行扩展, 哪些节点需要提供软件, 引导, 配置和安装
* 在节点下线之前将应用程序的日志上传至中心存储, 像云存储
* 关于服务器在负载均衡器中的 DNS 记录的创建和销毁




