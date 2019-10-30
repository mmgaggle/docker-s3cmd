FROM alpine:3.3

RUN apk update
RUN apk add python py-pip py-setuptools git ca-certificates
RUN pip install python-dateutil

RUN git clone https://github.com/s3tools/s3cmd.git /tmp/s3cmd
RUN ln -s /tmp/s3cmd/s3cmd /usr/bin/s3cmd

WORKDIR /tmp

ADD ./files/s3cfg /tmp/.s3cfg
ADD ./files/main.sh /tmp/main.sh

# Main entrypoint script
RUN chmod 777 /tmp/main.sh .

# Folders for s3cmd optionations
RUN mkdir /tmp/src
RUN mkdir /tmp/dest

WORKDIR /
CMD ["/tmp/main.sh"]
