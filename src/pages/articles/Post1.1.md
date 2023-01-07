---
public: true
layout: ../../layouts/BlogPost.astro

title: Bundling your Flutter project into a snap file in 2023
description: How to properly configure snapcraft to compile your Flutter application

createdAt: 1673091276
updatedAt: 1673091276
heroImage: /snapcraft.png
---

Recently, I faced a problem when attempting to release a project I work on to the Snap store[^1].

It's built with Flutter, and we had followed the official documentation to a tee, but the application wasn't working 
properly.

After hours reading through the snapcraft forum and many of their documentation pages, here's what I've learned.

> TL;DR: check the [example snapcraft.yaml](#snapcraftyaml-example) at the end.

# See the snapcraft.yaml file as you would a CI/CD platform configuration file

Turns out that they are very similar in that you must describe, in one way or another, how to bring
a fresh image (a docker image in case of CircleCI, for example) into a state where it can build your application.

It sounds obvious, but that distinction wasn't clear to me at first. Being the person responsible for building
the entire CI/CD pipelines for this very same project, I was accustomed to the hurdles that come with developing
such infrastructures.

But I approached the snapcraft configuration from a different perspective, and it slowed me down considerably.
Once I realized this, I quickly got back on track:

###### You must describe in the configuration how the base will reach a state where it:
###### 1. can build/compile your project, and;
###### 2. can run your project

# The anatomy of a snapcraft.yaml file

All snapcraft.yaml files are composed of at least 4 sections. Those are:

**1 - [The metadata](#metadata)**

**2 - [The security model](#security-model)**

**3 - [The parts](#parts)**

**4 - [The app](#app)**


##### Metadata

This set of keys briefly describes characteristics of your project. Things like `name`, `base`, `version`, `summary` and `description`.
This is the least mission critical section, with exception to the `name` - which must be unique in the snap store, and
the `base` you use - similar to what docker image you would use in a docker-based automation system.

##### Security model

The snap system has a tight security model, and you will need to go very much deep into it prior to moving your
app from `confinement: devmode` to `confinement: strict`. Just know for now that the former allows you to
temporarily bypass the security features in order to test your app and find which interfaces your app needs [^2].

##### Parts

Here lies the heart of your application. The parts describe the steps to bring your `base` into a state where
the internal snap environment will have a compiled version of your app.

You can have many parts, and also describe the order they must be executed in. Installing dependencies, copying
assets, making libraries available to your app and compiling code are all examples of things that occur in this
step. This is the most critical section of your snapcraft.

##### App

Finally, the apps are the commands/applications exposed to end users. For a flutter project, there will usually
be only one: the actual application.

It's also in here that you'll describe `plugs` and `slots` in order to comply with the security model.

# Successfully compiling a Flutter app with snapcraft

The current [flutter plugin](https://snapcraft.io/docs/flutter-plugin) has been a source of many problems, in
my experience, and since I needed to move from `base: core18` (which is nowadays somewhat obsolete) to `core22`,
I could not make use of it at all.

> Note: There is a new plugin [in the making](https://github.com/snapcore/snapcraft/pull/3952), so hopefully soon this
> workaround is no longer needed.

Luckily, once we understand the role of a part, we can see that we could just add one new part to install flutter
on a `base: core22` and discard the flutter plugin altogether. In fact, many apps[^3] already do so.

We use the `override-build`[^4] key to describe custom steps that we want to execute, both in the `install-flutter` part
and the `build-flutter` part.

Finally, since we're manually installing Flutter, we also replace the [flutter extension](https://snapcraft.io/docs/flutter-extension)
with the [gnome extension](https://snapcraft.io/docs/gnome-extension).

# snapcraft.yaml example

```yaml
name: Flutter App
summary: Example snapcraft.yaml for Flutter apps using core22

base: core22

grade: devel
confinement: devmode

parts:
  install-flutter:
    source: https://github.com/flutter/flutter.git
    source-branch: stable
    plugin: nil
    override-build: |
      set -eux
      mkdir -p $CRAFT_PART_INSTALL/usr/bin
      mkdir -p $CRAFT_PART_INSTALL/usr/libexec
      cp -r $CRAFT_PART_SRC $CRAFT_PART_INSTALL/usr/libexec/flutter
      ln -sf $CRAFT_PART_INSTALL/usr/libexec/flutter/bin/flutter $CRAFT_PART_INSTALL/usr/bin/flutter
      export PATH="$CRAFT_PART_INSTALL/usr/bin:$PATH"
      flutter doctor
      flutter channel stable
      flutter upgrade
    build-packages:
      - clang
      - cmake
      - curl
      - ninja-build
      - unzip
    override-prime: ''
    
  build-flutter:
    plugin: nil
    source: .
    after: [install-flutter]
    override-build: |
      set -eux
      flutter pub get || true
      flutter build linux --release -v
      mkdir -p $CRAFT_PART_INSTALL/bin
      cp -r build/linux/*/release/bundle/* $CRAFT_PART_INSTALL/bin/


slots:
  dbus-app:
    interface: dbus
    bus: session
    name: com.example.app


environment:
  LD_LIBRARY_PATH: ${SNAP_LIBRARY_PATH}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}:$SNAP/usr/lib:$SNAP/usr/lib/x86_64-linux-gnu:$SNAP/bin/lib


apps:
  qaul:
    # Here you should rename "app" to the name of your binary
    # which was copied into the "bin" folder in the last line 
    # of the `build-flutter` part
    command: bin/app
    extensions: [gnome]
    plugs:
      - network
    slots:
      - dbus-app

```


[^1]: 1 - It's called [qaul.net](https://github.com/qaul/qaul.net), and it's open source. Check it out if you want!
[^2]: 2 - Check out this doc about [confinement](https://snapcraft.io/docs/snap-confinement) and this one about the [security model](https://snapcraft.io/docs/choosing-a-security-model) to know more.
[^3]: 3 - Here are a few examples: [firmware-updater](https://github.com/canonical/firmware-updater/blob/main/snap/snapcraft.yaml#L20-L39); [ubuntu software](https://github.com/ubuntu-flutter-community/software/blob/main/snap/snapcraft.yaml#L20-L40); [ubuntu-desktop-installer](https://github.com/canonical/ubuntu-desktop-installer/blob/main/snap/snapcraft.yaml#L128-L148); [workshops](https://github.com/canonical/workshops/blob/main/snap/snapcraft.yaml#L19-L37)
[^4]: 4 - [Snapcraft parts metadata](https://snapcraft.io/docs/snapcraft-parts-metadata); [parts lifecycle](https://snapcraft.io/docs/parts-lifecycle)
