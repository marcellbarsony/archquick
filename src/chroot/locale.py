import logging
import subprocess
import sys


"""
Docstring for Locale
https://wiki.archlinux.org/title/locale
"""

def locale():
    locale_gen = "/etc/locale.gen"
    try:
        with open(locale_gen, "r") as file:
            lines = file.readlines()
    except Exception as err:
        print(f":: [-] Reading {locale_gen}", err)
        logging.info(f"Reading {locale_gen}")
        sys.exit(1)

    lines[170] = "en_US.UTF-8 UTF-8\n"
    lines[295] = "ja_JP.UTF-8 UTF-8\n"
    try:
        with open(locale_gen, "w") as file:
            file.writelines(lines)
        print(f":: [+] Set {locale_gen}")
        logging.info(locale_gen)
    except Exception as err:
        print(f":: [-] Set {locale_gen}", err)
        logging.error(f"{locale_gen}: {err}")
        sys.exit(1)

def conf():
    locale = "LANG=en_US.UTF-8"
    locale_conf = "/etc/locale.conf"
    try:
        with open(locale_conf, "a") as file:
            file.write(f"{locale}\n")
        print(f":: [+] Set {locale_conf}")
        logging.info(locale_conf)
    except Exception as err:
        print(f":: [-] Set {locale_conf}", err)
        logging.error(f"{locale_conf}\n{err}")
        sys.exit(1)

def gen():
    cmd = "locale-gen"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] Locale-gen")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] Locale-gen", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)
