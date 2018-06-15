# MeterCollector

This is an application that I am using to read out the "smart meters" that
are installed in my home.

## Compatibility

I only tested the application with my own equipment, but it should generally
be compatible with IEC 62056-21 compliant meters. So far I only
implemented Mode C.

There is also some code for SML parsing in the repository, but it is incomplete
and has never been used productively.

## Usage

Copy the sample configuration into a new file, e.g. `configuration.yml`.

Adapt the file to your needs. At least set the `path` of your infrared receiver.

Finally:

```bash
$ bin/meter_collector -f configuration.yml
```
