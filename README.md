# Google Drive MCP Server

MCP server for Google Drive — search and read files from your Google Drive in Claude.

## Quick Start (Docker, no clone required)

### 1. Set up GCP credentials

Follow the [GCP Setup](#gcp-setup) section below, then place the downloaded JSON file here:

```sh
mkdir -p ~/.config/gdrive-mcp
cp ~/Downloads/client_secret_*.json ~/.config/gdrive-mcp/gcp-oauth.keys.json
```

### 2. Authenticate

```sh
docker compose \
  --profile auth \
  -f git@github.com:pmunin/gdrive-mcp-server.git \
  run --rm -p 4242:4242 gdrive-mcp-auth
```

Open the URL printed in the terminal, approve access in your browser, and wait for "Credentials saved."

### 3. Add to Claude config

In `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "gdrive": {
      "command": "docker",
      "args": [
        "compose",
        "-f", "git@github.com:pmunin/gdrive-mcp-server.git",
        "run", "--rm", "-i", "gdrive-mcp"
      ],
      "env": {
        "GCP_CREDENTIALS_PATH": "/Users/YOUR_USERNAME/.config/gdrive-mcp"
      }
    }
  }
}
```

Replace `YOUR_USERNAME` with your macOS username (`echo $USER`).

Restart Claude — the `gdrive_search` and `gdrive_read_file` tools will be available.

---

## Re-authentication

If your token expires, run auth again (no need to touch Claude config):

```sh
docker compose \
  --profile auth \
  -f git@github.com:pmunin/gdrive-mcp-server.git \
  run --rm -p 4242:4242 gdrive-mcp-auth
```

---

## GCP Setup

<details>
<summary>Step-by-step Google Cloud setup</summary>

### 1. Create a Google Cloud Project

- Go to [console.cloud.google.com/projectcreate](https://console.cloud.google.com/projectcreate)
- Enter a name (e.g. "MCP GDrive Server") and click **Create**

### 2. Enable the Google Drive API

- Go to [APIs & Services → Library](https://console.cloud.google.com/apis/library)
- Search for **Google Drive API** and click **Enable**

### 3. Configure OAuth Consent Screen

- Go to [APIs & Services → OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent)
- Choose **External** (or Internal if Google Workspace)
- Fill in app name, support email, developer email → **Save and Continue**
- Add scope: `https://www.googleapis.com/auth/drive.readonly` → **Save and Continue**
- Add your Google account as a test user → **Save and Continue**

### 4. Create OAuth Client ID

- Go to [APIs & Services → Credentials](https://console.cloud.google.com/apis/credentials)
- Click **Create Credentials → OAuth client ID**
- Application type: **Desktop app**
- Name it and click **Create**
- Click **Download JSON** and save the file

### 5. Add redirect URI

- Edit the OAuth client you just created
- Under **Authorized redirect URIs**, add: `http://localhost:4242`
- Click **Save**

</details>

---

## Tools

| Tool | Description |
|------|-------------|
| `gdrive_search` | Full-text search across your Google Drive |
| `gdrive_read_file` | Read a file by its Google Drive file ID |

### Supported formats

| Google format | Exported as |
|---------------|-------------|
| Google Docs | Markdown |
| Google Sheets | CSV |
| Google Slides | Plain text |
| Google Drawings | PNG |
| Text / JSON | UTF-8 |
| Everything else | Base64 |

---

## Local Development

```sh
git clone git@github.com:pmunin/gdrive-mcp-server.git
cd gdrive-mcp-server
npm install && npm run build

# Auth
node dist/index.js auth

# Run
node dist/index.js
```

---

## License

MIT — see [LICENSE](LICENSE)
