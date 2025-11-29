

find_file_recursive() {
    local dir="$1"
    local filename="PrivacyInfo.xcprivacy"  # 要查找的文件名
    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            result=$(find_file_recursive "$item")
            if [ -n "$result" ]; then
                echo "$result"
                return
            fi
        elif [ -f "$item" ] && [ "$(basename "$item")" = "$filename" ]; then
            echo "$item"
            return
        fi
    done
    echo ""
}

traverse() {
    local target_folder="$1"
    for dir in "$target_folder"/*; do
        if [ -d "$dir" ]; then
            result=$(find_file_recursive "$dir")
            PrivacyInfo="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/FrameworkTemplate.xcprivacy"
            if [ -z "$result" ]; then
                target_File="$dir/PrivacyInfo.xcprivacy"
                cp $PrivacyInfo $target_File
            fi
        fi
    done
}

TARGET_APP_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
TARGET_APP_FRAMEWORK_PATH="$TARGET_APP_PATH/Frameworks"
echo '😄😄😄😄😄😄😄😄😄😄'
traverse "$TARGET_APP_FRAMEWORK_PATH"
