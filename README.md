# Capsule Shield

A [caplet](https://github.com/puniverse/capsule#what-are-caplets) that launches a [capsule](https://github.com/puniverse/capsule) in a minimal container.

## Requirements

In addition to [Capsule's](https://github.com/puniverse/capsule):

  * [LXC tools](https://linuxcontainers.org/) correctly installed, including extras for unprivileged support (for Ubuntu see e.g. [here](http://www.unixmen.com/setup-linux-containers-using-lxc-on-ubuntu-15-04/))
  * Other (rather basic) tools such as `dhclient`, `tar`, `cat`, `sh`, `bash`, `id`, `ifconfig`, `route`, `kill`, `test` correctly installed
  * Only for unprivileged containers: the regular user running the capsule must have been assigned a range of subordinate uids and gids through e.g. `sudo usermod -v 100000-165536 -w 100000-165536`

## Usage

The Gradle-style dependency you need to embed in your Capsule JAR, which you can generate with the tool you prefer (f.e. with plain Maven/Gradle as in [Photon](https://github.com/puniverse/photon) and [`capsule-gui-demo`](https://github.com/puniverse/capsule-gui-demo) or higher-level [Capsule build plugins](https://github.com/puniverse/capsule#build-tool-plugins)), is `co.paralleluniverse:capsule-shield:0.2.0-SNAPSHOT`. Also include the caplet class in your Capsule manifest, for example:

``` gradle
    Caplets: MavenCapsule ShieldedCapsule
```

`capsule-shield` can also be run as a wrapper capsule without embedding it:

``` bash
$ java -Dcapsule.log=verbose -jar capsule-shield-0.2.0-SNAPSHOT.jar my-capsule.jar my-capsule-arg1 ...
```

It can be both run against (or embedded in) plain (e.g. "fat") capsules and [Maven-based](https://github.com/puniverse/capsule-maven) ones.

## Notes

Please note that an unprivileged container's root disk is owned by a _subuid_ of the user launching the capsule and **cannot be destroyed without user mapping**; should you want or need you can destroy the container by launching the capsule with the `capsule.shield.lxc.destroyOnly` option set. The removal can also be performed manually with `lxc-destroy -n lxc -P ${HOME}/.capsule-shield/<app-id>` (or `lxc-destroy -n lxc -P ${CAPSULE_CACHE_DIR}/../.capsule-shield/<app-id>` if Capsule's cache directory had been re-defined through the `CAPSULE_CACHE_DIR` environment variable in the run that created the container).

## Additional Capsule manifest entries

The following additional manifest entries and capsule options can be used to customize the container environment:

  * `capsule.shield.lxc.destroyOnly` capsule option: if present or `true`, the container will be forcibly destroyed without re-creating and booting it afterwards.
  * `capsule.shield.lxc.privileged` capsule option: whether the container will be a privileged one or not; unprivileged containers build upon [Linux User Namespaces](https://lwn.net/Articles/531114/) and are safer (default: `false`).
  * `capsule.shield.jmx` capsule option: whether JMX will be proxied from the capsule parent process to the container (default: `true`).
  * `capsule.shield.redirect` capsule option: whether Log4J events should be redirected to a SocketNode running in the capsule process (default: `true`, requires `capsule.shield.jmx`).
  * `capsule.shield.redirectLog4j.slf4jVer` capsule option: the SLF4J version that will be used as a bridge to Log4J when redirecting application logs (default: `1.7.12`, requires `capsule.shield.redirect` and potentially `MavenCapsule` if the relevant JARs are not already included in the capsule).
  * `capsule.shield.redirectLog4j.log4j2Ver` capsule option: the version of the Log4J V2 bridge to SLF4J when redirecting application logs (default: `2.4`, requires `capsule.shield.redirect` and potentially `MavenCapsule` if the relevant JARs are not already included in the capsule).
  * `capsule.shield.redirectLog4j` capsule option: the Log4J version that will be used when redirecting application logs (default: `1.2.17`, requires `capsule.shield.redirect` and potentially `MavenCapsule` if the relevant JARs are not already included in the capsule).

  * Valid for both privileged and unprivileged containers:
    * `capsule.shield.lxc.sysShareDir` capsule option: the location of the LXC toolchain's system-wide `share` directory; this is installation/distro-dependent but the default should work in most cases (default: `/usr/share/lxc`).
    * `LXC-Networking-Type`: the LXC networking type to be configured (default: `veth`). The `capsule.shield.lxc.networkingType` capsule option can override it.
    * `LXC-Network-Bridge`: the name of the host bridge adapter for LXC networking (default: `lxcbr0`). The `capsule.shield.lxc.networkBridge` capsule option can override it.
    * `LXC-Allow-TTY`: whether the console device will be enabled in the container (default: `false`). The `capsule.shield.lxc.allowTTY` capsule option can override it.
    * `Hostname`: the host name assigned to the container (default: _none_). The `capsule.shield.hostname` capsule option can override it.
    * `Set-Default-GW`: whether the default gateway should be set in order to grant internet access to the container (default: `true`). The `capsule.shield.setDefaultGW` capsule option can override it.
    * `Static-IP`: whether the default gateway should be set in order to grant internet access to the container (default: `true`). The `capsule.shield.staticIP` capsule option can override it.
    * `Memory-Limit`: `cgroup` memory limit (default: _none_). The `capsule.shield.memoryLimit` capsule option can override it.
    * `CPU-Shares`: `cgroup` cpu shares (default: _none_). The `capsule.shield.cpuShares` capsule option can override it.

  * Valid only for unprivileged containers ([some insight about user namespaces and user mappings](https://lwn.net/Articles/532593/) can be useful):
    * `capsule.shield.lxc.unprivileged.uidMapStart` capsule option: the first user ID in an unprivileged container (default: `100000`)
    * `capsule.shield.lxc.unprivileged.uidMapSize` capsule option: the size of the consecutive user ID map in an unprivileged container (default: `65536`)
    * `capsule.shield.lxc.unprivileged.gidMapStart` capsule option: the first group ID in an unprivileged container (default: `100000`)
    * `capsule.shield.lxc.unprivileged.gidMapSize` capsule option: the size of the consecutive group ID map in an unprivileged container (default: `65536`)
    * `Allowed-Devices`: a list of additional allowed devices in an unprivileged container (example: `"c 136:* rwm" ""`, default: _none_). The `capsule.shield.allowedDevices` capsule option can override it.

The LXC container (both configuration file and a minimal root disk containing mostly mount points) will be created in `${HOME}/.capsule-shield/<app-id>/lxc` (or `${CAPSULE_APP_CACHE}/../capsule-shield/<app-id>/lxc` if Capsule's cache directory has been re-defined through the `CAPSULE_CACHE_DIR` environment variable) and re-created automatically when needed.

## License

    Copyright (c) 2015, Parallel Universe Software Co. and Contributors. All rights reserved.

    This program and the accompanying materials are licensed under the terms
    of the Eclipse Public License v1.0 as published by the Eclipse Foundation.

        http://www.eclipse.org/legal/epl-v10.html
