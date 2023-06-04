# 1....

Dear Breno

I added many logs to libqaul and it seems to work fine as far as I can see.
Every function is returning correctly and libqaul keeps looping.

Which function did not return?

In order to test it I published my logs on the branch libqaul-snap-debug.
You can test it checking out this branch.

the branch name was added to snapcraft.yaml in the following way:

1234  libqaul:
plugin: nil
source: https://github.com/qaul/qaul.net.git
source-branch: libqaul-snap-debug

In order to rebuild I cleaned only the libqaul part

1234567891011121314# clean libqaul part from build environment
snapcraft clean --use-lxd libqaul

# build it
snapcraft --use-lxd

# remove old build
snap remove --purge qaul

# install new build
snap install qaul_2.0.0-beta.12_amd64.snap --dangerous

# run qaul
qaul

I don't know how you found the blocker on the flutter side, until know I haven't found one on the rust side unfortunately.
Maybe we can make a joint debugging session :)

These are my current logs:

    Libqaul only gets asked twice whether it is initialized and returns with a 0 two times...
    afterwards it does not get asked again and keeps looping.

123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051[sojus@sojus testing]$ qaul
update.go:85: cannot change mount namespace according to change mount (/var/lib/snapd/hostfs/usr/share/fonts /usr/share/fonts-2 none bind,ro 0 0): permission denied
/home/sojus/snap/qaul/common
INFO  libqaul::api > libqaul API start
INFO  libqaul::api > libqaul API start_with_config
INFO  libqaul::api > libqaul API start_with_config done
INFO  libqaul::api > libqaul API starte done
start finished
initialized()
initialized() 0
INFO  libqaul::api > libqaul API start_with_config thread spawned
initialized()
initialized() 0
INFO  libqaul::api > libqaul API start_with_config async started
INFO  libqaul      > start 1
running libqaul 2.0.0-beta.12.1
libqaul data on latest version
INFO  libqaul      > start 2
INFO  libqaul      > start 3
INFO  libqaul      > start 4
ERROR libqaul::storage::configuration > no configuration file found, creating one.
INFO  libqaul                         > start 5
INFO  libqaul                         > start 6
INFO  libqaul                         > start 7
INFO  libqaul                         > start 8
INFO  libqaul                         > test log to ensure that logging is working
INFO  libqaul                         > start Node::init()
INFO  libqaul                         > start Router::init()
INFO  libqaul                         > start Services::init()
INFO  libqaul                         > initializing finished, start event loop
INFO  libqaul                         > loop start 1
INFO  libqaul                         > loop start 2
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 192.168.0.123
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 10.95.11.1
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 172.18.0.1
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 172.23.0.1
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 172.19.0.1
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 172.21.0.1
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 172.22.0.1
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 172.20.0.1
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 172.100.1.1
INFO  libp2p_mdns::behaviour::iface   > creating instance on iface 10.111.85.1
INFO  libqaul                         > loop start 3
INFO  libqaul                         > loop start 4
INFO  libqaul                         > loop start 5
INFO  libqaul                         > loop start 6
INFO  libqaul                         > loop start 7
INFO  libqaul                         > loop start 8
INFO  libqaul                         > loop start 9
INFO  libqaul                         > loop start 10
...

# 2....

I further investigated our snap problem and "solved" at least all possible libqaul problems.
There is one further necessary commit on the branch ``.

Our problem is that we need 4 critical plugs to be connected in order to run the application successfully, which are not auto-connect.

The following plugs are necessary and not auto-connect:

    mount-observe
    process-control
    system-observe
    network-control

One can connect them manually after installation from the command line:

12345678# list all snap connections for qaul
snap connections qaul

# connect snaps that are not autoconnected
sudo snap connect qaul:process-control :process-control
sudo snap connect qaul:system-observe :system-observe
sudo snap connect qaul:mount-observe :mount-observe
sudo snap connect qaul:network-control :network-control

In order to have those plugs auto-connected we would need to go through a review process by the snap store.
It is not fully clear to me if we need to do something additionally or if they will be connected just magically afterwards.

From what I see, we have the following options:

    publish the snap as it is and document how to manually connect those plugs after installation. This can only be a temporary solution IMHO.
    go through the review process.
    build a classic snap. This needs a review process too. It would free us though from future review processes, when we need further plugs.
    build native installation packages for the most popular Linux distributions.

If you have time today, I would love to quickly discuss our strategy with you and the further steps with you.

afterwards qaul is still starting with a blank window and and the following exception.
My best guess is, that this exception is coming from Flutter?

123= AppArmor =
Time: Jan 16 14:54:48
Log: apparmor="DENIED" operation="mount" info="failed flags match" error=-13 profile="snap-update-ns.qaul" name="/usr/share/fonts-2/" pid=1353404 comm="5" srcname="/var/lib/snapd/hostfs/usr/share/fonts/" flags="rw, bind"

(but maybe this is just my build environment...)


# 3 ....
Compilation Instructions

To build the new snap I started from a cleaned environment:

1snapcraft clean --use-lxd

Interesting Snap Compilation Discovery

In order to build process I had the following security exception. This exception was thrown several times. I don't know when that was happening and if it has any effect. It was either before or during the libqaul compilation.

123456= AppArmor =
Time: Jan 16 14:33:35
Log: apparmor="DENIED" operation="file_inherit" namespace="root//lxd-snapcraft-qaul_<var-snap-lxd-common-lxd>" profile="/snap/snapd/17950/usr/lib/snapd/snap-confine" name="/tmp/#58946" pid=1323044 comm="snap-confine" requested_mask="wr" denied_mask="wr" fsuid=1000 ouid=1000
File: /tmp/#58946 (write)
Suggestion:
* adjust program to write to $SNAP_DATA, $SNAP_COMMON, $SNAP_USER_DATA or $SNAP_USER_COMMON

Update:
oh, interesting, the app-armor exception is only thrown on the first launch.
When one launches it again it is not launched anymore but still not working ... (blank window, 100% system load on two processes)...
