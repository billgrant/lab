# Terraform MCP Server Example

## Docs

- https://developer.hashicorp.com/terraform/mcp-server
- https://developer.hashicorp.com/terraform/mcp-server/deploy

Claude Desktop configuration.

`claude_desktop_config.json`

```json
{
  "mcpServers": {
    "terraform": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "TFE_ADDRESS=<<PASTE_TFE_ADDRESS_HERE>>",
        "-e",
        "TFE_TOKEN=<<PASTE_TFE_TOKEN_HERE>>",
        "hashicorp/terraform-mcp-server:0.3.0"
      ]
    }
  }
}
```
