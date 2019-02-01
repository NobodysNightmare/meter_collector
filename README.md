# MeterCollector

This is an application that I am using to read out the "smart meters" that
are installed in my home.

It can print out readings or upload them to my [energy application](https://github.com/NobodysNightmare/energy),
which is collecting this kind of data.

## Compatibility

I only tested the application with my own equipment, but it should generally
be compatible with IEC 62056-21 compliant meters that use Mode C.

Furthermore, results can be read from ModBus devices. ModBus is supported by a bunch of photovoltaic inverters and many
top-rail-mountable meters.

The repository also contains some code for SML parsing. [SML](https://de.wikipedia.org/wiki/Smart_Message_Language) is
another fancy standard to transmit smart meter data.
But that implementation is incomplete and has never been used productively.

## Usage

Copy the sample configuration into a new file, e.g. `configuration.yml`.

Adapt the file to your needs.

Finally:

```bash
$ bin/meter_collector -f configuration.yml
```
