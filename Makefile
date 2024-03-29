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
	@mkdir -p /app/docker-skinnywms
	@git clone https://github.com/EduardRosert/docker-skinnywms.git /app/docker-skinnywms/
	@echo "from skinnywms.wmssvr import application">/app/docker-skinnywms/demo.py
	@echo "application.run(debug=True, threaded=False, host='0.0.0.0',port=80)">>/app/docker-skinnywms/demo.py
	@mkdir -p /app/docker-dwd-open-data-downloader
	@git clone https://github.com/EduardRosert/docker-dwd-open-data-downloader /app/docker-dwd-open-data-downloader
	@mkdir -p /app/data
	@$(PYTHON) /app/docker-dwd-open-data-downloader/opendata-downloader.py --model icon-eu --single-level-fields t_2m tmax_2m clch pmsl --max-time-step 6 --directory /app/data -v

run-application:
	@ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{print "Skinnywms running on http://"$$2":80"}'
	@sh -c "$(CONDA) init bash; export MAGPLUS_HOME=/opt/miniconda3; $(PYTHON) /app/docker-skinnywms/demo.py --host='0.0.0.0' --port=80 --path /app/data >/dev/null 2>&1 &"
	@echo ""
	@ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{print "Skinnywms running in background. Visit: http://"$$2":80"}'