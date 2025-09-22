#!/bin/bash

install_pip() {
    echo "Updating system..."
    wait_for_apt_lock
    sudo apt update && sudo apt upgrade -y
    echo "Installing Python..."
    wait_for_apt_lock
    sudo apt install python3 python3-venv python3-pip pkg-config libmysqlclient-dev -y
    sudo apt install -y python3 python3-venv python3-pip build-essential cmake \
    libopenblas-dev liblapack-dev libx11-dev libgtk-3-dev
    # Check Ubuntu version and use virtual environment if Ubuntu 24.04+

        echo "Creating virtual environment for Python dependencies..."
        python3 -m venv /root/venv
        source /root/venv/bin/activate
   
    
    echo "Upgrading pip and setuptools..."
    pip install --upgrade pip setuptools
    echo "Installing mysqlclient..."
    pip install --no-binary :all: mysqlclient
    
    
    deactivate
  
    
    echo "Python and pip setup completed!"
}

install_python_dependencies_in_venv() {
wget -O ub24req.txt "https://raw.githubusercontent.com/osmanfc/face_compare/main/ub24req.txt"
    echo "Installing Python dependencies from requirements.txt in a virtual environment..."

    # Define the virtual environment name
    VENV_DIR="/root/venv"

    # Create the virtual environment (if not already created)
    if [ ! -d "$VENV_DIR" ]; then
        echo "Creating virtual environment..."
        python3 -m venv "$VENV_DIR"
    else
        echo "Virtual environment already exists."
    fi

    # Activate the virtual environment
    echo "Activating virtual environment..."
    source "$VENV_DIR/bin/activate"

    # Upgrade pip and install dependencies
    echo "Upgrading pip and installing packages..."
    "$VENV_DIR/bin/python3" -m pip install --upgrade pip
    "$VENV_DIR/bin/python3" -m pip install -r ub24req.txt

    # Deactivate the virtual environment
    echo "Deactivating virtual environment..."
    deactivate

    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo "Python dependencies installed successfully in the virtual environment."
    
    fi
}
allow_ports() {

    # Allow each port through UFW and iptables
    for port in "$@"; do
        # UFW rule
        sudo ufw allow "$port/tcp"
        echo "Allowed $port/tcp through UFW."

        # iptables rule
        sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
        sudo iptables -A OUTPUT -p tcp --dport "$port" -j ACCEPT
        echo "Allowed $port/tcp through iptables."
    done

    # Special case for port range 40110-40210
    sudo ufw allow 40110:40210/tcp
    sudo iptables -A INPUT -p tcp --dport 40110:40210 -j ACCEPT
    sudo iptables -A OUTPUT -p tcp --dport 40110:40210 -j ACCEPT
    echo "Allowed 40110:40210/tcp through both UFW and iptables."

    sudo ufw allow 53/udp
    sudo ufw reload
    echo "UFW rules reloaded."

    return 0
}
