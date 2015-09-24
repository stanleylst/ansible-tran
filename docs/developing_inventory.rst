开发动态的Inventory数据源
====================================

.. contents:: Topics
   :local:

如 :doc:`intro_dynamic_inventory` 所介绍,ansible可以从一个动态的数据源获取到inventory信息,包含云端数据源

怎么写一个自己的数据源?

很简单！我们仅仅需要创建一个在适当参数下,能够返回正确JSON格式数据的脚本或者程序,你可以使用任何语言来实现.

.. _inventory_script_conventions:

脚本规范
``````````````````

当我们在外部使用``--list``参数调用这个脚本时,这个脚本必须返回一个JSON散列/字典,它包含所管理的所有组.每个组的value应该是一个关于其包含的主机/IP哈希/字典,它可能是一个子组或者组的变量或者仅仅是一个主机/IP的列表, 例如::

    {
        "databases"   : {
            "hosts"   : [ "host1.example.com", "host2.example.com" ],
            "vars"    : {
                "a"   : true
            }
        },
        "webservers"  : [ "host2.example.com", "host3.example.com" ],
        "atlanta"     : {
            "hosts"   : [ "host1.example.com", "host4.example.com", "host5.example.com" ],
            "vars"    : {
                "b"   : false
            },
            "children": [ "marietta", "5points" ]
        },
        "marietta"    : [ "host6.example.com" ],
        "5points"     : [ "host7.example.com" ]
    }


.. versionadded:: 1.0

在版本1.0之前,每一个组只能是一个包含hostnames/IP Address的列表,像上面的webservers, marietta, 5points组

当我们使用``--host <hostname>``(这里的<hostname>只指相对上面数据中的host)参数调用时,这个脚本必须返回一条空的JSON 哈希/字典, 或者关于变量的JSON哈希/字典,这些变量将被用来模板或者playbooks. 返回变量是可选的,如果脚本不希望这样做,返回一条空的哈希/字典即可::

    {
        "favcolor"   : "red",
        "ntpserver"  : "wolf.example.com",
        "monitoring" : "pack.example.com"
    }

.. _inventory_script_tuning:


开启调用外部Inventory脚本
````````````````````````````````````

.. versionadded:: 1.3

这个inventory脚本系统在所有的Ansible版本中都将会被调用,但是当使用``--host``参数操作每一台主机时,这将是十分麻烦(低效率),尤其是当它用在调用远程子系统时.在Ansible 1.3以后的版本(包含1.3),如果inventory脚本返回的顶级元素为"_meta",它可能会返回所有主机的变量.如果这个元素中包含一个名为"hostvars"的value,这个inventory脚本对每一台主机使用``--host``时将不会被调用.这将大大增加主机的执行效率,并且也使客户端更容易实现这个脚本的数据缓存.

这个数据将会被添加到JSON字典的顶级,像下面的格式::

    {

        # results of inventory script as above go here
        # inventory脚本将到此终止
        # ...

        "_meta" : {
           "hostvars" : {
              "moocow.example.com"     : { "asdf" : 1234 },
              "llama.example.com"      : { "asdf" : 5678 },
           }
        }

    }

.. seealso::

   :doc:`developing_api`
       Python API to Playbooks and Ad Hoc Task Execution
   :doc:`developing_modules`
       How to develop modules
   :doc:`developing_plugins`
       How to develop plugins
   `Ansible Tower <http://ansible.com/ansible-tower>`_
       REST API endpoint and GUI for Ansible, syncs with dynamic inventory
   `Development Mailing List <http://groups.google.com/group/ansible-devel>`_
       Mailing list for development topics
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel
