#!/bin/bash

# TikTok 视频下载脚本
# 使用 yt-dlp 交互式下载 TikTok 视频

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 脚本信息
SCRIPT_NAME="TikTok 视频下载器"
VERSION="1.0.0"

# 下载文件夹配置
DOWNLOAD_DIR="tiktok_downloads"

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${PURPLE}════════════════════════════════════════${NC}"
    echo -e "${PURPLE}        ${SCRIPT_NAME} v${VERSION}        ${NC}"
    echo -e "${PURPLE}════════════════════════════════════════${NC}"
    echo -e "${CYAN}使用 yt-dlp 下载 TikTok 视频${NC}"
    echo ""
}

# 显示帮助信息
show_help() {
    echo -e "${YELLOW}支持的链接格式：${NC}"
    echo "  • https://www.tiktok.com/@用户名/video/视频ID"
    echo "  • https://vm.tiktok.com/短链接"
    echo "  • https://vt.tiktok.com/短链接"
    echo ""
    echo -e "${YELLOW}操作说明：${NC}"
    echo "  • 输入 'q' 或 'quit' 退出程序"
    echo "  • 输入 'h' 或 'help' 显示帮助"
    echo "  • 输入 'c' 或 'clear' 清屏"
    echo "  • 输入 'l' 或 'list' 查看已下载文件"
    echo ""
}

# 检查依赖
check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}错误: 未找到 python3，请先安装 Python3${NC}"
        exit 1
    fi
    
    if [ ! -f "yt-dlp" ] && ! python3 -m yt_dlp --version &> /dev/null; then
        echo -e "${RED}错误: 未找到 yt-dlp，请确保在正确的目录中运行此脚本${NC}"
        exit 1
    fi
}

# 创建下载目录
create_download_dir() {
    if [ ! -d "$DOWNLOAD_DIR" ]; then
        mkdir -p "$DOWNLOAD_DIR"
        echo -e "${GREEN}📁 创建下载目录: $DOWNLOAD_DIR${NC}"
    fi
}

# 验证TikTok链接
validate_tiktok_url() {
    local url="$1"
    
    # 检查是否包含tiktok相关域名
    if [[ "$url" =~ (tiktok\.com|vm\.tiktok\.com|vt\.tiktok\.com) ]]; then
        return 0
    else
        return 1
    fi
}

# 下载视频
download_video() {
    local url="$1"
    
    # 确保下载目录存在
    create_download_dir
    
    echo -e "${BLUE}正在下载: ${url}${NC}"
    echo -e "${BLUE}保存位置: ${DOWNLOAD_DIR}/${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 使用yt-dlp下载到指定目录
    if python3 -m yt_dlp -o "${DOWNLOAD_DIR}/%(title)s [%(id)s].%(ext)s" "$url"; then
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ 下载成功！文件保存在 ${DOWNLOAD_DIR}/ 目录中${NC}"
        return 0
    else
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ 下载失败！${NC}"
        return 1
    fi
}

# 列出已下载的文件
list_downloaded_files() {
    echo -e "${YELLOW}已下载的视频文件 (${DOWNLOAD_DIR}/)：${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 检查下载目录是否存在
    if [ ! -d "$DOWNLOAD_DIR" ]; then
        echo -e "${YELLOW}  下载目录不存在，暂无已下载的视频文件${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        return
    fi
    
    # 查找下载目录中的mp4文件
    local mp4_files=("$DOWNLOAD_DIR"/*.mp4)
    if [ ${#mp4_files[@]} -gt 0 ] && [ -f "${mp4_files[0]}" ]; then
        for file in "${mp4_files[@]}"; do
            if [ -f "$file" ]; then
                local filename=$(basename "$file")
                local size=$(ls -lh "$file" | awk '{print $5}')
                local date=$(ls -l "$file" | awk '{print $6, $7, $8}')
                echo -e "  📹 ${filename}"
                echo -e "     📊 大小: ${size}  📅 时间: ${date}"
                echo ""
            fi
        done
        
        # 显示文件总数和目录大小
        local file_count=$(ls -1 "$DOWNLOAD_DIR"/*.mp4 2>/dev/null | wc -l)
        local dir_size=$(du -sh "$DOWNLOAD_DIR" 2>/dev/null | awk '{print $1}')
        echo -e "${GREEN}📊 总计: ${file_count} 个文件，占用空间: ${dir_size}${NC}"
    else
        echo -e "${YELLOW}  暂无已下载的视频文件${NC}"
    fi
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 主循环
main_loop() {
    while true; do
        echo ""
        echo -e "${YELLOW}请输入 TikTok 视频链接 (输入 'h' 查看帮助，'q' 退出):${NC}"
        read -p "🔗 " user_input
        
        # 处理用户输入
        case "$user_input" in
            "q"|"quit"|"exit")
                echo -e "${GREEN}感谢使用！再见！${NC}"
                exit 0
                ;;
            "h"|"help")
                echo ""
                show_help
                ;;
            "c"|"clear")
                show_welcome
                show_help
                ;;
            "l"|"list")
                echo ""
                list_downloaded_files
                ;;
            "")
                echo -e "${YELLOW}⚠️  请输入有效的链接${NC}"
                ;;
            *)
                # 验证链接
                if validate_tiktok_url "$user_input"; then
                    echo ""
                    download_video "$user_input"
                else
                    echo -e "${RED}❌ 无效的 TikTok 链接格式${NC}"
                    echo -e "${YELLOW}提示: 链接应包含 tiktok.com, vm.tiktok.com 或 vt.tiktok.com${NC}"
                fi
                ;;
        esac
    done
}

# 主函数
main() {
    # 检查依赖
    check_dependencies
    
    # 创建下载目录
    create_download_dir
    
    # 显示欢迎界面
    show_welcome
    show_help
    
    # 进入主循环
    main_loop
}

# 信号处理 - 优雅退出
trap 'echo -e "\n${GREEN}感谢使用！再见！${NC}"; exit 0' INT

# 运行主函数
main "$@" 