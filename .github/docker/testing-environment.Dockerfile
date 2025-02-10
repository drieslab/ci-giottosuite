FROM rocker/r-ver:4.4.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    pandoc \
    python3-pip \
    git \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libmagick++-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install CRAN packages
RUN R -e "install.packages(c(\
    'checkmate', \
    'colorRamp2', \
    'covr', \
    'cowplot', \
    'data.table', \
    'dbscan', \
    'deldir', \
    'devtools', \
    'exactextractr', \
    'future', \
    'future.apply', \
    'geometry', \
    'ggalluvial', \
    'ggdendro', \
    'ggforce', \
    'ggraph', \
    'ggplot2', \
    'ggrepel', \
    'gtools', \
    'htmlwidgets', \
    'igraph', \
    'jsonlite', \
    'lintr', \
    'knitr', \
    'lifecycle', \
    'magick', \
    'magrittr', \
    'Matrix', \
    'matrixStats', \
    'methods', \
    'networkD3', \
    'parallel', \
    'plotly', \
    'png', \
    'progressr', \
    'qs', \
    'R.utils', \
    'raster', \
    'rcmdcheck', \
    'RColorBrewer', \
    'reshape2', \
    'reticulate', \
    'remotes', \
    'rgl', \
    'rlang', \
    'rmarkdown', \
    'RTriangle', \
    'scales', \
    'scattermore', \
    'scatterpie', \
    'scran', \
    'Seurat', \
    'SeuratObject', \
    'sf', \
    'sp', \
    'stats', \
    'stars', \
    'testthat', \
    'tiff', \
    'uwot', \
    'viridis', \
    'viridisLite', \
    'xml2' \
    ))"

# Install Bioconductor packages
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager'); \
    BiocManager::install(c('Biobase', 'BiocParallel', 'BiocCheck', 'BiocStyle', 'BiocSingular', \
    'chihaya', 'ComplexHeatmap', 'DelayedArray', 'DelayedMatrixStats', 'HDF5Array', 'MatrixGenerics', 'rhdf5', \
    'S4Vectors', 'ScaledMatrix', 'SingleCellExperiment', 'sparseMatrixStats', 'SpatialExperiment', \
    'STexampleData', 'SummarizedExperiment'), ask=FALSE)"
    
# Install GitHub packages
RUN R -e "remotes::install_github('rspatial/terra')"

# Setup Python environment
ENV RETICULATE_MINICONDA_PATH=/opt/miniconda
RUN R -e "reticulate::install_miniconda()" && \
    R -e "reticulate::conda_create(envname = 'giotto_env', python_version = '3.10.2')" && \
    R -e "reticulate::conda_install(packages = c('scipy', 'pandas==1.5.1', 'networkx==2.8.8', \
    'python-igraph==0.10.2', 'leidenalg==0.9.0', 'scikit-learn==1.1.3'))" && \
    R -e "reticulate::conda_install(packages = c('python-louvain==0.16', 'smfishhmrf', \
    'session-info', 'scanpy', 'scrublet'), pip = TRUE)" && \
    R -e "system('/opt/miniconda/bin/conda clean -afy')" && \
    rm -rf /opt/miniconda/pkgs/*

# Set working directory
WORKDIR /package

# Default command
CMD ["R"]