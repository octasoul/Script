#!/usr/bin/env bash

echo "========== Upload =========="
echo "[1] GitHub Release"
echo "[2] SourceForge"
echo "[3] PixelDrain"
echo "[4] GoFile"
echo "============================"

read -p "Choose: " UP
read -e -p "File: " FP

[ ! -f "$FP" ] && { echo "File not found!"; exit 1; }

FN=$(basename "$FP")

case "$UP" in

1)
    read -p "Repository (user/repo): " REPO
    read -p "Tag: " TAG

    gh release view "$TAG" -R "$REPO" >/dev/null 2>&1 || \
    gh release create "$TAG" --title "$TAG" --notes "Release" -R "$REPO"

    echo "Uploading..."
    gh release upload "$TAG" "$FP" --clobber -R "$REPO"

    echo
    echo "Upload Successful!"
    echo "https://github.com/$REPO/releases/tag/$TAG"
    ;;

2)
    read -p "SourceForge Username: " USER
    read -p "Project: " PROJECT
    read -p "Folder: " DIR

    echo "Uploading..."
    scp "$FP" "$USER@frs.sourceforge.net:/home/frs/project/$PROJECT/$DIR/"

    echo
    echo "Upload Successful!"
    echo "https://sourceforge.net/projects/$PROJECT/files/$DIR/$FN"
    ;;

3)
    read -p "PixelDrain API Key: " KEY

    echo "Uploading..."
    RESULT=$(curl -T "$FP" \
        -u ":$KEY" \
        https://pixeldrain.com/api/file)

    ID=$(echo "$RESULT" | grep -oP '"id":"\K[^"]+')

    echo
    echo "Upload Successful!"
    echo "https://pixeldrain.com/u/$ID"
    ;;

4)
    echo "Uploading..."

    SERVER=$(curl -s https://api.gofile.io/servers | grep -oP '"name":"\K[^"]+' | head -1)

    RESULT=$(curl \
        -F "file=@$FP" \
        "https://${SERVER}.gofile.io/uploadFile")

    LINK=$(echo "$RESULT" | grep -oP '"downloadPage":"\K[^"]+')

    echo
    echo "Upload Successful!"
    echo "$LINK"
    ;;

*)
    echo "Invalid Choice!"
    ;;
esac
