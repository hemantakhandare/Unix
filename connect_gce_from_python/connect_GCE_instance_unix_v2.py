import paramiko

#add your GCE external ip 
host = "30.60.110.706"
username = "tanvi"
password = "tanvi"

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())


   
ssh.connect("30.60.110.706",port=22,username=username, password=password)

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
