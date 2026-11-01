{ lib, pkgs, ... }:

{
  environment.sessionVariables.LD_LIBRARY_PATH = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
  ];

  environment.systemPackages = with pkgs; [
    (python3.withPackages (
      ps: with ps; [
        jupyterlab
        notebook
        ipykernel
        ipywidgets
        numpy
        matplotlib
        seaborn
        plotly
        pandas
        polars
        pyarrow
        scipy
        statsmodels
        debugpy
        pytest
        mypy
        build
        scikit-learn
        openpyxl
        xlrd
        requests
        duckdb
      ]
    ))
    uv
    poetry
    pyright
    ruff
    black
  ];
}
