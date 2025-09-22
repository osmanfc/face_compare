#!/bin/bash

install_pip() {
    APP_DIR="/usr/local/facecompare"
    PY_ENV="$APP_DIR/venv"
    mkdir -p "$APP_DIR"

    echo "[INFO] Updating system..."
    wait_for_apt_lock
    sudo apt update && sudo apt upgrade -y

    echo "[INFO] Installing Python and build tools..."
    wait_for_apt_lock
    sudo apt install -y python3 python3-venv python3-pip build-essential cmake \
        pkg-config libopenblas-dev liblapack-dev libx11-dev libgtk-3-dev libmysqlclient-dev

    echo "[INFO] Creating virtual environment..."
    python3 -m venv "$PY_ENV"

    # Activate virtual environment
    source "$PY_ENV/bin/activate"

    echo "[INFO] Upgrading pip and setuptools..."
    pip install --upgrade pip setuptools wheel

    echo "[INFO] Installing mysqlclient..."
    pip install --no-binary :all: mysqlclient

    echo "[INFO] Python virtual environment setup completed!"
    
    # Deactivate virtual environment
    deactivate
}

install_python_dependencies_in_venv() {
wget -O ub24req.txt "https://raw.githubusercontent.com/osmanfc/face_compare/main/ub24req.txt"
    echo "Installing Python dependencies from requirements.txt in a virtual environment..."

    # Define the virtual environment name
     APP_DIR="/usr/local/facecompare"
    VENV_DIR="$APP_DIR/venv"
    

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

wait_for_apt_lock() {
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "Waiting for apt lock to be released..."
        sleep 5
    done
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

install_pip
install_python_dependencies_in_venv
allow_ports 2025
