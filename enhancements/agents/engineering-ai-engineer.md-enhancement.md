# Agent Enhancement: AI Engineer

## Current State

**File**: `engineering/engineering-ai-engineer.md`
**Name**: `engineering-ai-engineer`
**Description**: `Expert AI/ML engineer specializing in machine learning model development, deployment, and integration into production systems. Focused on building intelligent features, data pipelines, and AI-powered applications with emphasis on practical, scalable solutions.`

## Proposed Changes

### Better Name
**Proposed**: `engineering-ai-ml-systems-engineer`
**Rationale**: Specifies both AI and ML expertise plus systems focus, distinguishing from research-focused AI roles.

### Better Description
**Proposed**: `Develops and deploys production ML systems including models, data pipelines, and AI-powered features. Implements LLM integrations, computer vision, NLP, and recommendation systems with focus on ethics, performance, and scalability. Use when building AI features, deploying ML models, or creating intelligent automation.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Implements ML models and AI features
- `/agency:plan` - Creates ML project roadmaps and architecture
- `/agency:optimize` - Optimizes model performance and inference speed
- `/agency:test` - Creates ML testing strategies and validates models
- `/agency:document` - Generates ML documentation and API specs
- `/agency:review` - Reviews ML code for bias, ethics, and best practices

## Enhancement Recommendations

### Capability Enhancements
- **Model registry integration**: MLflow, Weights & Biases for model versioning
- **Automated model retraining**: Drift detection and automated pipeline triggers
- **Feature store management**: Centralized feature engineering and serving
- **Model explainability**: SHAP, LIME for model interpretability
- **Edge deployment**: TensorFlow Lite, ONNX for mobile/edge inference
- **Vector database expertise**: Pinecone, Weaviate, Chroma for RAG systems
- **LLM fine-tuning**: LoRA, QLoRA for custom model adaptation
- **Prompt engineering**: Systematic prompt optimization for LLM integration

### Skill References
Should reference these workflow skills when available:
- `ai-5-expert` - For AI SDK integration patterns
- `fastmcp-2-expert` - For ML model serving via MCP
- `pixeltable-0-expert` - For ML data management
- `python-ml-frameworks` - For ML framework best practices
- `ml-ops-patterns` - For production ML deployment

### Tool Access
Current tools seem appropriate, but consider adding:
- **Model training tools**: Access to GPU resources and training infrastructure
- **Data analysis tools**: Pandas, NumPy for data exploration
- **Model serving tools**: FastAPI, TensorFlow Serving integration
- **Vector database tools**: Direct integration with vector stores
- **LLM API access**: OpenAI, Anthropic, Cohere API integration

### Quality Improvements
- Add specific model evaluation metrics for different problem types
- Include bias detection and fairness testing frameworks
- Provide ML project templates for common use cases (classification, regression, etc.)
- Add data versioning and reproducibility guidelines
- Include monitoring dashboards and alerting templates
- Provide cost optimization strategies for ML infrastructure
- Add examples of successful production ML architectures
- Include privacy-preserving ML techniques (differential privacy, federated learning)
- Provide model compression techniques (quantization, pruning, distillation)

## Implementation Priority
**Priority**: High
**Rationale**: AI/ML capabilities are increasingly critical for competitive products. Needs strong integration with data engineering and backend development agents. High demand skill set.
