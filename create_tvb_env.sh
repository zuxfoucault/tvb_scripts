#!/usr/bin/env zsh
# Modified based on Dockerfile-build
# conda env

# check environment variables
#echo $HOME
#echo $CONDA_PREFIX
USER_GIT=zuxfoucault
USER_HOME=/Volumes/SSD/Space/TVB
USER_SYSTEM_HOME=$HOME
CONDA_ENV=$CONDA_PREFIX/envs
TVB_STORAGE=$USER_HOME/TVB_STORAGE
NUMBA_CACHE=$USER_HOME/numba_cache
KEYCLOAK_CONFIG=$USER_HOME/keycloak_config
JUPYTER_CONFIG=$USER_HOME/.jupyter

conda update -n base -c defaults conda
conda create -y --name tvb-docs python=3.7 nomkl numba scipy numpy networkx scikit-learn cython pip numexpr psutil
conda install -y --name tvb-docs pytest pytest-cov pytest-benchmark pytest-mock matplotlib-base
conda install -y --name tvb-docs psycopg2 pytables scikit-image==0.14.2 simplejson cherrypy docutils werkzeug==0.16.1
conda install -y --name tvb-docs -c conda-forge jupyterlab flask gevent
$CONDA_ENV/tvb-docs/bin/pip install --upgrade pip
# Latest functioning pair compatible tested for sqlalchemy==1.3.20 sqlalchemy-migrate==0.13.0
$CONDA_ENV/tvb-docs/bin/pip install h5py formencode cfflib jinja2 nibabel sqlalchemy sqlalchemy-migrate allensdk
$CONDA_ENV/tvb-docs/bin/pip install tvb-gdist typing BeautifulSoup4 subprocess32 flask-restplus python-keycloak mako pyAesCrypt pyunicore
$CONDA_ENV/tvb-docs/bin/pip install sphinx==1.2.3 docutils==0.12

conda update -n base -c defaults conda
conda create -y --name tvb-run python=3 nomkl numba scipy numpy networkx scikit-learn cython pip numexpr psutil
conda install -y --name tvb-run pytest pytest-cov pytest-benchmark pytest-mock matplotlib-base
conda install -y --name tvb-run psycopg2 pytables scikit-image==0.14.2 simplejson cherrypy docutils werkzeug==0.16.1
conda install -y --name tvb-run -c conda-forge jupyterlab flask gevent
$CONDA_ENV/tvb-run/bin/pip install --upgrade pip
# Latest functioning pair compatible tested for sqlalchemy==1.3.20 sqlalchemy-migrate==0.13.0
$CONDA_ENV/tvb-run/bin/pip install h5py formencode cfflib jinja2 nibabel sqlalchemy sqlalchemy-migrate allensdk
$CONDA_ENV/tvb-run/bin/pip install tvb-gdist typing BeautifulSoup4 subprocess32 flask-restplus python-keycloak mako pyAesCrypt pyunicore

# Jupyther notebook configurations: set password
# tvb42
mkdir -p $JUPYTER_CONFIG #folder structure containing $USER_HOME
/usr/local/bin/zsh -c "source activate tvb-run"
$CONDA_ENV/tvb-run/bin/jupyter notebook --generate-config
cp /Users/zuxfoucault/.jupyter/jupyter_notebook_config.py $JUPYTER_CONFIG/jupyter_notebook_config.py
echo "c.NotebookApp.password='sha1:12bff019c253:9daecd92c2e9bdb10b3b8a06767a74a0fe078d7c'">>$JUPYTER_CONFIG/jupyter_notebook_config.py

pushd $USER_HOME
wget "https://zenodo.org/record/3688773/files/tvb-data.zip?download=1" -O tvb_data.zip
mkdir tvb_data; unzip tvb_data.zip -d tvb_data; rm tvb_data.zip;
pushd tvb_data
$CONDA_ENV/tvb-run/bin/python setup.py develop
$CONDA_ENV/tvb-docs/bin/python setup.py develop
popd

# clone user's fork
git clone --depth 1 https://github.com/$USER_GIT/tvb-root.git
#git remote add upstream https://github.com/the-virtual-brain/tvb-root.git
#git fetch --all

pushd tvb-root
cd framework_tvb
$CONDA_ENV/tvb-run/bin/python setup.py develop --no-deps
$CONDA_ENV/tvb-docs/bin/python setup.py develop --no-deps
cd ../scientific_library
$CONDA_ENV/tvb-run/bin/python setup.py develop
$CONDA_ENV/tvb-docs/bin/python setup.py develop
cd ../tvb_contrib
$CONDA_ENV/tvb-run/bin/python setup.py develop --no-deps
$CONDA_ENV/tvb-docs/bin/python setup.py develop --no-deps
cd ../tvb_bin
$CONDA_ENV/tvb-run/bin/python setup.py develop
$CONDA_ENV/tvb-docs/bin/python setup.py develop
cd ../tvb_build
$CONDA_ENV/tvb-run/bin/python setup.py develop --no-deps
$CONDA_ENV/tvb-docs/bin/python setup.py develop --no-deps
cd ..

# customize .tvb.configuration after copy
#cp tvb_buil/docker/.tvb.configuration $USER_SYSTEM_HOME/.tvb.configuration
popd
mkdir $USER_HOME/.tvb-temp; mkdir $USER_HOME/.tvb-temp/logs; mkdir -m777 $TVB_STORAGE $NUMBA_CACHE $KEYCLOAK_CONFIG

# original dockerfile
#ENV TVB_USER_HOME $USER_HOME
#ENV NUMBA_CACHE_DIR $NUMBA_CACHE
#
#WORKDIR $USER_HOME/tvb-root
## MOUNT -v [local- tvb-root - clone]:$USER_HOME/tvb-root
#
## For building static help for web
##CMD ["bash","-c","source activate tvb-docs && cd tvb_build && python build_step1.py"]
#
## For building the Pypi packages
##CMD ["bash","-c","source activate tvb-run && cd tvb_build && bash package_for_pip.sh"]
#
## For running all unit-tests
## inspect output in local tvb-root/tvb_bin/TEST_OUTPUT folder
##CMD ["bash","-c","source activate tvb-run && cd tvb_bin && service postgresql start && bash run_tests.sh postgres"]
#
## For running Jupyter notebooks
## bind port 8888:8888
##CMD ["bash","-c","source activate tvb-run && cd tvb_documentation && jupyter notebook --ip 0.0.0.0 --no-browser --allow-root"]
#
## For running TVB Web GUI
## bind port 8080
## MOUNT -v [local- ~/TVB ]:$TVB_STORAGE
#
#CMD ["bash","-c","source activate tvb-run && /bin/bash"]
