FROM ubuntu

RUN apt-get update
RUN apt-get install -y python3 python3-pip
RUN python3 -m pip config set global.break-system-packages true
RUN pip3 install flask

COPY app.py /opt/app.py

ENTRYPOINT FLASK_APP=/opt/app.py flask run --host=0.0.0.0
