FROM python:3.10-slim

# Install system utilities and data-slicing engines
RUN apt-get update && apt-get install -y \
    tmux \
    mc \
    libcom-err2 \
    libcom-dev \
    vim \
    nano \
    netcat-traditional \
    make \
    gcc \
    par2 \
    && rm -rf /var/lib/apt/lists/*

# Set up the RAM-disk simulation folders
RUN mkdir -p /tmp/kerbtap-spool /tmp/nntpfusemount /root/workspace
WORKDIR /root/workspace

# Configure Vim for Python Development
RUN echo "syntax on\nset tabstop=4\nset expandtab\nset shiftwidth=4\nset autoindent\nset number" > /root/.vimrc

# Install python requirements via the setup.py we will mount
# (Will be executed at runtime or you can run `pip install -e .` inside)
RUN pip install --no-cache-dir textual python-dotenv Nuitka dateparser

# Copy entrypoint and Welcome Message
COPY motd /etc/
COPY mount.nntp /sbin/
COPY nntpfuse.py /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /sbin/mount.nntp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
