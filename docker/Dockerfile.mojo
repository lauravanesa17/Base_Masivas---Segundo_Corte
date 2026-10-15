FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir uv \
    && python3 -m venv /opt/mojo-venv \
    && (uv pip install --python /opt/mojo-venv/bin/python mojo \
        || uv pip install --python /opt/mojo-venv/bin/python mojo \
            --index https://whl.modular.com/nightly/simple/ \
            --prerelease allow)

ENV PATH="/opt/mojo-venv/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu"

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpython3.12 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
CMD ["mojo", "--version"]
