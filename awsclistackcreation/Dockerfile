FROM ubuntu:18.04
RUN apt-get -y update
RUN apt-get -y install python3
RUN apt-get -y install python3-pip
RUN pip3 install flask
COPY getHost.py /
CMD [ "python3", "getHost.py" ]
