default: install-conda install-libmesa install-skinnywms fetch-data run-application

CONDA :=/opt/miniconda3/bin/conda
PYTHON :=/opt/miniconda3/bin/python3

install-conda:
	@echo "Installing Conda ..."
	@wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
	@chmod +x Miniconda3-latest-Linux-x86_64.sh
	@./Miniconda3-latest-Linux-x86_64.sh -u -b -p /opt/miniconda3


install-libmesa:
	@echo "Installing libGL ..."
	@yum install mesa-libGL -y

install-skinnywms:
	@echo "Installing Skinnywms Demo ..."
	@$(CONDA) install -c conda-forge skinnywms=0.2.1 -y

fetch-data:
	@echo "Downloading demo application..."
	@echo git clone https://github.com/EduardRosert/docker-skinnywms.git
	@echo "from skinnywms.wmssvr import application">./docker-skinnywms/demo.py
	@echo "application.run(debug=True, threaded=False, host='0.0.0.0',port=443)">>./docker-skinnywms/demo.py
	@echo git clone https://github.com/EduardRosert/docker-dwd-open-data-downloader
	@$(PYTHON) ./docker-dwd-open-data-downloader/opendata-downloader.py --model icon-eu --single-level-fields t_2m tmax_2m clch pmsl --max-time-step 6 --directory /tmp/ -v

run-application:
	@ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{print "Skinnywms running on http://"$$2":443"}'
	@sh -c "$(CONDA) init bash; export MAGPLUS_HOME=/opt/miniconda3; $(PYTHON) ./docker-skinnywms/demo.py --host='0.0.0.0' --port=443 --path /tmp/ >/dev/null 2>&1 &"
	@echo ""
	@ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{print "Skinnywms running in background. Visit: http://"$$2":443"}'