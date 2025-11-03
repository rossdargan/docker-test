Simple install method:

``` bash
curl -fsSL https://raw.githubusercontent.com/rossdargan/docker-test/refs/heads/main/install.sh | sudo bash
```

Safer install method:

``` bash
# Download the script first
curl -fsSL https://raw.githubusercontent.com/rossdargan/docker-test/refs/heads/main/install.sh -o install.sh

# Review it
cat install.sh

# Make it executable and run it
chmod +x install.sh
sudo ./install.sh
```
