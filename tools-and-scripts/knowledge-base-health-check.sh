#!/bin/bash
# 知识库健康检查脚本
# 用途: 检查知识库的健康状态

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置变量
KB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/03-knowledge-base"
REPORT_FILE="${KB_ROOT}/health-check-report-$(date +%Y%m%d-%H%M%S).md"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# 检查文档完整性
check_document_completeness() {
    log_section "检查文档完整性"

    cd "$KB_ROOT"

    # 检查失败案例
    FAILURE_CASES=$(find failure-cases -mindepth 1 -maxdepth 1 -type d)
    for case in $FAILURE_CASES; do
        case_name=$(basename "$case")
        log_info "检查案例: $case_name"

        # 检查必需文档
        required_files=("01-案例摘要.md" "02-详细分析.md" "03-决策复盘.md" "04-技术债务清单.md" "05-预防措施.md")
        for file in "${required_files[@]}"; do
            if [ ! -f "$case/$file" ]; then
                log_warn "⚠️  缺少文件: $case/$file"
            else
                log_info "✅ 存在: $case/$file"
            fi
        done
    done
}

# 检查链接有效性
check_links() {
    log_section "检查链接有效性"

    cd "$KB_ROOT"

    # 检查Markdown文件中的内部链接
    find . -name "*.md" -type f | while read file; do
        # 检查相对路径链接
        grep -o '\[.*\](\.\./.*\.md)' "$file" 2>/dev/null | while read link; do
            link_path=$(echo "$link" | sed 's/.*(\(.*\))/\1/')
            if [ ! -f "$(dirname "$file")/$link_path" ]; then
                log_warn "⚠️  失效链接: $file -> $link_path"
            fi
        done
    done
}

# 统计知识库
generate_stats() {
    log_section "生成知识库统计"

    cd "$KB_ROOT"

    FAILURE_CASES=$(find failure-cases -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
    SUCCESS_CASES=$(find success-cases -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    ANTI_PATTERNS=$(find patterns/anti-patterns -name "*.md" -type f | wc -l | tr -d ' ')
    BEST_PRACTICES=$(find patterns/best-practices -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    FRAMEWORKS=$(find decision-frameworks -name "*.md" -type f | wc -l | tr -d ' ')
    TOTAL_DOCS=$(find . -name "*.md" -type f | wc -l | tr -d ' ')

    log_info "失败案例: $FAILURE_CASES"
    log_info "成功案例: $SUCCESS_CASES"
    log_info "反模式: $ANTI_PATTERNS"
    log_info "最佳实践: $BEST_PRACTICES"
    log_info "决策框架: $FRAMEWORKS"
    log_info "总文档数: $TOTAL_DOCS"
}

# 生成报告
generate_report() {
    log_section "生成健康检查报告"

    cat > "$REPORT_FILE" << EOF
# 知识库健康检查报告

**检查日期**: $(date)
**知识库位置**: $KB_ROOT

## 检查结果

### 文档完整性

[检查结果]

### 链接有效性

[检查结果]

### 知识库统计

- 失败案例: [数量]
- 成功案例: [数量]
- 反模式: [数量]
- 最佳实践: [数量]
- 决策框架: [数量]
- 总文档数: [数量]

## 建议

[改进建议]

---

**报告生成时间**: $(date)
EOF

    log_info "健康检查报告已生成: $REPORT_FILE"
}

# 主函数
main() {
    log_section "开始知识库健康检查"

    check_document_completeness
    check_links
    generate_stats
    generate_report

    log_section "健康检查完成"
    log_info "报告位置: $REPORT_FILE"
}

# 执行主函数
main
