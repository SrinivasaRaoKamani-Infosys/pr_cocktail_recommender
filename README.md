
This project deploys a **Frontend** (static HTML/JS) and a **Backend** (Flask Python) into **Azure Container Apps**, using:

- **Terraform** (Infrastructure as Code)
- **GitHub Actions** CI/CD
- **Azure Container Registry (ACR)**
- **User‑Assigned Managed Identity (UAMI)** for image pulls
- **Remote Terraform State** stored in Azure Blob Storage


---

## 🚀 Architecture
```text
GitHub Actions → Build & Push Docker Images → ACR
Terraform (Phase 1) → Resource Group, ACR, Log Analytics, Env, UAMI, AcrPull
Enable ACR authentication-as-arm
Terraform (Phase 2) → Deploy Container Apps (Frontend + Backend)
Container Apps pull images from ACR via UAMI
```

### Deployed Components
- Azure Resource Group  
- Azure Container Registry  
- Log Analytics Workspace  
- Container Apps Environment  
- User‑Assigned Managed Identity  
- Role Assignment: **AcrPull → UAMI**  
- Frontend Container App (port 80)  
- Backend Container App (port 5000)

---

---

## 🔐 GitHub Secrets
Prerequistite :
In Azure Portal

App registration > Secret creation > role assignment to SPN
Stoarge account > block container


Set in **Settings → Secrets → Actions**:

| Secret | Description |
|-------|-------------|
| `AZURE_CREDENTIALS` | JSON for `azure/login@v1` |
| `AZURE_CLIENT_ID` | SP clientId |
| `AZURE_CLIENT_SECRET` | SP clientSecret |
| `AZURE_SUBSCRIPTION_ID` | Subscription ID |
| `AZURE_TENANT_ID` | Tenant ID |
| `ACR_LOGIN_SERVER` | e.g. `myregistry.azurecr.io` |

---

## 🔧 GitHub Variables

Set in **Settings → Variables**:

| Variable | Example |
|---------|---------|
| `LOCATION` | southindia |
| `RESOURCE_GROUP` | rg-containerapps-demo |
| `ACR_NAME` | myregistry |
| `TFSTATE_RG` | rg-storageaccounts-si |
| `TFSTATE_STORAGE_ACCOUNT` | tfstatecocktaildemo |
| `TFSTATE_CONTAINER` | tfstate |
| `TFSTATE_KEY` | containerapps.tfstate |

---

## 🧩 CI/CD Pipeline (deploy.yml)

The workflow performs:

### **Phase 1 – Infrastructure**
- Terraform init with Azure Blob backend  
- Create RG, ACR, Log Analytics Workspace  
- Create Container Apps Environment  
- Create User‑Assigned Managed Identity  
- Assign **AcrPull** to UAMI  
- Enable ACR **authentication‑as‑ARM** (required for MI pulls)

### **Image Build & Push**
- Build frontend & backend images  
- Push to ACR

### **Phase 2 – Container Apps**
- Deploy frontend + backend apps using Terraform  
- Apps reference images from ACR using UAMI

---
## 🌐 Application Endpoints

After deployment, Terraform outputs:

- **Frontend URL**  
- **Backend URL**
