# ============================================================================
# STAGE 1: Builder - Install dependencies with build tools
# ============================================================================
FROM python:3.12-slim AS builder

# Install build dependencies needed for compiling Python packages
RUN apk add --no-cache \
    gcc \
    musl-dev \
    linux-headers \
    libffi-dev

# Set working directory
WORKDIR /build

# Copy requirements file
COPY requirements.txt .

# Install Python packages to a custom location
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ============================================================================
# STAGE 2: Runtime - Create minimal final image
# ============================================================================
FROM python:3.12-alpine

# Install only runtime dependencies (no build tools)
RUN apk add --no-cache libffi
RUN useradd -u 1000 -m appuser

# Set working directory
WORKDIR /app

# Copy installed packages from builder stage (excludes build tools)
COPY --from=builder /install /usr/local

# Copy application files
COPY app.py .

# Expose port 5000
EXPOSE 5000
USER appuser
# Run the app
CMD ["python", "app.py"]
