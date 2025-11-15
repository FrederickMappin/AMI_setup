#!/bin/bash

set -e  # Exit on error

echo "=== Updating System Packages ==="
sudo apt-get update

echo ""
echo "=== Installing Required Dependencies ==="
echo "Installing Java (required for Nextflow)..."
sudo apt-get install -y default-jre

echo ""
echo "=== Installing AWS CLI ==="

# Check if AWS CLI is already installed
if command -v aws &> /dev/null; then
    echo "AWS CLI is already installed: $(aws --version)"
else
    echo "Installing AWS CLI..."
    
    # Download and install AWS CLI v2
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
    
    echo "AWS CLI installed successfully: $(aws --version)"
fi

echo ""
echo "=== Installing Nextflow ==="

# Check if Nextflow is already installed
if command -v nextflow &> /dev/null; then
    echo "Nextflow is already installed: $(nextflow -version 2>&1 | head -n 1)"
else
    echo "Installing Nextflow..."
    
    # Install Nextflow
    cd /tmp
    curl -s https://get.nextflow.io | bash
    sudo mv nextflow /usr/local/bin/
    sudo chmod +x /usr/local/bin/nextflow
    
    echo "Nextflow installed successfully: $(nextflow -version 2>&1 | head -n 1)"
fi

echo ""
echo "=== Configuring AWS Batch Requirements ==="

# Create .nextflow directory for configs
mkdir -p ~/.nextflow

# Set optimal JVM settings for Nextflow
echo "Configuring JVM settings for Nextflow..."
cat > ~/.nextflow/jvm.options <<EOF
-Xms512m
-Xmx2g
-XX:+UseG1GC
EOF

echo "AWS Batch setup complete!"
echo ""
echo "IMPORTANT: To use AWS Batch, you'll need to:"
echo "1. Configure AWS credentials: aws configure"
echo "2. Create a Nextflow config with AWS Batch settings"
echo "3. Ensure IAM roles have appropriate permissions for Batch, S3, ECR, CloudWatch"

echo ""
echo "=== Cleaning Up ==="

# Clean apt cache if using apt
if command -v apt-get &> /dev/null; then
    echo "Cleaning apt cache..."
    sudo apt-get clean
    sudo rm -rf /var/lib/apt/lists/*
fi

# Clean temporary files
echo "Cleaning temporary files..."
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clear bash history (for AMI)
echo "Clearing bash history..."
history -c
cat /dev/null > ~/.bash_history

# Clear log files
echo "Clearing log files..."
sudo find /var/log -type f -exec truncate -s 0 {} \;

echo ""
echo "=== Installation Complete ==="
echo "AWS CLI version: $(aws --version)"
echo "Nextflow version: $(nextflow -version 2>&1 | head -n 1)"
echo ""
echo "System ready for AMI creation"
