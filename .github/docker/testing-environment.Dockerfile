FROM rocker/r-ver:4.4.2

# Install system dependencies and clean up
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libglpk-dev \
    pandoc \
    python3-pip \
    git \
    libudunits2-dev \
    libsqlite3-dev \
    libgdal-dev \
    gdal-bin \
    libgeos-dev \
    libproj-dev \
    libnetcdf-dev \
    libtiff5-dev \
    libwebp-dev \
    libmagick++-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install CRAN packages, Bioconductor packages, and GitHub packages and clean up
RUN R -e "install.packages(c( \
    'checkmate', \
    'colorRamp2', \
    'covr', \
    'cowplot', \
    'data.table', \
    'dbscan', \
    'deldir', \
    'devtools', \
    'exactextractr', \
    'FNN', \
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
    'spdep', \
    'stats', \
    'stars', \
    'terra', \
    'testthat', \
    'tiff', \
    'uwot', \
    'viridis', \
    'viridisLite', \
    'xml2' \
    ))" && \
    R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager'); \
    BiocManager::install(c( \
    'Biobase', \
    'BiocParallel', \
    'BiocCheck', \
    'BiocStyle', \
    'BiocSingular', \
    'chihaya', \
    'ComplexHeatmap', \
    'DelayedArray', \
    'DelayedMatrixStats', \
    'HDF5Array', \
    'MatrixGenerics', \
    'rhdf5', \
    'S4Vectors', \
    'ScaledMatrix', \
    'SingleCellExperiment', \
    'sparseMatrixStats', \
    'SpatialExperiment', \
    'STexampleData', \
    'SummarizedExperiment' \
    ), ask=FALSE)" && \
    rm -rf /tmp/downloaded_packages/

# Setup Python environment and clean up
ENV RETICULATE_MINICONDA_PATH=/opt/miniconda
RUN R -e "reticulate::install_miniconda()" && \
    R -e "reticulate::conda_create(envname = 'giotto_env', python_version = '3.10.2')" && \
    R -e "reticulate::conda_install(packages = 'scipy', envname = 'r-reticulate')" && \
    R -e "reticulate::conda_install(packages = c( \
    'scipy', \
    'pandas==1.5.1', \
    'networkx==2.8.8', \
    'python-igraph==0.10.2', \
    'leidenalg==0.9.0', \
    'scikit-learn==1.1.3' \
    ), envname = 'giotto_env')" && \
    R -e "reticulate::conda_install(packages = c( \
    'python-louvain==0.16', \
    'smfishhmrf', \
    'session-info', \
    'scanpy', \
    'scrublet' \
    ), envname = 'giotto_env', pip = TRUE)" && \
    R -e "system('/opt/miniconda/bin/conda clean -afy')" && \
    rm -rf /opt/miniconda/pkgs/*

WORKDIR /package
CMD ["R"]