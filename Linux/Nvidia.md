Power Limt: https://chatgpt.com/share/040d0771-af6a-4055-b472-994d5487c515

If your system doesn't have `/etc/init.d`, you are likely using a system that relies on `systemd` for service management. In this case, you can create a `systemd` service unit directly to set the power limit at startup.

Here’s how to do it:

### 1. **Create a Script to Set the Power Limit**

First, create a script that sets the desired power limit using `nvidia-smi`. This script will be called by the `systemd` service.

```sh
sudo nano /usr/local/bin/set_nvidia_power_limit.sh
```

Add the following content to the script:

```sh
#!/bin/bash
# Set the power limit for NVIDIA GPU to 150 watts (example)
nvidia-smi -pl 150
```

Replace `150` with your desired power limit in watts. Save and close the file.

### 2. **Make the Script Executable**

Make sure the script is executable:

```sh
sudo chmod +x /usr/local/bin/set_nvidia_power_limit.sh
```

### 3. **Create a systemd Service Unit**

Next, create a `systemd` service unit file:

```sh
sudo nano /etc/systemd/system/nvidia-power-limit.service
```

Add the following content to the file:

```ini
[Unit]
Description=Set NVIDIA GPU Power Limit
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/set_nvidia_power_limit.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

This configuration tells `systemd` to run the script when the system reaches the `multi-user.target`, which is a common default for user sessions.

### 4. **Enable the Service**

To ensure the service runs at startup, enable it with the following command:

```sh
sudo systemctl enable nvidia-power-limit.service
```

### 5. **Start the Service Immediately (Optional)**

If you want to apply the power limit immediately without rebooting, start the service with:

```sh
sudo systemctl start nvidia-power-limit.service
```

### 6. **Verify the Power Limit**

To confirm that the power limit has been set, you can run:

```sh
nvidia-smi -q -d POWER
```

### **Notes**

- **Power Limit Adjustment**: The power limit set should be within the allowable range for your specific GPU model. Exceeding this range can result in errors or damage to the hardware.
- **Script Path**: The script path `/usr/local/bin/set_nvidia_power_limit.sh` is arbitrary; you can place the script in any directory as long as it is accessible and correctly referenced in the service unit file.

By setting up the `systemd` service, the power limit configuration will be applied automatically every time the system boots, ensuring consistent GPU power management.
