# HA Proxy user setup

It's a good idea to create a non-root user just to manage haproxy access. In this example, the user is named `wireproxy`.

```
# Login to the Raspberry Pi
# Install haproxy
sudo apt-get install haproxy
sudo systemctl enable haproxy
sudo systemctl start haproxy
# Run this from a user with sudo privileges
sudo EDITOR=vim visudo
%wireproxy ALL= (root) NOPASSWD: /bin/systemctl restart haproxy

sudo addgroup wireproxy
sudo adduser --disabled-password --ingroup wireproxy wireproxy
```

You'll need to make sure that you're able to ssh into this user account without a password. For example, let's say the user with sudo privileges is named `ubuntu`. Follow these steps to enable passwordless SSH for `ubuntu`.

```
# Run this from your Client
# Change user/IP address here as needed
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.0.100
```

Now you can either follow the same steps for the `wireproxy` user (not recommended as we don't want to give the `wireproxy` user a password) or you can copy the `~/.ssh/authorized_keys` file from the `ubuntu` user to this user.

```
# Login to the Raspberry Pi with user 'ubuntu'
cat ~/.ssh/authorized_keys
# Copy the value in a clipboard
sudo su wireproxy
# You're now logged in as wireproxy user
vim ~/.ssh/authorized_keys
# Paste the same key here
# Logout from the Raspberry Pi
# Make sure you're able to ssh in wireproxy user from your Client
ssh wireproxy@192.168.0.100
```

Using the same example, the user `wireproxy` needs to own the files under `/etc/haproxy`

```
# Login to the Raspberry Pi with user 'ubuntu'
sudo chown -R wireproxy: /etc/haproxy
```