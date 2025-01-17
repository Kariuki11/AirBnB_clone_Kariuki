#!/usr/bin/python3
"""A module for web application deployment with Fabric."""
import os
from datetime import datetime
from fabric.api import env, local, put, run, runs_once, sudo


# Load server IPs from environment variables (assuming they are set)
env.user = "username"  # Assuming you have SSH access with username
env.hosts = [os.getenv("HOST1_IP", ""), os.getenv("HOST2_IP", "")]

@runs_once
def do_pack():
    """Archives the static files."""
    if not os.path.isdir("versions"):
        os.mkdir("versions")
    cur_time = datetime.now()
    output = "versions/web_static_{}{}{}{}{}{}.tgz".format(
        cur_time.year,
        cur_time.month,
        cur_time.day,
        cur_time.hour,
        cur_time.minute,
        cur_time.second
    )
    try:
        print("Packing web_static to {}".format(output))
        local("tar -cvzf {} web_static".format(output))
        archive_size = os.stat(output).st_size
        print("web_static packed: {} -> {} Bytes".format(output, archive_size))
    except Exception:
        output = None
    return output

def do_deploy(archive_path):
    """Deployment of - static files to the host servers.

    Args:
        archive_path (str): The path to the archived static files.

    Returns:
        bool: True on success, False on failure.
    """
    if not os.path.exists(archive_path):
        return False

    file_name = os.path.basename(archive_path)
    folder_name = file_name.replace(".tgz", "")
    folder_path = "/data/web_static/releases/{}/".format(folder_name)

    try:
        put(archive_path, "/tmp/{}".format(file_name))
        with sudo():
            run("mkdir -p {}".format(folder_path))
            run("tar -xzf /tmp/{} -C {}".format(file_name, folder_path))
            run("rm -rf /tmp/{}".format(file_name))
            run("mv {}web_static/* {}".format(folder_path, folder_path))
            run("rm -rf {}web_static".format(folder_path))
            run("rm -rf /data/web_static/current")
            run("ln -s {} /data/web_static/current".format(folder_path))
        print('New version deployed!')
        return True
    except Exception as e:
        print(f"Error during deployment: {e}")
        return False