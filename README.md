# genesis-tasks
Tasks for use in the tumblr/genesis framework.

## Packaging

Real simple stuff...

```
tar czf tasks.tar.gz tasks/*
```

## Tools

The `tools/dell` directory contains a tgz with all the rpm files
that are needed for setting an asset tag. After you unzip and install
the RPMs that are built for centos6 you can set the asset tag as follows.

```
smbios-sys-info --asset-tag --set=SOME_TAG
```

Reboot your system for it to take effect in tools such as dmidecode. Possibly
you can do this in a much more surgical way but I haven't found it.
