import shutil
import subprocess
import os


def copytree(src, dst, symlinks=False, ignore=None):
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, symlinks, ignore)
        else:
            shutil.copy2(s, d)


# remove all contents from dist folder
shutil.rmtree("dist")

# run pyinstaller for hid_sender.pyw
subprocess.run(["pyinstaller", "hid_sender.pyw"])

# copy contents from dependencies folder to dist folder
copytree("dependencies", "dist/hid_sender")
