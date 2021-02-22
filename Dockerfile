FROM lambci/lambda:python3.6 AS base

USER root 

FROM amazonlinux:2 AS buildyum

WORKDIR /work

# install java, maven
RUN yum install -y curl tar wget gzip xorg-x11-server-Xvfb glibc-langpack-ja GConf2 unzip libicu-devel yum-utils rpmdevtools 

# mkdir /opt/bin
RUN mkdir /opt/bin

# Install serverless-chrome
RUN cd /tmp && \
    wget https://github.com/adieuadieu/serverless-chrome/releases/download/v1.0.0-37/stable-headless-chromium-amazonlinux-2017-03.zip && \
    unzip stable-headless-chromium-amazonlinux-2017-03.zip && \
    mv headless-chromium /opt/bin/headless-chromium && \
    rm stable-headless-chromium-amazonlinux-2017-03.zip
    
# Install ChromeDriver
RUN cd /tmp && \
    wget https://chromedriver.storage.googleapis.com/2.37/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /opt/bin/chromedriver && \
    rm chromedriver_linux64.zip

FROM base AS final  
WORKDIR /var/task  
COPY --from=buildyum /opt /opt  

RUN cd /opt
RUN mkdir python
RUN cd python

COPY requirements.txt /tmp/requirements.txt 

RUN pip install --upgrade pip 
RUN pip install -r /tmp/requirements.txt -t /opt/python

CMD ["app.lambda_handler"]