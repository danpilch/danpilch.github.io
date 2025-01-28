FROM ubuntu:24.04

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    pandoc \
    texlive-xetex \
    lmodern \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

CMD ["xelatex", "danpilch_resume.tex"]
