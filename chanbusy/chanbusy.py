#!/usr/bin/env python

import click
import os, os.path
import sys
import time

@click.command()
@click.argument('samprate_hz', type=int)
def main (samprate_hz):
    def fp (p):
        return '/sys/kernel/debug/ieee80211/{}'.format(p)

    freq = 1.0 / samprate_hz

    try:
        path = '/sys/kernel/debug/ieee80211'
        phys = sorted([p for p in os.listdir(path)])
        phydirs = [fp(p) for p in phys if os.path.isdir(fp(p))]
    except OSError:
        sys.stderr.write('cannot open debugfs path; exiting.\n')
        sys.exit(1)

    busy_pct_files = ['{}/ath9k/busy_pct'.format(d) for d in phydirs]
    print ','.join(['{}_busy'.format(b) for b in phys])

    while True:
        print ','.join([open(b, 'r').readline().rstrip() for b in busy_pct_files])
        time.sleep(freq)

if __name__ == '__main__':
    main()
