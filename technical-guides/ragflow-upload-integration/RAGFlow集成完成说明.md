# ✅ RAGFlow 集成完成说明

## 🎉 已完成的工作

基于你提供的 RAGFlow 配置文档，我已经完成了 RAGFlow 集成代码的完善。

---

## 📋 集成的配置信息

### 1. RAGFlow API 地址
- **内网访问**（推荐）：`http://192.168.13.44/api`
- **公网访问**：`https://ragflow.suuntoyun.com/api`
- **配置位置**：`.env` 文件中的 `RAGFLOW_API_BASE`

### 2. 认证方式
- **方式**：Bearer Token 认证
- **配置位置**：`.env` 文件中的 `RAGFLOW_API_TOKEN`
- **获取方式**：需要通过 RAGFlow Web 界面的登录接口获取 Token

### 3. 知识库映射
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

## 🔧 完善的代码

### 1. RAGFlow 客户端 (`app/services/ragflow_client.py`)

**功能**：
- ✅ 上传文档到 RAGFlow
- ✅ 获取知识库列表
- ✅ 查询文档状态
- ✅ 轮询文档解析状态（等待解析完成）

**API 接口**：
- `POST /api/v1/datasets/{knowledge_base_id}/documents` - 上传文档
- `GET /api/v1/datasets` - 获取知识库列表
- `GET /api/v1/datasets/{knowledge_base_id}/documents/{document_id}` - 查询文档状态

### 2. 知识库映射管理 (`app/utils/kb_mapping.py`)

**功能**：
- ✅ 根据分类名称自动映射到知识库 ID
- ✅ 支持配置文件动态更新
- ✅ 提供默认映射表

**使用方式**：
```python
from app.utils.kb_mapping import kb_mapping

# 获取知识库 ID
kb_id = kb_mapping.get_kb_id("制度流程")  # 返回 "kb_policy"

# 获取完整信息
kb_info = kb_mapping.get_kb_info("制度流程")
```

### 3. RAGFlow API 路由 (`app/api/ragflow/route.py`)

**功能**：
- ✅ 上传文件到 RAGFlow（根据分类自动映射知识库）
- ✅ 获取知识库列表

**API 端点**：
- `POST /api/ragflow/upload` - 上传文档
- `GET /api/ragflow/knowledge-bases` - 获取知识库列表

---

## 📝 配置步骤

### 1. 配置环境变量

编辑 `.env` 文件：

```bash
# RAGFlow 配置
RAGFLOW_API_BASE=http://192.168.13.44/api
RAGFLOW_API_TOKEN=your-ragflow-api-token  # 需要先获取 Token
RAGFLOW_TIMEOUT=300
```

### 2. 获取 RAGFlow API Token

**方法 1：通过 RAGFlow Web 界面**
1. 访问 `https://ragflow.suuntoyun.com`
2. 登录账号
3. 在浏览器开发者工具中查看登录请求的响应，获取 Token

**方法 2：通过登录 API**
```bash
curl -X POST "http://192.168.13.44/api/v1/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "your_username", "password": "your_password"}'
```

### 3. 配置知识库映射（可选）

如果需要自定义映射，复制示例文件：

```bash
cp config/kb_mapping.json.example config/kb_mapping.json
# 编辑 config/kb_mapping.json，更新实际的知识库 ID
```

---

## 🚀 使用示例

### 上传文档到 RAGFlow

```python
# 通过 API 上传
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

### 获取知识库列表

```python
# 通过 API 获取
GET /api/ragflow/knowledge-bases
```

---

## ⚠️ 注意事项

### 1. Token 获取
- **重要**：需要先获取 RAGFlow API Token
- Token 可能有时效性，需要定期更新
- 建议实现 Token 自动刷新机制

### 2. 知识库 ID
- 文档中的知识库 ID（如 `kb_policy`）是示例
- **需要根据实际创建的知识库更新映射表**
- 可以通过 `GET /api/ragflow/knowledge-bases` 获取实际的知识库 ID

### 3. 文件路径
- 上传的文件路径必须是服务器上的绝对路径
- 确保文件存在且有读取权限

### 4. API 路径
- RAGFlow API 路径可能因版本而异
- 如果遇到 404 错误，请检查实际的 API 路径
- 建议先用 Postman 或 curl 测试 API

---

## 🔍 测试建议

### 1. 测试知识库列表 API

```bash
curl -X GET "http://192.168.13.44/api/v1/datasets" \
  -H "Authorization: Bearer your_token"
```

### 2. 测试文档上传 API

```bash
curl -X POST "http://192.168.13.44/api/v1/datasets/kb_policy/documents" \
  -H "Authorization: Bearer your_token" \
  -F "file=@/path/to/document.pdf" \
  -F "name=test.pdf" \
  -F "parser_id=naive" \
  -F "chunk_method=naive"
```

### 3. 测试文档状态查询

```bash
curl -X GET "http://192.168.13.44/api/v1/datasets/kb_policy/documents/{document_id}" \
  -H "Authorization: Bearer your_token"
```

---

## 📚 相关文档

- `上传门户开发任务.md` - 完整的 RAGFlow API 文档和示例
- `RAGFlow发布和维护文档.md` - RAGFlow 部署和维护信息
- `RAGFlow知识库标准配置记录.md` - 知识库配置标准

---

## ✅ 下一步

1. **获取 RAGFlow API Token**
   - 通过 Web 界面或 API 获取 Token
   - 配置到 `.env` 文件

2. **更新知识库映射**
   - 调用 `GET /api/ragflow/knowledge-bases` 获取实际的知识库 ID
   - 更新 `config/kb_mapping.json` 文件

3. **测试集成**
   - 测试文件上传功能
   - 测试文档状态查询
   - 验证知识库映射是否正确

4. **完善功能**
   - 实现 Token 自动刷新
   - 添加错误处理和重试机制
   - 完善日志记录

---

**完成时间**：2025-11-29
**基于文档**：`上传门户开发任务.md`、`RAGFlow发布和维护文档.md`
