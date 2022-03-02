import paramiko

host = "34.67.110.206"
username = "tanvi"
password = "tanvi"

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())


   
ssh.connect("34.67.110.206",port=22,username=username, password=password)

commands = [
    "pwd",
    "id",
    "uname -a",
    "df -h"
]
# execute the commands

for command in commands:
    print("="*50, command, "="*50)
    stdin, stdout, stderr = ssh.exec_command(command)
    print(stdout.read().decode())
    err = stderr.read().decode()
    if err:
        print(err)