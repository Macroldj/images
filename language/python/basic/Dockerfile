FROM python:3.6-slim

WORKDIR /home/workspace

ADD requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir  -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com -r /tmp/requirements.txt && rm -rf /tmp/requirements.txt

COPY . .

CMD ["python3","main.py"]