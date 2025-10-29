# Containerize an MCP Server

Containerize the [Weather MCP server](../server/weather/) that was built in [Build an MCP server](01-build_an_mcp_server.md) tutorial.

# Dockerfile

A docker file has been created in Weather app's [directory](../server/weather/) with the following contents.

```dockerfile
# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
# Prevents Python from writing pyc files
ENV PYTHONDONTWRITEBYTECODE=1
# Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1

# Install system dependencies if needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv (fast Python package installer)
RUN pip install --no-cache-dir uv

# Copy dependency files
COPY pyproject.toml uv.lock* ./

# Copy application code
COPY weather.py .

# Sync dependencies using uv
RUN uv sync --frozen

# Create a non-root user for security
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Set the entrypoint to run the weather server using uv
ENTRYPOINT ["uv", "run", "weather.py"]
```

Build the image and test the container.

```shell
docker build -t weather-mcp-server .
```

```shell
docker run -i weather-mcp-server
```

# Modify Claude Desktop config

Edit the Claude desktop config. Located at `~/Library/Application Support/Claude/claude_desktop_config.json` on a Mac.

```json
{
  "mcpServers": {
    "weather": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "weather-mcp-server:latest"]
    }
  }
}
```

Restart Claude and use the following commands to test the server.

- What’s the weather in Sacramento?
- What are the active weather alerts in Texas?
