#!/bin/bash
display_success_message() {

    GREEN='\033[38;5;83m'
    NC='\033[0m'	
    # Get the IP address
    IP=$(hostname -I | awk '{print $1}')
    
    # Get the port from the file
    PORT=2025
	DB_PASSWORDx=$(get_password_from_file "/usr/local/facecompare/main/etc/apikey.txt")
   
    
    # Print success message in green
    echo "${GREEN}You have successfully installed the facecompare panel!"
    echo "api URL is: https://${IP}:${PORT}"
  
    echo "apikey: ${DB_PASSWORDx}${NC}"
}
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
 sudo apt install tesseract-ocr 
sudo apt install libtesseract-dev 
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
allow_port() {
    local port=$1
    if [[ -z "$port" ]]; then
        echo "Usage: allow_port <port>"
        return 1
    fi

    # Detect firewall type
    if command -v ufw &>/dev/null && sudo ufw status &>/dev/null; then
        sudo ufw allow "${port}/tcp"
        sudo ufw reload
        echo "Allowed $port/tcp through UFW."
    elif command -v firewall-cmd &>/dev/null && sudo systemctl is-active firewalld &>/dev/null; then
        sudo firewall-cmd --permanent --add-port="${port}/tcp"
        sudo firewall-cmd --reload
        echo "Allowed $port/tcp through firewalld."
    else
        sudo iptables -C INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null || sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
        sudo iptables -C OUTPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null || sudo iptables -A OUTPUT -p tcp --dport "$port" -j ACCEPT
        echo "Allowed $port/tcp through iptables."
    fi
}


install_pip
install_python_dependencies_in_venv
allow_port 2025

sudo wget -q -O /usr/local/facecompare/main.zip https://github.com/osmanfc/face_compare/raw/main/main.zip && sudo unzip -q /usr/local/facecompare/main.zip -d /usr/local/facecompare && sudo rm /usr/local/facecompare/main.zip
sudo wget -q -O /etc/systemd/system/facecp.service https://raw.githubusercontent.com/osmanfc/face_compare/refs/heads/main/facecp.service
sudo systemctl daemon-reload
sudo systemctl enable facecp
sudo systemctl start facecp
sudo systemctl status facecp
display_success_message
