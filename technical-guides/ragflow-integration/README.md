# RAGFlow集成技术指南

**来源项目**: 公司知识库-资料上传入口
**提取日期**: 2026年1月9日
**知识类型**: 技术集成经验

---

## 📋 概述

本文档总结了RAGFlow API集成的核心经验，包括配置、认证、API使用和常见问题解决方案。

---

## 🔧 核心经验

### 1. API配置

#### RAGFlow API地址

- **内网访问**（推荐）：`http://192.168.13.44/api`
- **公网访问**：`https://ragflow.suuntoyun.com/api`
- **配置位置**：`.env` 文件中的 `RAGFLOW_API_BASE`

#### 认证方式

- **方式**：Bearer Token 认证
- **配置位置**：`.env` 文件中的 `RAGFLOW_API_TOKEN`
- **获取方式**：
  1. 通过 RAGFlow Web 界面的登录接口获取 Token
  2. 或使用登录 API：
     ```bash
     curl -X POST "http://192.168.13.44/api/v1/login" \
       -H "Content-Type: application/json" \
       -d '{"username": "your_username", "password": "your_password"}'
     ```

#### 知识库映射

- **映射方式**：分类名称 → 知识库 ID
- **配置文件**：`config/kb_mapping.json`（可选，有默认映射）
- **支持的分类**：
  - 制度流程 → `kb_policy`
  - 产品方案 → `kb_product`
  - 项目案例 → `kb_project`
  - 技术资料 → `kb_tech`
  - 运维支持 → `kb_ops`
  - 合同管理 → `kb_contract`
  - 投标事业部 → `kb_bid`

---

### 2. API接口使用

#### 核心API端点

1. **上传文档**
   ```
   POST /api/v1/datasets/{knowledge_base_id}/documents
   ```

2. **获取知识库列表**
   ```
   GET /api/v1/datasets
   ```

3. **查询文档状态**
   ```
   GET /api/v1/datasets/{knowledge_base_id}/documents/{document_id}
   ```

#### 使用示例

**上传文档**:
```python
POST /api/ragflow/upload
{
    "file_path": "/mnt/data/ragflow-upload/uploads/2025/11/29/document.pdf",
    "category": "制度流程",  # 自动映射到 kb_policy
    "document_name": "制度流程-入职SOP-v3.pdf",
    "tags": ["人事制度", "v3", "内部"],
    "parser_id": "naive",
    "chunk_method": "naive"
}
```

**获取知识库列表**:
```python
GET /api/ragflow/knowledge-bases
```

---

## ⚠️ 常见问题

### 问题1: Token获取和刷新

**问题描述**:
- Token 可能有时效性，需要定期更新
- 手动获取Token不方便

**解决方案**:
- 实现 Token 自动刷新机制
- 缓存Token，定期检查有效性
- 失效时自动重新获取

**最佳实践**:
```python
class RAGFlowClient:
    def __init__(self):
        self.token = None
        self.token_expiry = None

    def get_token(self):
        if self.token and self.is_token_valid():
            return self.token
        return self.refresh_token()

    def refresh_token(self):
        # 调用登录API获取新Token
        response = requests.post(f"{self.api_base}/v1/login", ...)
        self.token = response.json()["token"]
        self.token_expiry = time.time() + 3600  # 假设1小时有效期
        return self.token
```

---

### 问题2: 知识库ID映射

**问题描述**:
- 文档中的知识库 ID（如 `kb_policy`）是示例
- 需要根据实际创建的知识库更新映射表

**解决方案**:
1. 通过 `GET /api/ragflow/knowledge-bases` 获取实际的知识库 ID
2. 更新 `config/kb_mapping.json` 文件
3. 实现动态映射机制

**最佳实践**:
```python
class KBMapping:
    def __init__(self):
        self.mapping = self.load_mapping()
        self.ragflow_client = RAGFlowClient()

    def get_kb_id(self, category):
        # 先从配置文件读取
        if category in self.mapping:
            return self.mapping[category]

        # 如果不存在，从RAGFlow获取
        kb_list = self.ragflow_client.get_knowledge_bases()
        # 根据名称匹配
        for kb in kb_list:
            if kb["name"] == category:
                return kb["id"]

        raise ValueError(f"未找到分类 {category} 对应的知识库")
```

---

### 问题3: 文件路径问题

**问题描述**:
- 上传的文件路径必须是服务器上的绝对路径
- 确保文件存在且有读取权限

**解决方案**:
- 使用绝对路径
- 验证文件存在性和权限
- 提供清晰的错误提示

**最佳实践**:
```python
def validate_file_path(file_path):
    if not os.path.isabs(file_path):
        raise ValueError("文件路径必须是绝对路径")

    if not os.path.exists(file_path):
        raise FileNotFoundError(f"文件不存在: {file_path}")

    if not os.access(file_path, os.R_OK):
        raise PermissionError(f"文件无读取权限: {file_path}")

    return True
```

---

### 问题4: API路径版本差异

**问题描述**:
- RAGFlow API 路径可能因版本而异
- 如果遇到 404 错误，需要检查实际的 API 路径

**解决方案**:
- 先用 Postman 或 curl 测试 API
- 记录实际的API路径
- 实现API版本检测机制

---

## 🎯 最佳实践

### 1. 错误处理和重试

```python
def upload_with_retry(file_path, category, max_retries=3):
    for attempt in range(max_retries):
        try:
            return upload_to_ragflow(file_path, category)
        except requests.exceptions.RequestException as e:
            if attempt == max_retries - 1:
                raise
            time.sleep(2 ** attempt)  # 指数退避
```

### 2. 轮询文档解析状态

```python
def wait_for_parsing(document_id, kb_id, timeout=300):
    start_time = time.time()
    while time.time() - start_time < timeout:
        status = get_document_status(document_id, kb_id)
        if status == "parsed":
            return True
        elif status == "failed":
            raise Exception("文档解析失败")
        time.sleep(5)  # 每5秒检查一次

    raise TimeoutError("文档解析超时")
```

### 3. 日志记录

```python
import logging

logger = logging.getLogger(__name__)

def upload_document(file_path, category):
    logger.info(f"开始上传文档: {file_path}, 分类: {category}")
    try:
        result = upload_to_ragflow(file_path, category)
        logger.info(f"上传成功: {result['document_id']}")
        return result
    except Exception as e:
        logger.error(f"上传失败: {e}", exc_info=True)
        raise
```

---

## 📚 相关资源

- **来源项目**: `01-projects/active/公司知识库-资料上传入口/`
- **迁移时间**: 2026年1月9日
- **参考文档**:
  - `RAGFlow集成完成说明.md` - 完整集成说明
  - `项目架构设计.md` - 架构设计文档
  - `README.md` - 项目使用说明

---

## 🔗 项目关联

- **来源项目**: `01-projects/active/公司知识库-资料上传入口/`
- **迁移时间**: 2026年1月9日
- **更多细节**: 查看完整项目

---

**最后更新**: 2026年1月9日
**维护者**: DevOps团队
