# Define paths
    REPO_DIR="/home/boringpi/git/Website"   # change this to your actual git repo path
    TARGET_DIR="/var/www/html"
    
    echo ">>> Pulling latest changes from Git..."
    cd "$REPO_DIR" || { echo "❌ Failed to cd into repo directory"; exit 1; }
    
    git pull origin main || { echo "❌ Git pull failed"; exit 1; }
    
    echo ">>> Removing old files from $TARGET_DIR..."
    sudo rm -rf "$TARGET_DIR"/*
    
    echo ">>> Copying updated files to $TARGET_DIR..."
    sudo cp -r "$REPO_DIR"/* "$TARGET_DIR"
    echo ">>> Setting permissions..."
    sudo chown -R www-data:www-data "$TARGET_DIR"
    sudo chmod -R 755 "$TARGET_DIR"
    
    echo ">>> Restarting Apache..."
    sudo systemctl restart apache2
    
    echo "✅ Deployment complete!"
    ```