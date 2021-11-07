# Proxy setup

## apt

```bash
sudo vi /etc/apt/apt.conf.d/proxy.conf
Acquire::http::Proxy "http://user:password@proxy.server:port/";
Acquire::https::Proxy "http://user:password@proxy.server:port/";
```