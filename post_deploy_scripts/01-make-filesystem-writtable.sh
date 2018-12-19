echo ""
echo "Making the filesystem writable so that translations can be saved"
echo ""
sed -i "s/'DISALLOW_FILE_MODS', true/'DISALLOW_FILE_MODS', false/g" public/wp-config.php